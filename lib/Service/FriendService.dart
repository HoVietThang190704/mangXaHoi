import 'package:mangxahoi/Model/FriendStatus.dart';
import 'package:mangxahoi/Repository/FriendRepository.dart';

class FriendService {
  FriendService({FriendRepository? repository}) : _repository = repository ?? FriendRepository();

  final FriendRepository _repository;

  String? _cachedRequestId;

  String? get cachedRequestId => _cachedRequestId;

  Future<FriendStatus> getStatus(String userId) async {
    final result = await _repository.fetchStatus(userId);
    _cachedRequestId = result.requestId;
    return result.status;
  }

  Future<FriendStatus> sendFriendRequest(String userId) async {
    final request = await _repository.sendRequest(userId);
    _cachedRequestId = request.id;
    return FriendStatus.pendingSent;
  }

  Future<FriendStatus> cancelFriendRequest(String userId) async {
    await _repository.cancelRequest(userId);
    _cachedRequestId = null;
    return FriendStatus.none;
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _repository.acceptRequest(requestId);
    _cachedRequestId = null;
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _repository.rejectRequest(requestId);
    _cachedRequestId = null;
  }

  Future<FriendStatus> removeFriend(String userId) async {
    await _repository.removeFriend(userId);
    _cachedRequestId = null;
    return FriendStatus.none;
  }

  Future<List<FriendRequestModel>> getPendingRequests({int page = 1, int limit = 20}) {
    return _repository.getPendingRequests(page: page, limit: limit);
  }
}
