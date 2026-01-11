import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/Views/ChatView.dart';
import 'package:mangxahoi/Views/HomeView.dart';
import 'package:mangxahoi/Views/NotificationView.dart';
import 'package:mangxahoi/Views/Profile/MyProfileView.dart';
import 'package:mangxahoi/Views/Settings/SettingsHomeView.dart';
import 'package:mangxahoi/Views/Chat/ChatViewArguments.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  final ChatViewArguments? chatArgs;

  const MainShell({super.key, this.initialIndex = 0, this.chatArgs});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex = widget.initialIndex.clamp(0, 4);
  late final List<Widget> _pages = [
    const HomeView(),
    const MyProfileView(),
    ChatView(initialArgs: widget.chatArgs),
    const NotificationView(),
    const SettingsHomeView(),
  ];

  @override
  void initState() {
    super.initState();
    Utils.selectIndex = _currentIndex;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      Utils.selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Stack(
          key: ValueKey(_currentIndex),
          children: List.generate(_pages.length, (index) {
            final active = index == _currentIndex;
            return Offstage(
              offstage: !active,
              child: TickerMode(
                enabled: active,
                child: _pages[index],
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarComponent(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
