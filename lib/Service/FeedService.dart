import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Model/PostModel.dart';
import '../Repository/FeedRepository.dart';

class FeedService {
  final FeedRepository _repo = FeedRepository();

  Future<List<PostModel>> getPosts({int page = 1, int pageSize = 10}) async {
    return _repo.getFeed(page: page, limit: pageSize);
  }

  Future<List<PostModel>> getPostsByUser(String userId, {int page = 1, int pageSize = 10}) async {
    return _repo.getPostsByUser(userId, page: page, limit: pageSize);
  }

  Future<PostModel> createPost(Map<String, dynamic> payload) async {
    await _prepareMedia(payload, 'images', _repo.uploadImagesWithIds, idKey: 'cloudinaryPublicIds');
    await _prepareMedia(payload, 'videos', _repo.uploadVideos, idKey: 'videoPublicIds');

    try {
      return await _repo.createPost(payload);
    } catch (e) {
      debugPrint('❌ createPost failed: $e');
      rethrow;
    }
  }

  Future<void> _prepareMedia(
    Map<String, dynamic> payload,
    String key,
    Future<UploadResult> Function(List<String>) uploader, {
    String? idKey,
  }) async {
    if (!payload.containsKey(key)) return;
    final raw = payload[key];
    if (raw is! List) return;

    final cleaned = raw
      .map((e) => e == null ? null : e.toString())
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (cleaned.isEmpty) {
      payload.remove(key);
      if (idKey != null) payload.remove(idKey);
      return;
    }

    final remote = <String>[];
    final local = <String>[];

    for (final path in cleaned) {
      if (_isRemotePath(path)) {
        remote.add(path);
      } else {
        local.add(path);
      }
    }

    if (local.isEmpty) {
      payload[key] = remote;
      return;
    }

    try {
      final uploaded = await uploader(local);
      payload[key] = [...remote, ...uploaded.urls];
      if (idKey != null) {
        payload[idKey] = uploaded.publicIds;
      }
    } catch (e) {
      debugPrint('❌ $key upload failed: $e');
      rethrow;
    }
  }

  bool _isRemotePath(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      return await _repo.toggleLike(postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> getPostById(String postId) {
    return _repo.getPostById(postId);
  }

  Future<List<String>> uploadFiles(List<String> filePaths) {
    return _repo.uploadFiles(filePaths);
  }
}
