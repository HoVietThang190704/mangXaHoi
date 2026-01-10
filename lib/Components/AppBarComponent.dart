import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Views/CreatePostView.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function(dynamic createdPost)? onPostCreated;

  const AppBarComponent(this.title, {super.key, this.onPostCreated});

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
          onPressed: () async {
            final created = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CreatePostView()));
            if (created != null) {
              onPostCreated?.call(created);
            }
          },
          icon: Icon(Icons.add, color: Colors.black87),
          tooltip: l10n?.create_post_title ?? 'Tạo bài viết',
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