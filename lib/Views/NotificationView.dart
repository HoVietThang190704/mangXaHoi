import 'package:flutter/material.dart';
import 'package:mangxahoi/Model/NotificationModel.dart';
import 'package:mangxahoi/Service/NotificationService.dart';
import 'package:mangxahoi/Views/Profile/UserProfileView.dart';
import 'package:mangxahoi/Views/Chat/ChatDetailView.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await notificationService.refreshNotifications();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await notificationService.loadMore();
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _markAllRead() async {
    await notificationService.markAllAsRead();
  }

  void _onNotificationTap(NotificationModel notification) async {
    // Mark as read
    await notificationService.markAsRead(notification.id);

    if (!mounted) return;

    // Navigate based on notification type
    if (notification.isFriendRequest || notification.isFriendAccepted) {
      final userId = notification.friendRequestSenderId ?? notification.payload?['userId']?.toString();
      if (userId != null && userId.isNotEmpty) {
        Navigator.of(context).pushNamed(
          '/profile/user',
          arguments: UserProfileArguments(userId: userId),
        );
      }
    } else if (notification.isNewMessage) {
      final senderId = notification.messageSenderId;
      final senderName = notification.messageSenderName;
      final senderAvatar = notification.messageSenderAvatar;
      if (senderId != null && senderId.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailView(
              targetUserId: senderId,
              targetDisplayName: senderName,
              targetAvatar: senderAvatar,
            ),
          ),
        );
      }
    } else if (notification.isComment) {
      final commenterId = notification.commenterId;
      if (commenterId != null && commenterId.isNotEmpty) {
        Navigator.of(context).pushNamed(
          '/profile/user',
          arguments: UserProfileArguments(userId: commenterId),
        );
      }
    } else if (notification.isCommentReply) {
      // Navigate to replier's profile
      final replierId = notification.replierId;
      if (replierId != null && replierId.isNotEmpty) {
        Navigator.of(context).pushNamed(
          '/profile/user',
          arguments: UserProfileArguments(userId: replierId),
        );
      }
    }
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'friend_request':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case 'friend_request_accepted':
        icon = Icons.people;
        color = Colors.green;
        break;
      case 'like':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'comment':
        icon = Icons.comment;
        color = Colors.orange;
        break;
      case 'comment_reply':
        icon = Icons.reply;
        color = Colors.teal;
        break;
      case 'new_message':
        icon = Icons.message;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final loc = AppLocalizations.of(context)!;
    final timeAgo = _formatTimeAgo(notification.createdAt, loc);

    return InkWell(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notification.isRead ? Colors.white : Colors.blue.withValues(alpha: 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime, AppLocalizations loc) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ${loc.notification_days_ago}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${loc.notification_hours_ago}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${loc.notification_minutes_ago}';
    } else {
      return loc.notification_just_now;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          loc.notification_title,
          style: const TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: notificationService.unreadCount,
            builder: (context, unread, _) {
              if (unread == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: _markAllRead,
                child: Text(loc.notification_mark_all_read),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(loc.notification_load_error),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: Text(loc.profile_retry),
                      ),
                    ],
                  ),
                )
              : ValueListenableBuilder<List<NotificationModel>>(
                  valueListenable: notificationService.notifications,
                  builder: (context, notifications, _) {
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              loc.notification_empty,
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: notifications.length + (_isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index == notifications.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildNotificationItem(notifications[index]);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
