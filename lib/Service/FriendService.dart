import 'package:mangxahoi/Model/FriendStatus.dart';
import 'package:mangxahoi/Repository/FriendRepository.dart';

class FriendService {
  FriendService({FriendRepository? repository}) : _repository = repository ?? FriendRepository();

  final FriendRepository _repository;

  Future<FriendStatus> getStatus(String userId) {
    return _repository.fetchStatus(userId);
  }

  Future<FriendStatus> sendFriendRequest(String userId) {
    return _repository.sendRequest(userId);
  }

  Future<FriendStatus> cancelFriendRequest(String userId) {
    return _repository.cancelRequest(userId);
  }

  Future<FriendStatus> removeFriend(String userId) {
    return _repository.removeFriend(userId);
  }
}
