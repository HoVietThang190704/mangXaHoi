import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class CreatePostComponent extends StatelessWidget{
  final void Function(String content)? onPost;
  CreatePostComponent({this.onPost});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hint = loc.create_post_hint;
    final title = loc.create_post_title;
    final cancel = loc.cancel;
    final postLabel = loc.post;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(child: Icon(Icons.person)),
            SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () async {
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
