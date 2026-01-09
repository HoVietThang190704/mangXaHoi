import 'package:mangxahoi/Model/AuthUserModel.dart';

class SearchPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const SearchPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      page: json['page'] is int ? json['page'] as int : int.tryParse('${json['page'] ?? 0}') ?? 0,
      limit: json['limit'] is int ? json['limit'] as int : int.tryParse('${json['limit'] ?? 0}') ?? 0,
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total'] ?? 0}') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages'] as int
          : int.tryParse('${json['totalPages'] ?? 0}') ?? 0,
    );
  }

  const SearchPagination.empty()
      : page = 1,
        limit = 0,
        total = 0,
        totalPages = 0;
}

class SearchUsersResult {
  final List<AuthUserModel> users;
  final SearchPagination pagination;
  final String? message;

  SearchUsersResult({
    required this.users,
    required this.pagination,
    this.message,
  });

  factory SearchUsersResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final usersJson = data['users'] is List ? data['users'] as List : const [];
    final paginationJson = data['pagination'] is Map<String, dynamic>
        ? data['pagination'] as Map<String, dynamic>
        : <String, dynamic>{};

    return SearchUsersResult(
      users: usersJson
          .whereType<Map<String, dynamic>>()
          .map(AuthUserModel.fromJson)
          .toList(),
      pagination: SearchPagination.fromJson(paginationJson),
      message: json['message']?.toString(),
    );
  }
}
