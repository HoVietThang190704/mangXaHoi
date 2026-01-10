enum FriendStatus {
  none,
  requested,
  friends,
}

extension FriendStatusX on FriendStatus {
  bool get isPending => this == FriendStatus.requested;
  bool get isFriends => this == FriendStatus.friends;
}
