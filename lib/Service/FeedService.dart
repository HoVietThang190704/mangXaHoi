import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Model/PostModel.dart';
import '../Repository/FeedRepository.dart';

class FeedService {
  final FeedRepository _repo = FeedRepository();

  Future<List<PostModel>> getPosts({int page = 1, int pageSize = 10}) async {
    return _repo.getFeed(page: page, limit: pageSize);
  }

  Future<PostModel> createPost(Map<String, dynamic> payload) async {
    if (payload.containsKey('images') && payload['images'] is List<String>) {
      final paths = List<String>.from(payload['images']);
      if (paths.isEmpty) {
        payload.remove('images');
      } else {
        try {
          final uploaded = await _repo.uploadFiles(paths);
          payload['images'] = uploaded;
        } catch (e) {
          debugPrint('❌ File upload failed: $e');
          rethrow;
        }
      }
    }

    try {
      return await _repo.createPost(payload);
    } catch (e) {
      debugPrint('❌ createPost failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      return await _repo.toggleLike(postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> uploadFiles(List<String> filePaths) {
    return _repo.uploadFiles(filePaths);
  }
}
