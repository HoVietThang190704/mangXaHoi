import 'package:mangxahoi/Views/ChatView.dart';
import 'package:mangxahoi/Views/HomeView.dart';
import 'package:mangxahoi/Views/Auth/LoginView.dart';
import 'package:mangxahoi/Views/Auth/RegisterView.dart';
import 'package:mangxahoi/Views/ProductView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

import 'Utils.dart';
import 'Views/ProductDetailView.dart';


void main() {
  // Ensure debug paint overlays are disabled by default in debug builds
  assert(() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugPaintPointersEnabled = false;
    return true;
  }());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: Utils.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: Utils.navigatorKey,
          title: "My app",
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          routes: {
            '/': (context) => LoginView(),
            '/home': (context) => HomeView(),
            '/chat': (context) => ChatView(),
            '/product': (context) => ProductView(),
            '/productDetail': (context) {
              var args = ModalRoute.of(context)!.settings.arguments as Map;
              return ProductDetailView((args["Id"] as int));
            },
            '/register': (context) => RegisterView(),
          },
        );
      },
    );
  }
}



