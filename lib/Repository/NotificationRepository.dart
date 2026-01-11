import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mangxahoi/Model/NotificationModel.dart';
import 'package:mangxahoi/Utils.dart';

import 'BaseRepository.dart';

class NotificationListResult {
  final List<NotificationModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final int unreadCount;

  NotificationListResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.unreadCount,
  });
}

class NotificationRepository extends BaseRepository {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Utils.accessToken != null) 'Authorization': 'Bearer ${Utils.accessToken}',
  };

  Future<NotificationListResult> getNotifications({
    int page = 1,
    int limit = 20,
    String status = 'all',
  }) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/notifications').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
      },
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        final dataList = decoded['data'] as List? ?? [];
        final meta = decoded['meta'] as Map<String, dynamic>? ?? {};

        final items = dataList
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return NotificationListResult(
          items: items,
          page: meta['page'] ?? page,
          limit: meta['limit'] ?? limit,
          total: meta['total'] ?? items.length,
          totalPages: meta['totalPages'] ?? 1,
          unreadCount: meta['unreadCount'] ?? 0,
        );
      }
    }

    super.codeErrorHandle(response.statusCode);
    throw Exception('Failed to load notifications');
  }

  Future<NotificationSummary> getSummary() async {
    final uri = Uri.parse('${Utils.baseUrl}/api/notifications/summary');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return NotificationSummary.fromJson(decoded['data']);
      }
    }

    super.codeErrorHandle(response.statusCode);
    return NotificationSummary(total: 0, unread: 0, hasUnread: false);
  }

  Future<NotificationModel?> markAsRead(String notificationId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/notifications/$notificationId/read');

    final response = await http.patch(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return NotificationModel.fromJson(decoded['data']);
      }
    }

    super.codeErrorHandle(response.statusCode);
    return null;
  }

  Future<int> markAllAsRead() async {
    final uri = Uri.parse('${Utils.baseUrl}/api/notifications/read-all');

    final response = await http.patch(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return decoded['data']['updated'] ?? 0;
      }
    }

    super.codeErrorHandle(response.statusCode);
    return 0;
  }

  Future<void> updatePushToken(String pushToken) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/users/me/push-token');
    
    debugPrint('NotificationRepository.updatePushToken: URL = $uri');
    debugPrint('NotificationRepository.updatePushToken: Token = ${pushToken.substring(0, 20)}...');
    debugPrint('NotificationRepository.updatePushToken: Headers = $_headers');

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode({'pushToken': pushToken}),
    );

    debugPrint('NotificationRepository.updatePushToken: Status = ${response.statusCode}');
    debugPrint('NotificationRepository.updatePushToken: Response = ${response.body}');

    if (response.statusCode != 200) {
      super.codeErrorHandle(response.statusCode);
      throw Exception('Failed to update push token: ${response.statusCode} - ${response.body}');
    }
  }
}
