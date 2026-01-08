import 'package:flutter/material.dart';

import '../Utils.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget{
  late String title = "";
  AppBarComponent(String title){
    this.title = title;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      title: Text(this.title, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
      actions: [
        Text("hello ${Utils.userName}", style: TextStyle(color: Colors.white, fontSize: 20)),
        SizedBox(width: 20,)
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}