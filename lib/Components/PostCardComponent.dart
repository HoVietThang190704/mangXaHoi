import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'PostShareSheet.dart';
import '../Model/PostModel.dart';

class PostCardComponent extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostCardComponent({super.key, required this.post, this.onLike, this.onComment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final primaryText = post.author.userName ?? post.author.email ?? loc.unknown;
    final avatarLabel = primaryText.isNotEmpty ? primaryText[0].toUpperCase() : '?';
    final timestamp = _formatTimestamp(post.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, avatarLabel, primaryText, timestamp),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                post.content,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) _buildMediaPreview(context),
          _buildStatsRow(context),
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          _buildActionRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String avatarLabel, String primaryText, String timestamp) {
    final theme = Theme.of(context);
    final avatarUrl = (post.author.avatar?.trim().isNotEmpty ?? false) ? post.author.avatar!.trim() : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.primaryColor.withOpacity(0.15),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(avatarLabel, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        primaryText,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Color(0xFF1D72F2), size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timestamp,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: CircleAvatar(radius: 2, backgroundColor: Colors.grey[400]),
                    ),
                    Icon(Icons.public, size: 14, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context) {
    return GestureDetector(
      onTap: onComment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            post.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                alignment: Alignment.center,
                color: Colors.grey[200],
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _reactionBubble(Colors.blue, Icons.thumb_up, 0),
                _reactionBubble(Colors.redAccent, Icons.favorite, 18),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${post.likes}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            '${post.comments} ${loc.comments.toLowerCase()}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _actionButton(
            context,
            icon: post.isLiked ? Icons.favorite : Icons.thumb_up_alt_outlined,
            label: post.isLiked ? 'Liked' : 'Like',
            color: post.isLiked ? theme.primaryColor : Colors.grey[700],
            onTap: onLike,
          ),
          _actionButton(
            context,
            icon: Icons.mode_comment_outlined,
            label: 'Comment',
            onTap: onComment,
          ),
          _actionButton(
            context,
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => showPostShareSheet(context, post),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color ?? Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(color: color ?? Colors.grey[800], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned _reactionBubble(Color color, IconData icon, double leftOffset) {
    return Positioned(
      left: leftOffset,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    if (difference.inDays <= 7) {
      return '${difference.inDays}d';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
