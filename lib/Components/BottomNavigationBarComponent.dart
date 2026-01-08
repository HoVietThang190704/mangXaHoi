import 'package:flutter/material.dart';

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
    // TODO: implement build
    return BottomNavigationBar(
      onTap: (value) {
        return tabItemClick(value);
      },
        backgroundColor: Colors.green,
        selectedItemColor: Colors.orange,
        currentIndex: Utils.selectIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_card,),label: "Product"),
          BottomNavigationBarItem(icon: Icon(Icons.chat,),label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.adb,),label: "DT"),
        ]);
  }

}