import 'package:mangxahoi/Service/SessionService.dart';
import 'package:mangxahoi/Views/Auth/LoginView.dart';
import 'package:mangxahoi/Views/Auth/RegisterView.dart';
import 'package:mangxahoi/Views/CreatePostView.dart';
import 'package:mangxahoi/Views/Profile/UserProfileView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Views/SearchView.dart';
import 'package:mangxahoi/Views/Profile/FriendsListView.dart';
import 'package:mangxahoi/Views/Settings/EditProfileView.dart';
import 'package:mangxahoi/Views/Settings/FeedbackView.dart';
import 'package:mangxahoi/Views/Settings/LanguageSettingsView.dart';
import 'package:mangxahoi/Views/Settings/SecuritySettingsView.dart';
import 'package:mangxahoi/Views/MainShell.dart';
import 'Utils.dart';
import 'Views/Chat/ChatViewArguments.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugPaintPointersEnabled = false;
    return true;
  }());

  await Utils.loadSavedLocale();

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
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
              },
            ),
          ),
          initialRoute: initialRoute,
          routes: {
            '/': (context) => LoginView(),
            '/home': (context) => const MainShell(initialIndex: 0),
            '/chat': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              ChatViewArguments? chatArgs;
              if (args is ChatViewArguments) {
                chatArgs = args;
              } else if (args is Map) {
                chatArgs = ChatViewArguments(
                  userId: args['userId']?.toString(),
                  displayName: args['displayName']?.toString(),
                  avatar: args['avatar']?.toString(),
                );
              }
              return MainShell(initialIndex: 2, chatArgs: chatArgs);
            },
            '/myprofile': (context) => const MainShell(initialIndex: 1),
            '/profile/user': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is UserProfileArguments) {
                return UserProfileView(userId: args.userId, initialUser: args.initialUser);
              }
              if (args is String && args.isNotEmpty) {
                return UserProfileView(userId: args);
              }
              return const Scaffold(
                body: Center(child: Text('User not found')),
              );
            },
            '/profile/friends': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is FriendsListArguments) {
                return FriendsListView(args: args);
              }
              if (args is Map && args['userId'] != null) {
                return FriendsListView(args: FriendsListArguments(userId: args['userId'].toString(), title: args['title']?.toString()));
              }
              return const Scaffold(body: Center(child: Text('No user specified')));
            },
            '/notifications': (context) => const MainShell(initialIndex: 3),
            '/setting': (context) => const MainShell(initialIndex: 4),
            //'/myprofile': (context) => EditProfileView(),
            '/settings/profile': (context) => EditProfileView(),
            '/settings/security': (context) => SecuritySettingsView(),
            '/settings/feedback': (context) => FeedbackView(),
            '/settings/language': (context) => LanguageSettingsView(),
            '/createPost': (context) => CreatePostView(),
            '/register': (context) => RegisterView(),
            '/search': (context) => SearchView(),
          },
        );
      },
    );
  }
}



