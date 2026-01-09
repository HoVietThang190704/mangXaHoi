import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Model/CommentModel.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Service/CommentService.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Utils.dart';

class PostDetailView extends StatefulWidget {
  final PostModel post;

  const PostDetailView({super.key, required this.post});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final CommentService _commentService = CommentService();
  final FeedService _feedService = FeedService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  late PostModel _post;
  List<CommentModel> _comments = [];
  bool _loadingComments = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  bool _sending = false;
  CommentModel? _replyTo;
  final Set<String> _deleting = {};

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadPost();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
      _loadComments(loadMore: true);
    }
  }

  Future<void> _loadPost() async {
    try {
      final latest = await _feedService.getPostById(_post.id);
      if (!mounted) return;
      setState(() => _post = latest);
    } catch (_) {
    }
  }

  Future<void> _loadComments({bool loadMore = false}) async {
    if (_loadingComments) return;
    setState(() => loadMore ? _loadingMore = true : _loadingComments = true);

    final nextPage = loadMore ? _page + 1 : 1;
    try {
      final page = await _commentService.fetchComments(_post.id, page: nextPage, limit: 20);
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _hasMore = page.hasMore;
        if (loadMore) {
          _comments.addAll(page.comments);
        } else {
          _comments = page.comments;
        }
      });
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.comment_load_failed)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingComments = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _handlePostLike() async {
    final previousLiked = _post.isLiked;
    final previousLikes = _post.likes;

    setState(() {
      _post.isLiked = !_post.isLiked;
      _post.likes += _post.isLiked ? 1 : -1;
      if (_post.likes < 0) _post.likes = 0;
    });

    try {
      final result = await _feedService.toggleLike(_post.id);
      if (!mounted) return;
      setState(() {
        _post.isLiked = result['isLiked'] ?? _post.isLiked;
        _post.likes = result['likesCount'] ?? _post.likes;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _post.isLiked = previousLiked;
        _post.likes = previousLikes;
      });
    }
  }

  Future<void> _handleCommentLike(CommentModel comment) async {
    final previousLiked = comment.isLiked;
    final previousLikes = comment.likesCount;

    setState(() {
      comment.isLiked = !comment.isLiked;
      comment.likesCount += comment.isLiked ? 1 : -1;
      if (comment.likesCount < 0) comment.likesCount = 0;
    });

    try {
      final result = await _commentService.toggleLike(comment.id);
      if (!mounted) return;
      setState(() {
        comment.isLiked = result['isLiked'] ?? comment.isLiked;
        comment.likesCount = result['likesCount'] ?? comment.likesCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        comment.isLiked = previousLiked;
        comment.likesCount = previousLikes;
      });
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.comment_like_failed)),
      );
    }
  }

  Future<void> _sendComment() async {
    final loc = AppLocalizations.of(context)!;
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;
    if (_sending) return;

    setState(() => _sending = true);
    try {
      final imagePaths = _selectedImages.map((e) => e.path).toList();
      // Use a placeholder so backend validators accept image-only comments
      final safeContent = text.isEmpty && imagePaths.isNotEmpty ? '[image]' : text;
      CommentModel newComment;
      if (_replyTo != null) {
        newComment = await _commentService.replyTo(
          commentId: _replyTo!.id,
          content: safeContent,
          images: imagePaths.isNotEmpty ? imagePaths : null,
          mentionedUserId: _replyTo!.author.id,
        );
        _insertReply(newComment);
      } else {
        newComment = await _commentService.addComment(
          postId: _post.id,
          content: safeContent,
          images: imagePaths.isNotEmpty ? imagePaths : null,
        );
        setState(() => _comments.insert(0, newComment));
      }

      setState(() {
        _post.comments += 1;
        _replyTo = null;
        _textController.clear();
        _selectedImages.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.comment_action_failed)),
      );
    } finally {
      if (!mounted) return;
      setState(() => _sending = false);
    }
  }

  void _insertReply(CommentModel reply) {
    bool attached = _attachReply(_comments, reply);
    if (!attached) {
      setState(() => _comments.add(reply));
    } else {
      setState(() {});
    }
  }

  int _countSubtree(CommentModel comment) {
    var total = 1;
    for (final r in comment.replies) {
      total += _countSubtree(r);
    }
    return total;
  }

  int _removeCommentAndCount(List<CommentModel> list, String id) {
    for (var i = 0; i < list.length; i++) {
      final c = list[i];
      if (c.id == id) {
        final removed = _countSubtree(c);
        list.removeAt(i);
        return removed;
      }
      final childRemoved = _removeCommentAndCount(c.replies, id);
      if (childRemoved > 0) {
        c.repliesCount = (c.repliesCount - childRemoved).clamp(0, 1 << 30);
        return childRemoved;
      }
    }
    return 0;
  }

  Future<void> _handleDelete(CommentModel comment) async {
    if (_deleting.contains(comment.id)) return;
    setState(() => _deleting.add(comment.id));

    try {
      await _commentService.deleteComment(comment.id);
      final removed = _removeCommentAndCount(_comments, comment.id);
      setState(() {
        _post.comments = (_post.comments - removed).clamp(0, 1 << 30);
      });
    } catch (_) {
      final loc = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.comment_action_failed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deleting.remove(comment.id));
      }
    }
  }

  bool _attachReply(List<CommentModel> list, CommentModel reply) {
    for (final c in list) {
      if (c.id == reply.parentCommentId) {
        c.replies.insert(0, reply);
        c.repliesCount += 1;
        return true;
      }
      if (c.replies.isNotEmpty && _attachReply(c.replies, reply)) {
        return true;
      }
    }
    return false;
  }

  void _startReply(CommentModel comment) {
    if (comment.level >= 2) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.max_reply_depth)),
      );
      return;
    }
    final name = comment.author.userName ?? comment.author.email;
    setState(() {
      _replyTo = comment;
      _textController.text = '@$name ';
      _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
    });
  }

  Future<void> _pickImages() async {
    try {
      final imgs = await _picker.pickMultiImage();
      if (imgs != null && imgs.isNotEmpty) {
        setState(() => _selectedImages.addAll(imgs));
      }
    } catch (_) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.comment_action_failed)),
      );
    }
  }

  void _removeSelectedImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() => _selectedImages.removeAt(index));
  }

  void _openImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays <= 7) return '${difference.inDays}d';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildComment(CommentModel comment) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final currentUserId = Utils.currentUser?.id;
    final name = comment.author.userName ?? comment.author.email;
    final avatarUrl = (comment.author.avatar?.trim().isNotEmpty ?? false) ? comment.author.avatar!.trim() : null;
    final avatarLabel = name.isNotEmpty ? name[0].toUpperCase() : '?';

    String displayContent = comment.content;
    final mentionName = comment.mentionedUser?.userName ?? comment.mentionedUser?.email;
    final mentionSpanNeeded = mentionName != null && mentionName.isNotEmpty;

    if (mentionSpanNeeded) {
      final prefix = RegExp('^@?${RegExp.escape(mentionName)}\\s*', caseSensitive: false);
      displayContent = displayContent.replaceFirst(prefix, '').trimLeft();
    }

    return Padding(
      padding: EdgeInsets.only(left: 12.0 + comment.level * 16, right: 12, top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.primaryColor.withOpacity(0.15),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(avatarLabel, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(_formatTimestamp(comment.createdAt), style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[900], height: 1.3),
                        children: [
                          if (mentionSpanNeeded)
                            TextSpan(
                              text: '@$mentionName ',
                              style: const TextStyle(color: Color(0xFF1D72F2), fontWeight: FontWeight.w600),
                            ),
                          TextSpan(text: displayContent),
                        ],
                      ),
                    ),
                    if (comment.images.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: comment.images
                            .map(
                              (url) => GestureDetector(
                                onTap: () => _openImage(url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _handleCommentLike(comment),
                          child: Row(
                            children: [
                              Icon(
                                comment.isLiked ? Icons.favorite : Icons.thumb_up_alt_outlined,
                                size: 16,
                                color: comment.isLiked ? theme.primaryColor : Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text('${comment.likesCount} ${loc.comment_like.toLowerCase()}', style: theme.textTheme.labelMedium),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: comment.level >= 2 ? null : () => _startReply(comment),
                          child: Row(
                            children: [
                              const Icon(Icons.reply, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                loc.comment_reply,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: comment.level >= 2 ? Colors.grey : theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (currentUserId != null && currentUserId == comment.author.id) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _deleting.contains(comment.id) ? null : () => _handleDelete(comment),
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 16, color: _deleting.contains(comment.id) ? Colors.grey : Colors.redAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'Xóa',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: _deleting.contains(comment.id) ? Colors.grey : Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            Column(
              children: comment.replies.map(_buildComment).toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_post);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.post_detail_title),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadPost();
                  await _loadComments();
                },
                child: ListView(
                  controller: _scrollController,
                  children: [
                    PostCardComponent(
                      post: _post,
                      onLike: _handlePostLike,
                      onComment: () => FocusScope.of(context).requestFocus(FocusNode()),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Text('${_post.comments} ${loc.comments.toLowerCase()}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    if (_loadingComments && _comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!_loadingComments && _comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(loc.comments_empty)),
                      ),
                    ..._comments.map(_buildComment),
                    if (_loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            if (_replyTo != null)
              Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(loc.replying_to((_replyTo!.author.userName ?? _replyTo!.author.email)),
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800])),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _replyTo = null),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (Utils.currentUser?.avatar?.trim().isNotEmpty ?? false)
                              ? NetworkImage(Utils.currentUser!.avatar!.trim())
                              : null,
                          child: (Utils.currentUser?.avatar?.trim().isNotEmpty ?? false)
                              ? null
                              : Icon(Icons.person, color: Colors.grey[700], size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: loc.comment_input_hint,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.image_outlined),
                          color: theme.primaryColor,
                          onPressed: _pickImages,
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: _sending ? null : _sendComment,
                          style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                          child: _sending
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(loc.send),
                        ),
                      ],
                    ),
                    if (_selectedImages.isNotEmpty)
                      Container(
                        height: 90,
                        margin: const EdgeInsets.only(top: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            final file = File(_selectedImages[index].path);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeSelectedImage(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
