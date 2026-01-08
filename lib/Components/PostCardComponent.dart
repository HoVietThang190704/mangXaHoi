import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import '../Model/PostModel.dart';

class PostCardComponent extends StatelessWidget{
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  PostCardComponent({required this.post, this.onLike, this.onComment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text((post.author.userName != null && post.author.userName!.isNotEmpty)
                    ? post.author.userName![0]
                    : (post.author.email != null && post.author.email!.isNotEmpty ? post.author.email![0] : AppLocalizations.of(context)!.unknown[0]))),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author.userName ?? post.author.email ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${post.createdAt.toLocal()}'.split('.')[0], style: TextStyle(fontSize:12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(onPressed: (){}, icon: Icon(Icons.more_horiz))
              ],
            ),
            SizedBox(height: 8),
            Text(post.content),
            if(post.imageUrl != null) ...[
              SizedBox(height:8),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: DecorationImage(image: NetworkImage(post.imageUrl!), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(6),
                ),
              )
            ],
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : null),
                ),
                SizedBox(width:6),
                Text('${post.likes}'),
                Spacer(),
                Text('${post.comments} ' + AppLocalizations.of(context)!.comments, style: TextStyle(color: Colors.grey[600])), 
                SizedBox(width: 8),
                IconButton(onPressed: onComment, icon: Icon(Icons.comment_outlined))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
