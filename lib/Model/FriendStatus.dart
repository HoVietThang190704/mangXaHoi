enum FriendStatus {
  none,
  pendingSent,
  pendingReceived,
  friends,
}

extension FriendStatusX on FriendStatus {
  bool get isPendingSent => this == FriendStatus.pendingSent;
  bool get isPendingReceived => this == FriendStatus.pendingReceived;
  bool get isPending => isPendingSent || isPendingReceived;
  bool get isFriends => this == FriendStatus.friends;

  static FriendStatus fromString(String value) {
    switch (value) {
      case 'pending_sent':
        return FriendStatus.pendingSent;
      case 'pending_received':
        return FriendStatus.pendingReceived;
      case 'friends':
        return FriendStatus.friends;
      default:
        return FriendStatus.none;
    }
  }
}
