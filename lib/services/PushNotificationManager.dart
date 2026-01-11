import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mangxahoi/Service/NotificationService.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/Views/Profile/UserProfileView.dart';
import 'package:mangxahoi/Views/Chat/ChatDetailView.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void _backgroundNotificationListener(Map<String, dynamic> data) {
  debugPrint('PushNotificationManager: Background notification - $data');

  try {
    PushNotificationManager.instance._handleNotification(data);
  } catch (e, stackTrace) {
    debugPrint('PushNotificationManager: Background handler failed - $e');
    debugPrint('PushNotificationManager: Background handler stack trace - $stackTrace');

    final title = data['title']?.toString() ?? 'Notification';
    final message = data['message']?.toString() ?? data['body']?.toString() ?? '';
    Pushy.notify(title, message, data);
  }
}

class PushNotificationManager {
  PushNotificationManager._();
  static final PushNotificationManager instance = PushNotificationManager._();

  String? _deviceToken;
  bool _isInitialized = false;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? get deviceToken => _deviceToken;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    debugPrint('PushNotificationManager: initialize() called, _isInitialized=$_isInitialized');
    
    if (_isInitialized && _deviceToken != null) {
      debugPrint('PushNotificationManager: Already initialized, re-registering token with server...');
      await _registerTokenWithServer(_deviceToken!);
      return;
    }

    try {
      if (Platform.isAndroid) {
        try {
          final status = await Permission.notification.request();
          debugPrint('PushNotificationManager: Notification permission status: $status');
          if (!status.isGranted) {
            debugPrint('PushNotificationManager: Notification permission not granted');
          }
        } catch (e) {
          debugPrint('PushNotificationManager: Notification permission request failed - $e');
        }
      }

      await _initLocalNotifications();

      // Register with Pushy
      debugPrint('PushNotificationManager: Registering with Pushy...');
      final deviceToken = await Pushy.register();
      _deviceToken = deviceToken;
      debugPrint('PushNotificationManager: Device token - $deviceToken');

      Pushy.listen();

      await _registerTokenWithServer(deviceToken);

      // Use the top-level background-safe listener so notifications also work when the app is killed
      Pushy.setNotificationListener(_backgroundNotificationListener);
      Pushy.setNotificationClickListener(_handleNotificationClick);


      _isInitialized = true;
      debugPrint('PushNotificationManager: Initialized successfully');
    } catch (e) {
      debugPrint('PushNotificationManager: Failed to initialize - $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          _handleNotificationTap(payload);
        }
      },
    );


    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'friend_requests', 
        'Friend Requests',
        description: 'Notifications for friend requests and social activities',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      debugPrint('PushNotificationManager: Android notification channel created');
    }
  }

  Future<void> _registerTokenWithServer(String token) async {
    try {
      debugPrint('PushNotificationManager: Registering token with server...');
      debugPrint('PushNotificationManager: Token to register: ${token.substring(0, 20)}...');
      debugPrint('PushNotificationManager: Access token available: ${Utils.accessToken != null}');
      
      if (Utils.accessToken == null) {
        debugPrint('PushNotificationManager: ERROR - No access token available!');
        return;
      }
      
      await notificationService.updatePushToken(token);
      debugPrint('PushNotificationManager: Token registered with server successfully');
    } catch (e, stackTrace) {
      debugPrint('PushNotificationManager: Failed to register token - $e');
      debugPrint('PushNotificationManager: Stack trace - $stackTrace');
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    debugPrint('PushNotificationManager: Received notification - $data');
    notificationService.refreshNotifications();
    final title = data['title']?.toString() ?? 'Notification';
    final message = data['message']?.toString() ?? data['body']?.toString() ?? '';
    final type = data['type']?.toString() ?? '';
    final senderId = data['senderId']?.toString() ?? '';
    final commenterId = data['commenterId']?.toString() ?? '';
    final replierId = data['replierId']?.toString() ?? '';
    final threadId = data['threadId']?.toString() ?? '';
    final postId = data['postId']?.toString() ?? '';
    final commentId = data['commentId']?.toString() ?? '';
    
    _showLocalNotification(
      title: title,
      body: message,
      payload: '$type|$senderId|$commenterId|$replierId|$threadId|$postId|$commentId',
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('PushNotificationManager: Showing local notification - title: $title, body: $body');
    
    const androidDetails = AndroidNotificationDetails(
      'friend_requests',
      'Friend Requests',
      channelDescription: 'Notifications for friend requests and social activities',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
    
    debugPrint('PushNotificationManager: Local notification shown successfully');
  }

  void _handleNotificationTap(String payload) {
    final parts = payload.split('|');
    if (parts.isEmpty) return;
    
    final type = parts[0];
    final senderId = parts.length > 1 ? parts[1] : '';
    final commenterId = parts.length > 2 ? parts[2] : '';
    final replierId = parts.length > 3 ? parts[3] : '';
    final threadId = parts.length > 4 ? parts[4] : '';
    final postId = parts.length > 5 ? parts[5] : '';
    // final commentId = parts.length > 6 ? parts[6] : '';
    
    if ((type == 'friend_request' || type == 'friend_request_accepted') && senderId.isNotEmpty) {
      _navigateToUserProfile(senderId);
    } else if (type == 'new_message' && senderId.isNotEmpty) {
      _navigateToChat(senderId: senderId, threadId: threadId);
    } else if (type == 'comment' && commenterId.isNotEmpty) {
      _navigateToUserProfile(commenterId);
    } else if (type == 'comment_reply' && replierId.isNotEmpty) {
      _navigateToUserProfile(replierId);
    } else if (postId.isNotEmpty) {
      _navigateToPost(postId: postId);
    }
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    debugPrint('PushNotificationManager: Notification clicked - $data');
    
    final type = data['type']?.toString();
    final senderId = data['senderId']?.toString();
    final userId = data['userId']?.toString();
    final threadId = data['threadId']?.toString();
    final postId = data['postId']?.toString();
    final commenterId = data['commenterId']?.toString();
    final replierId = data['replierId']?.toString();
    
    if (type == 'friend_request' && senderId != null && senderId.isNotEmpty) {
      _navigateToUserProfile(senderId);
    } else if (type == 'friend_request_accepted' && userId != null && userId.isNotEmpty) {
      _navigateToUserProfile(userId);
    } else if (type == 'new_message' && senderId != null && senderId.isNotEmpty) {
      _navigateToChat(senderId: senderId, threadId: threadId);
    } else if (type == 'comment' && commenterId != null && commenterId.isNotEmpty) {
      _navigateToUserProfile(commenterId);
    } else if (type == 'comment_reply' && replierId != null && replierId.isNotEmpty) {
      _navigateToUserProfile(replierId);
    } else if (postId != null && postId.isNotEmpty) {
      _navigateToPost(postId: postId);
    }
  }

  void _navigateToUserProfile(String userId) {
    final navigator = Utils.navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed(
        '/profile/user',
        arguments: UserProfileArguments(userId: userId),
      );
    }
  }

  void _navigateToChat({required String senderId, String? threadId}) {
    final navigator = Utils.navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatDetailView(
            targetUserId: senderId,
          ),
        ),
      );
    }
  }

  void _navigateToPost({required String postId}) {
   final navigator = Utils.navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed('/notifications');
    }
  }

  Future<void> updateToken(String token) async {
    _deviceToken = token;
    await _registerTokenWithServer(token);
  }

  Future<void> clearToken() async {
    _deviceToken = null;
    _isInitialized = false;
    debugPrint('PushNotificationManager: Token cleared, will re-initialize on next login');
  }
}

final pushNotificationManager = PushNotificationManager.instance;
