import 'package:flutter/material.dart';
class BottomNavigationBarComponent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarComponent({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle,),label: "My Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.chat,),label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications,), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.settings,),label: "Setting"),
        ]);
  }
}