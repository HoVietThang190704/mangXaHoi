import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  CloudinaryService();

  Future<String> uploadImage(File file) async {
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
      }
    }

    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw Exception('Thiếu cấu hình Cloudinary (CLOUDINARY_CLOUD_NAME, CLOUDINARY_UPLOAD_PRESET)');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.cloudinary.com',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': uploadPreset,
    });

    final response = await dio.post('/v1_1/$cloudName/image/upload', data: formData);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final url = data['secure_url'] ?? data['url'];
      if (url != null) {
        return url.toString();
      }
    }
    throw Exception('Không nhận được đường dẫn ảnh sau khi tải lên');
  }
}
