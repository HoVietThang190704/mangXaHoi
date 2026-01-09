import 'package:mangxahoi/services/api_service.dart';
import 'package:dio/dio.dart';

import '../Model/PostModel.dart';

class FeedRepository{
  Future<List<PostModel>> getFeed({int page = 1, int limit = 10}) async{
    final api = await ApiService.create();
    // Use public feed endpoint (server exposes /feed/public and /feed/user)
    final jsonData = await api.getJson('/api/posts/feed/public', queryParameters: { 'page': page, 'limit': limit });
    final data = jsonData['data'];
    final postsJson = data != null && data['posts'] != null ? data['posts'] as List : [];
    return postsJson.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PostModel> getPostById(String postId) async{
    final api = await ApiService.create();
    final jsonData = await api.getJson('/api/posts/$postId');
    final data = jsonData['data'];
    return PostModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<PostModel> createPost(Map<String, dynamic> payload) async{
    final api = await ApiService.create();
    try{
      final jsonData = await api.postJson('/api/posts', payload);
      final data = jsonData['data'];
      return PostModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      // Normalize error to include useful details
      print('❌ createPost error: $e');
      if (e is DioException) {
        final resp = e.response?.data;
        print('❌ createPost response: $resp');
        if (resp is Map && resp['message'] != null) {
          throw Exception(resp['message'].toString());
        }
        throw Exception('Server error: ${e.response?.statusCode ?? 'unknown'}');
      }
      throw Exception(e.toString());
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
      print('❌ toggleLike error: $e');
      if (e is DioException) {
        final resp = e.response?.data;
        print('❌ toggleLike response: $resp');
        if (resp is Map && resp['message'] != null) {
          throw Exception(resp['message'].toString());
        }
        throw Exception('Server error: ${e.response?.statusCode ?? 'unknown'}');
      }
      throw Exception(e.toString());
    }
  }

  // upload files (images/videos) to server and return array of urls/public ids
  Future<List<String>> uploadFiles(List<String> filePaths) async{
    final api = await ApiService.create();

    try{
      final formData = FormData();
      for(final p in filePaths){
        // Use 'images' field name to match backend `upload.array('images')`
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(p)));
      }

      final res = await api.uploadFormData('/api/upload/images', formData);
      print('✅ uploadFiles response: $res');

      final data = res['data'];
      if(data == null) return [];
      if(data is Map && data['urls'] is List) return List<String>.from(data['urls']);
      if(res['urls'] is List) return List<String>.from(res['urls']);
      return [];
    } catch(e){
      print('❌ uploadFiles error: $e');
      if(e is DioException){
        final resp = e.response?.data;
        print('❌ uploadFiles response: $resp');
        if(resp is Map && resp['message'] != null) throw Exception(resp['message'].toString());
        throw Exception('Upload failed: ${e.response?.statusCode ?? 'unknown'}');
      }
      throw Exception(e.toString());
    }
  }
}
