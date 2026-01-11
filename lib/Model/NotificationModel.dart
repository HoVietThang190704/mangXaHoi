class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.payload,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      payload: json['payload'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['payload'] as Map) 
          : null,
      isRead: json['isRead'] == true,
      readAt: json['readAt'] != null 
          ? DateTime.tryParse(json['readAt'].toString()) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'payload': payload,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if notification is a friend request
  bool get isFriendRequest => type == 'friend_request';

  /// Check if notification is a friend request acceptance
  bool get isFriendAccepted => type == 'friend_request_accepted';

  /// Check if notification is a new message
  bool get isNewMessage => type == 'new_message';

  /// Check if notification is a comment
  bool get isComment => type == 'comment';

  /// Check if notification is a comment reply
  bool get isCommentReply => type == 'comment_reply';

  /// Get sender ID from friend request payload
  String? get friendRequestSenderId => payload?['senderId']?.toString();

  /// Get request ID from friend request payload
  String? get friendRequestId => payload?['requestId']?.toString();

  /// Get sender name from friend request payload
  String? get friendRequestSenderName => payload?['senderName']?.toString();

  /// Get sender avatar from friend request payload
  String? get friendRequestSenderAvatar => payload?['senderAvatar']?.toString();

  /// Get sender ID from new message payload
  String? get messageSenderId => payload?['senderId']?.toString();

  /// Get sender name from new message payload
  String? get messageSenderName => payload?['senderName']?.toString();

  /// Get sender avatar from new message payload
  String? get messageSenderAvatar => payload?['senderAvatar']?.toString();

  /// Get thread ID from new message payload
  String? get messageThreadId => payload?['threadId']?.toString();

  /// Get commenter ID from comment payload
  String? get commenterId => payload?['commenterId']?.toString();

  /// Get commenter name from comment payload
  String? get commenterName => payload?['commenterName']?.toString();

  /// Get commenter avatar from comment payload
  String? get commenterAvatar => payload?['commenterAvatar']?.toString();

  /// Get post ID from comment payload
  String? get commentPostId => payload?['postId']?.toString();

  /// Get comment ID from comment payload
  String? get commentId => payload?['commentId']?.toString();

  /// Get replier ID from comment reply payload
  String? get replierId => payload?['replierId']?.toString();

  /// Get replier name from comment reply payload
  String? get replierName => payload?['replierName']?.toString();

  /// Get replier avatar from comment reply payload
  String? get replierAvatar => payload?['replierAvatar']?.toString();
}

class NotificationSummary {
  final int total;
  final int unread;
  final bool hasUnread;
  final NotificationModel? latestNotification;
  final DateTime? latestUnreadAt;

  NotificationSummary({
    required this.total,
    required this.unread,
    required this.hasUnread,
    this.latestNotification,
    this.latestUnreadAt,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      total: json['total'] is int ? json['total'] : 0,
      unread: json['unread'] is int ? json['unread'] : 0,
      hasUnread: json['hasUnread'] == true,
      latestNotification: json['latestNotification'] != null
          ? NotificationModel.fromJson(json['latestNotification'])
          : null,
      latestUnreadAt: json['latestUnreadAt'] != null
          ? DateTime.tryParse(json['latestUnreadAt'].toString())
          : null,
    );
  }
}
