import 'package:flutter/material.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';

class Utils{
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String userName = "";
  static int selectIndex = 0;
  // Sử dụng 10.0.2.2 cho Android Emulator (đây là localhost từ emulator)
  // Nếu dùng điện thoại thật, đổi thành IP máy: http://192.168.1.32:5000
  static String baseUrl = "http://10.0.2.2:5000";
  static String slideUrl = "/api/Product/get-slide-product";
  static String allProductUrl = "/api/Product/get-all-product";
  static AuthUserModel? currentUser;
  static String? accessToken;
  static String? refreshToken;

  // Locale ValueNotifier used by the app to update language at runtime
  static ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static void setLocale(Locale? l) {
    locale.value = l;
  }
}
