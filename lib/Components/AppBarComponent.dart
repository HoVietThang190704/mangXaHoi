import 'package:flutter/material.dart';

import '../Utils.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  AppBarComponent(this.title);

  @override
  Widget build(BuildContext context) {
    final username = Utils.userName ?? '';
    final initial = username.isNotEmpty ? username[0] : (Utils.currentUser?.userName != null && Utils.currentUser!.userName!.isNotEmpty ? Utils.currentUser!.userName![0] : '?');

    return AppBar(
      backgroundColor: Color(0xFF1877F2),
      elevation: 2,
      title: Row(
        children: [
          Icon(Icons.facebook, size: 28, color: Colors.white),
          SizedBox(width: 8),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: (){
              // TODO: implement search navigation
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search tapped')));
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.message, color: Colors.white),
                onPressed: (){
                  Navigator.pushNamed(context, '/chat');
                },
              ),
            ],
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Text(initial, style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}