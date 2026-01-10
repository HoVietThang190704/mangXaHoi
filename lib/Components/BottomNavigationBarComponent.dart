import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

import '../Utils.dart';

class BottomNavigationBarComponent extends StatelessWidget{
  void tabItemClick(int value){
      if (value == Utils.selectIndex) {
        return;
      }
      Utils.selectIndex = value;
      BuildContext context = Utils.navigatorKey.currentContext!;
      if( value == 0){
        Navigator.pushNamed(context, '/home');
      }
      if(value == 1){
        Navigator.pushNamed(context, '/myprofile');
      }
      if(value == 2){
        Navigator.pushNamed(context, '/chat');
      }

      if(value == 3){

        Navigator.pushNamed(context, '/setting');
      }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BottomNavigationBar(
      onTap: (value) {
        return tabItemClick(value);
      },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        currentIndex: Utils.selectIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle,),label: "My Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.chat,),label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.settings,),label: "Setting"),
        ]);
  }

}

class _NavItem extends StatelessWidget{
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  _NavItem({required this.icon, required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? color : Colors.grey[600]),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: active ? color : Colors.grey[600])),
            SizedBox(height: 6),
            if(active) Container(width: 28, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))
          ],
        ),
      ),
    );
  }
}