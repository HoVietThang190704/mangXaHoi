import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiService._internal(this._dio, this._storage);

  static String _normalizeBaseUrl(String url) {
    // trim + remove trailing slashes
    return url.trim().replaceAll(RegExp(r'/*$'), '');
  }

  static Future<ApiService> create({bool enableLog = true}) async {
    // 1) Load env (không crash nếu thiếu)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Warning: .env not found or not bundled. Using defaults. $e');
    }

    // 2) Default base url theo platform (fallback)
    final platformDefault =
        Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';

    // 3) BaseUrl từ env hoặc fallback
    final rawBaseUrl = dotenv.env['API_BASE_URL'] ?? platformDefault;
    final baseUrl = _normalizeBaseUrl(rawBaseUrl);

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

          print('➡️ [API] ${options.method} ${dio.options.baseUrl}${options.path}');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }

          return handler.next(options);
        },
        onError: (e, handler) {
          print('❌ [API ERROR] baseUrl=${dio.options.baseUrl}');
          print('❌ status=${e.response?.statusCode}');
          print('❌ data=${e.response?.data}');
          return handler.next(e);
        },
      ),
    );

    print('✅ API_BASE_URL in use: ${dio.options.baseUrl}');

    return ApiService._internal(dio, storage);
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

    // Persist tokens if registration returns them
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
      print('⚠️ Failed to persist tokens after register: $e');
    }

    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });

    // Persist tokens if returned so Interceptor can include Authorization header
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
      // ignore storage write failures but log for debugging
      print('⚠️ Failed to persist tokens: $e');
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
