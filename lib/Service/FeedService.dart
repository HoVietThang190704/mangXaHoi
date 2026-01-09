import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Model/PostModel.dart';
import '../Repository/FeedRepository.dart';

class FeedService {
  final FeedRepository _repo = FeedRepository();

  Future<List<PostModel>> getPosts({int page = 1, int pageSize = 10}) async {
    final posts = await _repo.getFeed(page: page, limit: pageSize);
    return posts;
  }

  Future<PostModel> createPost(Map<String, dynamic> payload) async{
    // If payload contains local file paths under 'images', upload them first
    if(payload.containsKey('images') && payload['images'] is List<String>){
      final paths = List<String>.from(payload['images']);
      if(paths.isNotEmpty){
        try{
          final uploaded = await _repo.uploadFiles(paths);
          payload['images'] = uploaded; // uploaded urls or ids
        } catch (e){
          print('❌ File upload failed: $e');
          rethrow; // bubble up to UI
        }
      } else {
        payload.remove('images');
      }
    }

    try{
      final p = await _repo.createPost(payload);
      return p;
    } catch(e){
      print('❌ createPost failed in service: $e');
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

  Future<PostModel> getPostById(String postId) async {
    return _repo.getPostById(postId);
  }

  Future<List<String>> uploadFiles(List<String> filePaths) async{
    return await _repo.uploadFiles(filePaths);
  }
}
