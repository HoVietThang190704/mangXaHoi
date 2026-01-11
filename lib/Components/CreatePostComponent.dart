import 'package:flutter/material.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class CreatePostComponent extends StatelessWidget{
  final void Function(String content)? onPost;
  final ValueChanged<dynamic>? onCreated;
  CreatePostComponent({this.onPost, this.onCreated});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hint = loc.create_post_hint;
    final title = loc.create_post_title;
    final cancel = loc.cancel;
    final postLabel = loc.post;
    final user = Utils.currentUser;
    final avatarUrl = user?.avatar?.trim();
    final hasAvatar = avatarUrl?.isNotEmpty ?? false;
    final placeholderInitial = (user?.userName?.isNotEmpty ?? false)
        ? user!.userName!.trim()[0].toUpperCase()
        : (user?.email?.isNotEmpty ?? false)
            ? user!.email!.trim()[0].toUpperCase()
            : null;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
              child: hasAvatar
                  ? null
                  : (placeholderInitial != null
                      ? Text(
                          placeholderInitial,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        )
                      : const Icon(Icons.person, color: Color(0xFF9CA3AF))),
            ),
            SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final created = await Navigator.of(context).pushNamed('/createPost');
                  if (created != null) {
                    if (onCreated != null) {
                      onCreated!(created);
                      return;
                    }

                    if (created is String && created.trim().isNotEmpty) {
                      onPost?.call(created);
                      return;
                    }
                  }

                  final content = await showDialog<String>(context: context, builder: (ctx) {
                    String tmp = '';
                    return AlertDialog(
                      title: Text(title),
                      content: TextField(
                        autofocus: true,
                        onChanged: (v) => tmp = v,
                        decoration: InputDecoration(hintText: hint),
                        maxLines: 4,
                      ),
                      actions: [
                        TextButton(onPressed: (){ Navigator.of(ctx).pop(); }, child: Text(cancel)),
                        TextButton(onPressed: (){ Navigator.of(ctx).pop(tmp); }, child: Text(postLabel)),
                      ],
                    );
                  });
                  if(content != null && content.trim().isNotEmpty){
                    onPost?.call(content);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(AppLocalizations.of(context)!.create_post_hint, style: TextStyle(color: Colors.grey[700])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
