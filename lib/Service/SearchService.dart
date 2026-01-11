import 'package:mangxahoi/Model/SearchResult.dart';
import 'package:mangxahoi/Repository/SearchRepository.dart';

class SearchService {
  SearchService({SearchRepository? repository}) : _repository = repository ?? SearchRepository();

  final SearchRepository _repository;

  Future<SearchResult> search(String query, {int userLimit = 20, int postLimit = 10}) {
    return _repository.search(query: query, userLimit: userLimit, postLimit: postLimit);
  }
}
