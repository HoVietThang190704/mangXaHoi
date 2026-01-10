import 'package:flutter/foundation.dart';
import 'package:mangxahoi/services/api_service.dart';
import 'package:dio/dio.dart';

import '../Model/PostModel.dart';

class FeedRepository {
  Future<List<PostModel>> getFeed({int page = 1, int limit = 10}) async {
    final api = await ApiService.create();
    final jsonData = await api.getJson(
      '/api/posts/feed/public',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = jsonData['data'];
    final postsJson = data != null && data['posts'] != null ? data['posts'] as List : [];
    return postsJson.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PostModel>> getPostsByUser(String userId, {int page = 1, int limit = 10}) async {
    final api = await ApiService.create();
    final jsonData = await api.getJson(
      '/api/posts/user/$userId',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = jsonData['data'];
    final postsJson = data != null && data['posts'] is List ? data['posts'] as List : [];
    return postsJson.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PostModel> getPostById(String postId) async {
    final api = await ApiService.create();
    final jsonData = await api.getJson('/api/posts/$postId');
    final data = jsonData['data'];
    return PostModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<PostModel> createPost(Map<String, dynamic> payload) async {
    final api = await ApiService.create();
    try {
      final jsonData = await api.postJson('/api/posts', payload);
      final data = jsonData['data'];
      return PostModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      _logDioError('createPost', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final api = await ApiService.create();
    try {
      final jsonData = await api.postJson('/api/posts/$postId/like', const {});
      final data = jsonData['data'] ?? {};
      return {
        'isLiked': data['liked'] ?? data['isLiked'] ?? false,
        'likesCount': data['likesCount'] ?? data['likes'] ?? 0,
      };
    } catch (e) {
      _logDioError('toggleLike', e);
      rethrow;
    }
  }

  Future<List<String>> uploadFiles(List<String> filePaths) async {
    final api = await ApiService.create();
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
      }

      final res = await api.uploadFormData('/api/upload/images', formData);
      final data = res['data'];
      if (data == null) return [];
      if (data is Map && data['urls'] is List) return List<String>.from(data['urls']);
      if (res['urls'] is List) return List<String>.from(res['urls']);
      return [];
    } catch (e) {
      _logDioError('uploadFiles', e);
      rethrow;
    }
  }

  void _logDioError(String scope, Object error) {
    if (error is DioException) {
      final resp = error.response?.data;
      debugPrint('❌ $scope dio error: ${error.message} | response: $resp');
      if (resp is Map && resp['message'] != null) {
        throw Exception(resp['message'].toString());
      }
      throw Exception('Server error: ${error.response?.statusCode ?? 'unknown'}');
    }
    debugPrint('❌ $scope error: $error');
  }
}
