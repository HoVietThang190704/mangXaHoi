import 'dart:convert';

import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/services/PushNotificationManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService._();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';

  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final userJson = prefs.getString(_userKey);
    if (accessToken == null || userJson == null) {
      return false;
    }

    try {
      final dynamic decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid session user data');
      }
      final user = AuthUserModel.fromJson(decoded);
      Utils.currentUser = user;
      Utils.userName = user.userName ?? user.email;
      Utils.accessToken = accessToken;
      Utils.refreshToken = prefs.getString(_refreshTokenKey);
      
      // Initialize push notifications after session restore
      await PushNotificationManager.instance.initialize();
      
      return true;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  static Future<void> storeSession({
    required String accessToken,
    String? refreshToken,
    required AuthUserModel user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Utils.accessToken = accessToken;
    Utils.refreshToken = refreshToken;
    Utils.currentUser = user;
    Utils.userName = user.userName ?? user.email;

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      await prefs.remove(_refreshTokenKey);
    }
    
    // Initialize push notifications after login
    await PushNotificationManager.instance.initialize();
  }

  static Future<void> updateUser(AuthUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    Utils.currentUser = user;
    Utils.userName = user.userName ?? user.email;
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> clearSession() async {
    // Clear push notification token first (before clearing access token)
    await PushNotificationManager.instance.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    Utils.accessToken = null;
    Utils.refreshToken = null;
    Utils.currentUser = null;
    Utils.userName = '';
  }
}
