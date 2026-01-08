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
        // Cho phép Dio không throw riêng vì status 400
        // để mình vẫn đọc được e.response?.data và xử lý.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // 6) Logging (optional)
    if (enableLog) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    // 7) Auth interceptor
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

  // -------------------------
  // Generic helpers
  // -------------------------
  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await _dio.get(path, queryParameters: queryParameters);

    // Nếu status >= 400 thì throw để UI handle
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

  // -------------------------
  // Auth APIs
  // -------------------------
  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final data = await postJson('/api/auth/register', payload);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await getJson('/api/auth/profile');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}
