import '../Model/CommentModel.dart';
import '../Repository/CommentRepository.dart';

class CommentService {
  final CommentRepository _repo = CommentRepository();

  Future<CommentPage> fetchComments(String postId, {int page = 1, int limit = 20}) async {
    return _repo.getComments(postId, page: page, limit: limit);
  }

  Future<CommentModel> addComment({required String postId, required String content, List<String>? images, String? mentionedUserId}) async {
    final payload = await _buildPayload(content: content, images: images, mentionedUserId: mentionedUserId);
    return _repo.createComment(postId, payload);
  }

  Future<CommentModel> replyTo({required String commentId, required String content, List<String>? images, String? mentionedUserId}) async {
    final payload = await _buildPayload(content: content, images: images, mentionedUserId: mentionedUserId);
    return _repo.replyToComment(commentId, payload);
  }

  Future<Map<String, dynamic>> toggleLike(String commentId) async {
    return _repo.toggleLike(commentId);
  }

  Future<void> deleteComment(String commentId) async {
    await _repo.deleteComment(commentId);
  }

  Future<Map<String, dynamic>> _buildPayload({required String content, List<String>? images, String? mentionedUserId}) async {
    final payload = <String, dynamic>{};

    // allow image-only comment by sending a single space when text is empty
    final hasImages = images != null && images.isNotEmpty;
    payload['content'] = content.isEmpty && hasImages ? '[image]' : content;

    if (mentionedUserId != null && mentionedUserId.isNotEmpty) {
      payload['mentionedUserId'] = mentionedUserId;
    }

    if (hasImages) {
      final uploaded = await _repo.uploadFiles(images!);
      payload['images'] = uploaded;
    }

    return payload;
  }
}
