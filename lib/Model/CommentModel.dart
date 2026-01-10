import 'AuthUserModel.dart';

class CommentModel {
  final String id;
  final String postId;
  final String? parentCommentId;
  final int level;
  final AuthUserModel author;
  final AuthUserModel? mentionedUser;
  final String content;
  final List<String> images;
  int likesCount;
  int repliesCount;
  bool isLiked;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.level,
    required this.author,
    required this.content,
    required this.images,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
    this.mentionedUser,
    List<CommentModel> replies = const [],
  })  : replies = List<CommentModel>.from(replies),
        super();

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userMap = (json['user'] ?? json['author']) as Map<String, dynamic>? ?? {};
    final mentionedMap = json['mentionedUser'] as Map<String, dynamic>?;
    final replyList = (json['replies'] as List?) ?? const [];

    return CommentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      parentCommentId: json['parentCommentId']?.toString(),
      level: json['level'] is int ? json['level'] as int : int.tryParse('${json['level']}') ?? 0,
      author: AuthUserModel.fromJson(Map<String, dynamic>.from(userMap)),
      mentionedUser: mentionedMap != null ? AuthUserModel.fromJson(Map<String, dynamic>.from(mentionedMap)) : null,
      content: json['content']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
      likesCount: _parseInt(json['likesCount'] ?? json['likes']),
      repliesCount: _parseInt(json['repliesCount'] ?? json['replies']),
      isLiked: json['isLiked'] == true,
      isEdited: json['isEdited'] == true,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      replies: replyList.map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
