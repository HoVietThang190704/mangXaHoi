import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mangxahoi/Model/SearchUsersResult.dart';
import 'package:mangxahoi/Utils.dart';

import 'BaseRepository.dart';

class UserRepository extends BaseRepository {
  Future<SearchUsersResult> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('${Utils.baseUrl}/api/users/search').replace(queryParameters: {
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (Utils.accessToken != null) 'Authorization': 'Bearer ${Utils.accessToken}',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == true) {
          return SearchUsersResult.fromJson(decoded);
        }
        throw Exception(decoded['message']?.toString() ?? 'Search failed');
      }
      throw const FormatException('Invalid response format');
    }

    super.codeErrorHandle(response.statusCode);
    throw Exception('Search failed with status ${response.statusCode}');
  }
}
