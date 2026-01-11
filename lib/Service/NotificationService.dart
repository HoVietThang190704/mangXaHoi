import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mangxahoi/Model/NotificationModel.dart';
import 'package:mangxahoi/Repository/NotificationRepository.dart';

class NotificationService {
  NotificationService({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  final ValueNotifier<List<NotificationModel>> notifications = ValueNotifier<List<NotificationModel>>([]);

  Timer? _refreshTimer;
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  /// Start periodic refresh of notifications
  void startPeriodicRefresh({Duration interval = const Duration(seconds: 30)}) {
    stopPeriodicRefresh();
    _refreshTimer = Timer.periodic(interval, (_) => refreshNotifications());
  }

  /// Stop periodic refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Refresh notifications from server
  Future<void> refreshNotifications() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      final result = await _repository.getNotifications(page: 1, limit: 20);
      notifications.value = result.items;
      unreadCount.value = result.unreadCount;
      _currentPage = 1;
      _totalPages = result.totalPages;
    } catch (e) {
      debugPrint('NotificationService.refreshNotifications error: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Load more notifications (pagination)
  Future<bool> loadMore() async {
    if (_isLoading || _currentPage >= _totalPages) return false;

    try {
      _isLoading = true;
      final nextPage = _currentPage + 1;
      final result = await _repository.getNotifications(page: nextPage, limit: 20);
      
      final currentList = List<NotificationModel>.from(notifications.value);
      currentList.addAll(result.items);
      notifications.value = currentList;
      
      _currentPage = nextPage;
      _totalPages = result.totalPages;
      
      return result.items.isNotEmpty;
    } catch (e) {
      debugPrint('NotificationService.loadMore error: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Get notification summary
  Future<NotificationSummary> getSummary() async {
    try {
      final summary = await _repository.getSummary();
      unreadCount.value = summary.unread;
      return summary;
    } catch (e) {
      debugPrint('NotificationService.getSummary error: $e');
      return NotificationSummary(total: 0, unread: 0, hasUnread: false);
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      
      // Update local state
      final currentList = notifications.value;
      final index = currentList.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !currentList[index].isRead) {
        final updatedList = List<NotificationModel>.from(currentList);
        final old = updatedList[index];
        updatedList[index] = NotificationModel(
          id: old.id,
          userId: old.userId,
          type: old.type,
          title: old.title,
          message: old.message,
          payload: old.payload,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: old.createdAt,
        );
        notifications.value = updatedList;
        
        if (unreadCount.value > 0) {
          unreadCount.value = unreadCount.value - 1;
        }
      }
    } catch (e) {
      debugPrint('NotificationService.markAsRead error: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      
      // Update local state
      final currentList = notifications.value;
      final updatedList = currentList.map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        type: n.type,
        title: n.title,
        message: n.message,
        payload: n.payload,
        isRead: true,
        readAt: DateTime.now(),
        createdAt: n.createdAt,
      )).toList();
      notifications.value = updatedList;
      unreadCount.value = 0;
    } catch (e) {
      debugPrint('NotificationService.markAllAsRead error: $e');
    }
  }

  /// Update push notification token
  Future<void> updatePushToken(String token) async {
    try {
      await _repository.updatePushToken(token);
    } catch (e) {
      debugPrint('NotificationService.updatePushToken error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicRefresh();
    notifications.dispose();
    unreadCount.dispose();
  }
}

/// Global notification service instance
final notificationService = NotificationService();
