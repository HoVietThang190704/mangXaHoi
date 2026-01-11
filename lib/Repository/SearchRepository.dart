import 'package:mangxahoi/services/api_service.dart';

import '../Model/SearchResult.dart';

class SearchRepository {
  Future<SearchResult> search({
    required String query,
    int userPage = 1,
    int userLimit = 20,
    int postPage = 1,
    int postLimit = 10,
  }) async {
    final api = await ApiService.create();
    final response = await api.getJson(
      '/api/search',
      queryParameters: {
        'q': query,
        'userPage': userPage,
        'userLimit': userLimit,
        'postPage': postPage,
        'postLimit': postLimit,
      },
    );

    if (response is Map<String, dynamic>) {
      return SearchResult.fromJson(response);
    }

    throw const FormatException('Invalid search response');
  }
}
