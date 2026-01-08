import 'package:flutter/material.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';

class Utils{
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String userName = "";
  static int selectIndex = 0;
  static String baseUrl = "https://longbrushedhen85.conveyor.cloud";
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
