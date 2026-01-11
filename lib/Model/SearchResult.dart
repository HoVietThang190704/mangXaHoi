import 'AuthUserModel.dart';
import 'PostModel.dart';

class SearchPageInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  const SearchPageInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  const SearchPageInfo.empty()
      : page = 1,
        limit = 0,
        total = 0,
        totalPages = 0,
        hasMore = false;

  factory SearchPageInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchPageInfo.empty();
    final page = _parseInt(json['page'], fallback: 1);
    final limit = _parseInt(json['limit'], fallback: 0);
    final total = _parseInt(json['total'], fallback: 0);
    final totalPages = _parseInt(json['totalPages'], fallback: _calcTotalPages(total, limit));
    final hasMore = json['hasMore'] == true || (total > 0 && total > page * (limit > 0 ? limit : 1));

    return SearchPageInfo(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasMore: hasMore,
    );
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static int _calcTotalPages(int total, int limit) {
    if (limit <= 0) return 0;
    return (total / limit).ceil();
  }
}

class SearchSection<T> {
  final List<T> items;
  final SearchPageInfo pageInfo;

  const SearchSection({required this.items, required this.pageInfo});
}

class SearchResult {
  final String query;
  final SearchSection<AuthUserModel> users;
  final SearchSection<PostModel> posts;
  final String? message;

  const SearchResult({
    required this.query,
    required this.users,
    required this.posts,
    this.message,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : <String, dynamic>{};
    final usersJson = data['users'] is Map<String, dynamic> ? data['users'] as Map<String, dynamic> : <String, dynamic>{};
    final postsJson = data['posts'] is Map<String, dynamic> ? data['posts'] as Map<String, dynamic> : <String, dynamic>{};

    final userItems = (usersJson['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AuthUserModel.fromJson)
        .toList();
    final postItems = (postsJson['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PostModel.fromJson)
        .toList();

    return SearchResult(
      query: data['query']?.toString() ?? json['query']?.toString() ?? '',
      users: SearchSection<AuthUserModel>(
        items: userItems,
        pageInfo: SearchPageInfo.fromJson(usersJson),
      ),
      posts: SearchSection<PostModel>(
        items: postItems,
        pageInfo: SearchPageInfo.fromJson(postsJson),
      ),
      message: json['message']?.toString(),
    );
  }
}
