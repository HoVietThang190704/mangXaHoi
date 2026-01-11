class ChatAttachment {
  final String url;
  final String? type;
  final String? name;

  ChatAttachment({required this.url, this.type, this.name});

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        if (type != null) 'type': type,
        if (name != null) 'name': name,
      };
}

class ChatParticipant {
  final String userId;
  final String? userName;
  final String? avatar;

  ChatParticipant({required this.userId, this.userName, this.avatar});

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  String get displayName => (userName?.trim().isNotEmpty == true ? userName!.trim() : 'Người dùng');
}

class ChatThreadModel {
  final String id;
  final List<String> participantIds;
  final List<ChatParticipant> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final int unreadCount;
  final Map<String, int> unreadByUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatThreadModel({
    required this.id,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderId,
    required this.unreadCount,
    required this.unreadByUser,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List?)
            ?.map((item) => ChatParticipant.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList() ??
        <ChatParticipant>[];
    final unreadRaw = json['unreadByUser'] is Map
        ? Map<String, int>.from((json['unreadByUser'] as Map).map((key, value) => MapEntry(key.toString(), _toInt(value))))
        : <String, int>{};
    return ChatThreadModel(
      id: json['threadId']?.toString() ?? json['id']?.toString() ?? '',
      participantIds: (json['participantIds'] as List?)?.map((e) => e.toString()).toList() ??
          (json['participants'] as List?)?.map((e) => (e as Map)['userId'].toString()).toList() ??
          <String>[],
      participants: participants,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      lastSenderId: json['lastSenderId']?.toString(),
      unreadCount: _toInt(json['unreadCount']),
      unreadByUser: unreadRaw,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  bool includesUser(String userId) => participantIds.contains(userId);

  ChatParticipant? otherParticipant(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return participants.isNotEmpty ? participants.first : null;
    }
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.isNotEmpty ? participants.first : ChatParticipant(userId: '', userName: null),
    );
  }

  ChatThreadModel copyWith({int? unreadCountOverride}) {
    return ChatThreadModel(
      id: id,
      participantIds: participantIds,
      participants: participants,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      lastSenderId: lastSenderId,
      unreadCount: unreadCountOverride ?? unreadCount,
      unreadByUser: unreadByUser,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String threadId;
  final String senderId;
  final String recipientId;
  final String? content;
  final List<ChatAttachment> attachments;
  final DateTime createdAt;
  final DateTime? readAt;

  ChatMessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.recipientId,
    this.content,
    required this.attachments,
    required this.createdAt,
    this.readAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      threadId: json['threadId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      recipientId: json['recipientId']?.toString() ?? '',
      content: json['content']?.toString(),
      attachments: (json['attachments'] as List?)
              ?.map((item) => ChatAttachment.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          <ChatAttachment>[],
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      readAt: _parseDate(json['readAt']),
    );
  }

  bool get hasText => content != null && content!.trim().isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
}

class ChatThreadsResult {
  final List<ChatThreadModel> threads;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ChatThreadsResult({
    required this.threads,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

class ChatMessagesResult {
  final ChatThreadModel thread;
  final List<ChatMessageModel> messages;
  final bool hasMore;
  final String? nextCursor;

  ChatMessagesResult({
    required this.thread,
    required this.messages,
    required this.hasMore,
    required this.nextCursor,
  });
}

class ChatSendMessageResult {
  final ChatThreadModel thread;
  final ChatMessageModel message;

  ChatSendMessageResult({required this.thread, required this.message});
}

class ChatGroupResult {
  final String id;
  final String name;
  final String? avatar;
  final List<String> members;
  final List<String> admins;

  ChatGroupResult({required this.id, required this.name, this.avatar, required this.members, required this.admins});

  factory ChatGroupResult.fromJson(Map<String, dynamic> json) {
    return ChatGroupResult(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      members: (json['members'] as List?)?.map((e) => e.toString()).toList() ?? [],
      admins: (json['admins'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final parsed = DateTime.tryParse(value.toString());
  return parsed;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
