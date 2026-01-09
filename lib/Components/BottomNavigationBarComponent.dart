import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

import '../Utils.dart';

class BottomNavigationBarComponent extends StatelessWidget{
  void tabItemClick(int value){
      Utils.selectIndex = value;
      BuildContext context = Utils.navigatorKey.currentContext!;
      if( value == 0){
        Navigator.pushNamed(context, '/home');
      }
      if(value == 1){
        Navigator.pushNamed(context, '/product');
      }
      if(value == 2){
        Navigator.pushNamed(context, '/chat');
      }

      if(value == 3){

        Navigator.pushNamed(context, '/productDetail');
      }
  }
  @override
  Widget build(BuildContext context) {
    final selected = Utils.selectIndex;
    final Color active = Color(0xFF1877F2); 

    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.home, label: AppLocalizations.of(context)!.home, active: selected == 0, color: active, onTap: ()=> tabItemClick(0)),
                  _NavItem(icon: Icons.storefront, label: AppLocalizations.of(context)!.product, active: selected == 1, color: active, onTap: ()=> tabItemClick(1)),
                  SizedBox(width: 56), 
                  _NavItem(icon: Icons.chat_bubble_outline, label: AppLocalizations.of(context)!.chat, active: selected == 2, color: active, onTap: ()=> tabItemClick(2)),
                  _NavItem(icon: Icons.adb, label: AppLocalizations.of(context)!.dt, active: selected == 3, color: active, onTap: ()=> tabItemClick(3)),
                ],
              ),
            ),
          ),
          Positioned(
            top: -14,
            child: SizedBox(
              width: 72,
              height: 72,
              child: FloatingActionButton(
                onPressed: () async {
                  final ctx = Utils.navigatorKey.currentContext!;
                  final res = await Navigator.pushNamed(ctx, '/createPost');
                  if(res != null){
                    Navigator.pushNamed(ctx, '/home');
                  }
                },
                backgroundColor: active,
                child: Icon(Icons.add, size: 32),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
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