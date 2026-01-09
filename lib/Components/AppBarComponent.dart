import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarComponent(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Text(
            "Localhost",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.add, color: Colors.black87),
          tooltip: 'Tạo bài viết',
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/search'),
          icon: Icon(Icons.search, color: Colors.black87),
          tooltip: l10n?.search_title ?? 'Tìm kiếm',
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.chat, color: Colors.black87),
          tooltip: 'Chat',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}