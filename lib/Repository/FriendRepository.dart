import 'dart:async';

import 'package:mangxahoi/Model/FriendStatus.dart';

/// Temporary in-memory repository for friend interactions.
/// Replace with real API integration once backend endpoints are ready.
class FriendRepository {
  final Map<String, FriendStatus> _state = {};

  Future<FriendStatus> fetchStatus(String userId) async {
    return _simulateLatency(() => _state[userId] ?? FriendStatus.none);
  }

  Future<FriendStatus> sendRequest(String userId) async {
    return _simulateLatency(() {
      return _state[userId] = FriendStatus.requested;
    });
  }

  Future<FriendStatus> cancelRequest(String userId) async {
    return _simulateLatency(() {
      return _state[userId] = FriendStatus.none;
    });
  }

  Future<FriendStatus> removeFriend(String userId) async {
    return _simulateLatency(() {
      _state[userId] = FriendStatus.none;
      return FriendStatus.none;
    });
  }

  Future<FriendStatus> _simulateLatency(FriendStatus Function() action) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return action();
  }
}
