import 'dart:convert';

import 'AuthUserModel.dart';

class PostModel {
  final int id;
  final AuthUserModel author;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  int likes;
  int comments;
  bool isLiked;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      author: AuthUserModel.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
        'comments': comments,
        'isLiked': isLiked,
      };

  static List<PostModel> listFromJsonString(String source) {
    final data = json.decode(source) as List<dynamic>;
    return data.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
