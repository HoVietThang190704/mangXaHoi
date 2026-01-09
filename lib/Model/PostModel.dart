import 'dart:convert';

import 'AuthUserModel.dart';

class PostModel {
  final String id;
  final String userId;
  final AuthUserModel author;
  final String content;
  final List<String> images;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String visibility;
  final bool isEdited;
  int likes;
  int comments;
  int shares;
  bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.imageUrl,
    this.visibility = 'public',
    this.isEdited = false,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final userMap = _mapFrom(json['user']);
    final authorMap = userMap.isNotEmpty ? userMap : _mapFrom(json['author']);
    final author = AuthUserModel.fromJson(authorMap);
    final createdAt = _parseDate(json['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDate(json['updatedAt']) ?? createdAt;

    return PostModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? author.id,
      author: author,
      content: json['content']?.toString() ?? '',
      images: images,
      imageUrl: json['imageUrl']?.toString() ?? (images.isNotEmpty ? images.first : null),
      createdAt: createdAt,
      updatedAt: updatedAt,
      visibility: json['visibility']?.toString() ?? 'public',
      isEdited: json['isEdited'] == true,
      likes: _parseInt(json['likesCount'] ?? json['likes']),
      comments: _parseInt(json['commentsCount'] ?? json['comments']),
      shares: _parseInt(json['sharesCount'] ?? json['shares']),
      isLiked: json['isLiked'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'author': author.toJson(),
        'content': content,
        'images': images,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'likesCount': likes,
        'commentsCount': comments,
        'sharesCount': shares,
        'isLiked': isLiked,
        'visibility': visibility,
        'isEdited': isEdited,
      };

  static List<PostModel> listFromJsonString(String source) {
    final data = json.decode(source) as List<dynamic>;
    return data.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }
}
