import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/SearchUsersResult.dart';
import 'package:mangxahoi/Repository/UserRepository.dart';

class UserService {
  UserService({UserRepository? repository}) : _repository = repository ?? UserRepository();

  final UserRepository _repository;

  Future<SearchUsersResult> searchUsers(String query, {int page = 1, int limit = 20}) {
    return _repository.searchUsers(query: query, page: page, limit: limit);
  }

  Future<AuthUserModel> getPublicProfile(String userId) {
    return _repository.getPublicProfile(userId);
  }
}
