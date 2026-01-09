import 'package:mangxahoi/Views/ChatView.dart';
import 'package:mangxahoi/Views/HomeView.dart';
import 'package:mangxahoi/Service/SessionService.dart';
import 'package:mangxahoi/Views/Auth/LoginView.dart';
import 'package:mangxahoi/Views/Auth/RegisterView.dart';
import 'package:mangxahoi/Views/CreatePostView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Views/SearchView.dart';

import 'Utils.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure debug paint overlays are disabled by default in debug builds
  assert(() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugPaintPointersEnabled = false;
    return true;
  }());

  final bool autoLogin = await SessionService.restoreSession();
  runApp(MyApp(initialRoute: autoLogin ? '/home' : '/'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: Utils.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: Utils.navigatorKey,
          title: "My app",
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: initialRoute,
          routes: {
            '/': (context) => LoginView(),
            '/home': (context) => HomeView(),
            '/chat': (context) => ChatView(),
            '/createPost': (context) => CreatePostView(),
            '/register': (context) => RegisterView(),
            '/search': (context) => SearchView(),
          },

        );
      },
    );
  }
}



