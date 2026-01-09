import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/PostModel.dart';
import '../Utils.dart';

Future<void> showPostShareSheet(BuildContext context, PostModel post) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => PostShareSheet(post: post),
  );
}

class PostShareSheet extends StatelessWidget {
  final PostModel post;
  const PostShareSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareLink = _buildShareLink();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Chia sẻ bài viết', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                shareLink,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.link, color: theme.primaryColor),
                ),
                title: const Text('Sao chép đường link'),
                subtitle: const Text('Nhanh chóng gửi cho bạn bè'),
                onTap: () => _copyLink(context, shareLink),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ShareChip(
                      label: 'Zalo',
                      color: const Color(0xFF0068FF),
                      icon: Icons.chat_bubble_outline,
                      onTap: () => _openShareTarget(context, _zaloShareUri(shareLink)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShareChip(
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      icon: Icons.facebook,
                      onTap: () => _openShareTarget(context, _facebookShareUri(shareLink)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildShareLink() {
    final base = Utils.baseUrl.endsWith('/') ? Utils.baseUrl.substring(0, Utils.baseUrl.length - 1) : Utils.baseUrl;
    return '$base/posts/${post.id}';
  }

  Future<void> _copyLink(BuildContext context, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép đường link')));
  }

  Future<void> _openShareTarget(BuildContext context, Uri uri) async {
    Navigator.of(context).pop();
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không mở được ứng dụng chia sẻ')));
    }
  }

  Uri _facebookShareUri(String link) {
    return Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}');
  }

  Uri _zaloShareUri(String link) {
    return Uri.parse('https://zalo.me/share?url=${Uri.encodeComponent(link)}');
  }
}

class _ShareChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShareChip({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
