import 'package:mangxahoi/services/api_service.dart';
import 'package:dio/dio.dart';
import '../Model/CommentModel.dart';

class CommentPage {
  final List<CommentModel> comments;
  final int page;
  final int limit;
  final bool hasMore;
  final int total;

  CommentPage({
    required this.comments,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.total,
  });
}

class CommentRepository {
  Future<CommentPage> getComments(String postId, {int page = 1, int limit = 20}) async {
    final api = await ApiService.create();
    final res = await api.getJson('/api/comments/post/$postId', queryParameters: {
      'page': page,
      'limit': limit,
    });

    final data = res['data'] as Map<String, dynamic>? ?? {};
    final items = (data['comments'] as List?) ?? const [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    final comments = items
        .map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return CommentPage(
      comments: comments,
      page: pagination['page'] is int ? pagination['page'] as int : page,
      limit: pagination['limit'] is int ? pagination['limit'] as int : limit,
      hasMore: pagination['hasMore'] == true,
      total: pagination['total'] is int ? pagination['total'] as int : 0,
    );
  }

  Future<CommentModel> createComment(String postId, Map<String, dynamic> payload) async {
    final api = await ApiService.create();
    final res = await api.postJson('/api/comments/post/$postId', payload);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return CommentModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<CommentModel> replyToComment(String commentId, Map<String, dynamic> payload) async {
    final api = await ApiService.create();
    final res = await api.postJson('/api/comments/$commentId/reply', payload);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return CommentModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>> toggleLike(String commentId) async {
    final api = await ApiService.create();
    final res = await api.postJson('/api/comments/$commentId/like', const {});
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return {
      'isLiked': data['liked'] ?? data['isLiked'] ?? false,
      'likesCount': data['likesCount'] ?? 0,
    };
  }

  Future<void> deleteComment(String commentId) async {
    final api = await ApiService.create();
    await api.deleteJson('/api/comments/$commentId');
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
      if (data is Map && data['urls'] is List) return List<String>.from(data['urls']);
      if (res['urls'] is List) return List<String>.from(res['urls']);
      return const [];
    } catch (e) {
      if (e is DioException) {
        final resp = e.response?.data;
        if (resp is Map && resp['message'] != null) {
          throw Exception(resp['message'].toString());
        }
        throw Exception('Upload failed: ${e.response?.statusCode ?? 'unknown'}');
      }
      throw Exception(e.toString());
    }
  }
}
