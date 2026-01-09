import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/services/api_service.dart';

class SettingsService {
  Future<AuthUserModel> fetchProfile() async {
    final api = await ApiService.create();
    final data = await api.getProfile();
    return _parseUser(data);
  }

  Future<AuthUserModel> updateProfile({
    String? userName,
    String? phone,
    Map<String, dynamic>? address,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'userName': userName,
      'phone': phone,
      'address': address,
      'avatar': avatarUrl,
    };
    payload.removeWhere((key, value) => value == null);

    final api = await ApiService.create();
    final data = await api.putJson('/api/users/me/profile', payload);
    _throwIfFailed(data, fallbackMessage: 'Cập nhật hồ sơ thất bại');
    return _parseUser(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final api = await ApiService.create();
    final data = await api.postJson('/api/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    _throwIfFailed(data, fallbackMessage: 'Đổi mật khẩu thất bại');
  }

  Future<String> uploadAvatar(File file) async {
    final api = await ApiService.create();
    final formData = FormData.fromMap({'avatar': await MultipartFile.fromFile(file.path)});
    final data = await api.uploadFormData('/api/users/me/avatar', formData);
    _throwIfFailed(data, fallbackMessage: 'Tải ảnh đại diện thất bại');
    if (data is Map<String, dynamic>) {
      final url = data['data'] is Map<String, dynamic> ? data['data']['avatar'] : data['avatar'];
      if (url != null) return url.toString();
    }
    throw Exception('Không nhận được URL ảnh từ máy chủ');
  }

  Future<void> sendFeedback(String message, {String? email}) async {
    // Backend chưa hỗ trợ, tạm thời hoàn thành ngay để tránh lỗi UI.
    return;
  }

  Future<void> updatePreferences({String? languageCode, bool? notificationsEnabled}) async {
    // Backend chưa hỗ trợ lưu tùy chọn, bỏ qua để tránh lỗi 404.
    return;
  }

  AuthUserModel _parseUser(dynamic data) {
    if (data is Map<String, dynamic>) {
      final userRaw = data['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['data'] as Map)
          : data;
      return AuthUserModel.fromJson(userRaw);
    }
    throw const FormatException('Định dạng phản hồi không hợp lệ');
  }

  void _throwIfFailed(dynamic data, {required String fallbackMessage}) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('success') && data['success'] == false) {
        final message = data['message']?.toString() ?? fallbackMessage;
        throw Exception(message);
      }
    }
  }
}
