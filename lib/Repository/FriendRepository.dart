import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mangxahoi/Model/FriendStatus.dart';
import 'package:mangxahoi/Utils.dart';

import 'BaseRepository.dart';

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final String status;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      senderAvatar: json['senderAvatar']?.toString(),
      receiverId: json['receiverId']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      receiverAvatar: json['receiverAvatar']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class FriendStatusResult {
  final FriendStatus status;
  final String? requestId;

  FriendStatusResult({required this.status, this.requestId});
}

class FriendRepository extends BaseRepository {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Utils.accessToken != null) 'Authorization': 'Bearer ${Utils.accessToken}',
  };

  Future<FriendStatusResult> fetchStatus(String userId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/status/$userId');
    
    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        final data = decoded['data'];
        final statusStr = data['status']?.toString() ?? 'none';
        final status = FriendStatusX.fromString(statusStr);
        final requestId = data['requestId']?.toString();
        return FriendStatusResult(status: status, requestId: requestId);
      }
    }
    
    super.codeErrorHandle(response.statusCode);
    return FriendStatusResult(status: FriendStatus.none);
  }

  Future<FriendRequestModel> sendRequest(String userId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/request/$userId');
    
    final response = await http.post(uri, headers: _headers);
    
    if (response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return FriendRequestModel.fromJson(decoded['data']);
      }
    }
    
    super.codeErrorHandle(response.statusCode);
    final decoded = jsonDecode(response.body);
    throw Exception(decoded['message']?.toString() ?? 'Failed to send friend request');
  }

  Future<void> cancelRequest(String userId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/request/$userId/cancel');
    
    final response = await http.delete(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      return;
    }
    
    super.codeErrorHandle(response.statusCode);
    final decoded = jsonDecode(response.body);
    throw Exception(decoded['message']?.toString() ?? 'Failed to cancel friend request');
  }

  Future<void> acceptRequest(String requestId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/request/$requestId/accept');
    
    final response = await http.post(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      return;
    }
    
    super.codeErrorHandle(response.statusCode);
    final decoded = jsonDecode(response.body);
    throw Exception(decoded['message']?.toString() ?? 'Failed to accept friend request');
  }

  Future<void> rejectRequest(String requestId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/request/$requestId/reject');
    
    final response = await http.post(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      return;
    }
    
    super.codeErrorHandle(response.statusCode);
    final decoded = jsonDecode(response.body);
    throw Exception(decoded['message']?.toString() ?? 'Failed to reject friend request');
  }

  Future<void> removeFriend(String userId) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/$userId');
    
    final response = await http.delete(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      return;
    }
    
    super.codeErrorHandle(response.statusCode);
    final decoded = jsonDecode(response.body);
    throw Exception(decoded['message']?.toString() ?? 'Failed to remove friend');
  }

  Future<List<FriendRequestModel>> getPendingRequests({int page = 1, int limit = 20}) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends/requests/pending').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    
    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        final list = decoded['data'] as List;
        return list.map((e) => FriendRequestModel.fromJson(e)).toList();
      }
    }
    
    super.codeErrorHandle(response.statusCode);
    return [];
  }

  Future<List<FriendListItem>> getFriends({int page = 1, int limit = 50}) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/friends').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = decoded['data'] ?? decoded['items'] ?? decoded;
      if (list is List) {
        return list.map((e) {
          final id = e['id']?.toString() ?? e['_id']?.toString() ?? '';
          return FriendListItem(
            id: id,
            name: e['name']?.toString() ?? e['userName']?.toString() ?? '',
            avatar: e['avatar']?.toString(),
          );
        }).where((item) => item.name.isNotEmpty).toList();
      }
    }

    super.codeErrorHandle(response.statusCode);
    return [];
  }
}

class FriendListItem {
  final String id;
  final String name;
  final String? avatar;

  FriendListItem({required this.id, required this.name, this.avatar});
}

