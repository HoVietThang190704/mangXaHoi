import 'package:dio/dio.dart';
import 'package:mangxahoi/Model/ChatModels.dart';
import 'package:mangxahoi/services/api_service.dart';

class ChatRepository {
  Future<ChatThreadsResult> fetchThreads({int page = 1, int limit = 20}) async {
    final api = await ApiService.create();
    final response = await api.getJson('/api/chat/threads', queryParameters: {
      'page': page,
      'limit': limit,
    });

    final data = response['data'] as List? ?? [];
    final pagination = response['pagination'] as Map? ?? {};

    return ChatThreadsResult(
      threads: data
          .map((item) => ChatThreadModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: pagination['page'] is int ? pagination['page'] as int : int.tryParse('${pagination['page']}') ?? 1,
      limit: pagination['limit'] is int ? pagination['limit'] as int : int.tryParse('${pagination['limit']}') ?? limit,
      total: pagination['total'] is int ? pagination['total'] as int : int.tryParse('${pagination['total']}') ?? 0,
      totalPages: pagination['totalPages'] is int
          ? pagination['totalPages'] as int
          : int.tryParse('${pagination['totalPages']}') ?? 1,
    );
  }

  Future<ChatMessagesResult> fetchMessages(
    String threadId, {
    String? before,
    int limit = 20,
  }) async {
    final api = await ApiService.create();
    final query = <String, dynamic>{'limit': limit};
    if (before != null && before.isNotEmpty) {
      query['before'] = before;
    }

    final response = await api.getJson('/api/chat/threads/$threadId/messages', queryParameters: query);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final threadJson = data['thread'] as Map<String, dynamic>? ?? {};
    final messagesJson = data['messages'] as List? ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return ChatMessagesResult(
      thread: ChatThreadModel.fromJson(threadJson),
      messages: messagesJson
          .map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      hasMore: pagination['hasMore'] == true,
      nextCursor: pagination['nextCursor']?.toString(),
    );
  }

  Future<ChatSendMessageResult> sendMessage({
    required String recipientId,
    String? threadId,
    String? content,
    List<ChatAttachment>? attachments,
  }) async {
    final api = await ApiService.create();
    final payload = {
      'recipientId': recipientId,
      if (threadId != null && threadId.isNotEmpty) 'threadId': threadId,
      'content': content ?? '',
      if (attachments != null && attachments.isNotEmpty) 'attachments': attachments.map((a) => a.toJson()).toList(),
    };

    final response = await api.postJson('/api/chat/messages', payload);
    final data = response['data'] as Map<String, dynamic>? ?? {};

    return ChatSendMessageResult(
      thread: ChatThreadModel.fromJson(Map<String, dynamic>.from(data['thread'] as Map)),
      message: ChatMessageModel.fromJson(Map<String, dynamic>.from(data['message'] as Map)),
    );
  }

  Future<ChatThreadModel?> markThreadRead(String threadId) async {
    final api = await ApiService.create();
    final response = await api.postJson('/api/chat/threads/$threadId/read', {});
    if (response['data'] case Map<String, dynamic> data) {
      return ChatThreadModel.fromJson(data);
    }
    return null;
  }

  Future<List<ChatAttachment>> uploadImages(List<String> filePaths) async {
    if (filePaths.isEmpty) return [];
    final api = await ApiService.create();
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
    }

    final response = await api.uploadFormData('/api/upload/images', formData);
    final urls = _extractUrls(response);
    return urls.map((url) => ChatAttachment(url: url, type: 'image')).toList();
  }

  List<String> _extractUrls(dynamic response) {
    if (response == null) return [];
    if (response is Map) {
      if (response['data'] is Map && (response['data'] as Map)['urls'] is List) {
        return List<String>.from((response['data'] as Map)['urls']);
      }
      if (response['urls'] is List) {
        return List<String>.from(response['urls']);
      }
    }
    return [];
  }
}
