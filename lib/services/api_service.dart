import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiService._internal(this._dio, this._storage);

  static bool _envLoaded = false;
  static String? _cachedBaseUrl;

  static String _normalizeBaseUrl(String url) {
    // trim + remove trailing slashes
    return url.trim().replaceAll(RegExp(r'/*$'), '');
  }

  static Future<ApiService> create({bool enableLog = true}) async {
    final baseUrl = await getBaseUrl();

    // 4) Storage (reuse 1 instance)
    const storage = FlutterSecureStorage();

    // 5) Dio options
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (enableLog) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'accessToken');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }

          return handler.next(options);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );

    return ApiService._internal(dio, storage);
  }

  static Future<void> _ensureEnvLoaded() async {
    if (_envLoaded) return;
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Warning: .env not found or not bundled. Using defaults. $e');
    }
    _envLoaded = true;
  }

  static Future<String> getBaseUrl() async {
    await _ensureEnvLoaded();
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    final platformDefault = Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';
    final rawBaseUrl = dotenv.env['API_BASE_URL'] ?? platformDefault;
    _cachedBaseUrl = _normalizeBaseUrl(rawBaseUrl);
    return _cachedBaseUrl!;
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await _dio.get(path, queryParameters: queryParameters);

    if ((res.statusCode ?? 0) >= 400) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: res.data,
      );
    }
    return res.data;
  }

  Future<dynamic> postJson(String path, dynamic data) async {
    final res = await _dio.post(
      path,
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );

    if ((res.statusCode ?? 0) >= 400) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: res.data,
      );
    }
    return res.data;
  }

  Future<dynamic> putJson(String path, dynamic data) async {
    final res = await _dio.put(
      path,
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );

    if ((res.statusCode ?? 0) >= 400) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: res.data,
      );
    }
    return res.data;
  }

  Future<dynamic> deleteJson(String path) async {
    final res = await _dio.delete(path);

    if ((res.statusCode ?? 0) >= 400) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: res.data,
      );
    }

    return res.data;
  }

  /// Upload multipart FormData. Returns decoded JSON map.
  Future<dynamic> uploadFormData(String path, FormData formData) async {
    final res = await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if ((res.statusCode ?? 0) >= 400) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: res.data,
      );
    }
    return res.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final data = await postJson('/api/auth/register', payload);
    try {
      if (data is Map<String, dynamic>) {
        final access = data['accessToken']?.toString();
        final refresh = data['refreshToken']?.toString();
        if (access != null && access.isNotEmpty) {
          await _storage.write(key: 'accessToken', value: access);
        }
        if (refresh != null && refresh.isNotEmpty) {
          await _storage.write(key: 'refreshToken', value: refresh);
        }
      }
    } catch (e) {
    }

    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
    try {
      if (data is Map<String, dynamic>) {
        final access = data['accessToken']?.toString();
        final refresh = data['refreshToken']?.toString();
        if (access != null && access.isNotEmpty) {
          await _storage.write(key: 'accessToken', value: access);
        }
        if (refresh != null && refresh.isNotEmpty) {
          await _storage.write(key: 'refreshToken', value: refresh);
        }
      }
    } catch (e) {
    }

    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await getJson('/api/users/me/profile');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}
