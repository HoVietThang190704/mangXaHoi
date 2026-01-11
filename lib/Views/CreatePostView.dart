import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostView extends StatefulWidget {
  @override
  _CreatePostViewState createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  static const int _maxImages = 10;
  static const int _maxVideos = 2;

  final TextEditingController _controller = TextEditingController();
  final FeedService _feedService = FeedService();
  String _privacy = 'public';
  bool _posting = false;
  final List<XFile> _media = [];
  final ImagePicker _picker = ImagePicker();

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isVideoFile(XFile file) {
    final mime = file.mimeType;
    if (mime != null) {
      return mime.toLowerCase().startsWith('video/');
    }
    final lowerPath = file.path.toLowerCase();
    const videoExts = ['.mp4', '.mov', '.m4v', '.avi', '.wmv', '.flv', '.mkv', '.3gp'];
    return videoExts.any((ext) => lowerPath.endsWith(ext));
  }

  Future<void> _pickImages() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final imgs = await _picker.pickMultiImage();
      if (imgs == null || imgs.isEmpty) return;

      final currentImages = _media.where((file) => !_isVideoFile(file)).length;
      if (currentImages >= _maxImages) {
        _showSnack(loc.create_post_image_limit(_maxImages));
        return;
      }

      final availableSlots = _maxImages - currentImages;
      final toAdd = imgs.take(availableSlots).toList();
      if (toAdd.isEmpty) {
        _showSnack(loc.create_post_image_limit(_maxImages));
        return;
      }

      setState(() => _media.addAll(toAdd));

      if (toAdd.length < imgs.length) {
        _showSnack(loc.create_post_image_limit(_maxImages));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.create_post_error)));
    }
  }

  Future<void> _pickVideo() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final currentVideos = _media.where(_isVideoFile).length;
      if (currentVideos >= _maxVideos) {
        _showSnack(loc.create_post_video_limit(_maxVideos));
        return;
      }

      final video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() => _media.add(video));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.create_post_error)));
    }
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    final content = _controller.text.trim();
    final imagePaths = _media.where((file) => !_isVideoFile(file)).map((file) => file.path).toList();
    final videoPaths = _media.where(_isVideoFile).map((file) => file.path).toList();

    if (content.isEmpty && imagePaths.isEmpty && videoPaths.isEmpty) {
      _showSnack(loc.create_post_require_media);
      return;
    }

    setState(() => _posting = true);

    if (Utils.accessToken == null || Utils.accessToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.login_first ?? 'Please login to post')));
      setState(() => _posting = false);
      Navigator.of(context).pushNamed('/login');
      return;
    }

    try {
      final payload = <String, dynamic>{
        'content': content,
        'visibility': _privacy,
      };

      if (imagePaths.isNotEmpty) {
        payload['images'] = imagePaths;
      }

      if (videoPaths.isNotEmpty) {
        payload['videos'] = videoPaths;
      }

      final post = await _feedService.createPost(payload);
      if (!mounted) return;
      Navigator.of(context).pop(post);
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.create_post_error}: $message')));
      debugPrint('_submit error: $e');
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = Utils.currentUser;
    final avatarUrl = user?.avatar?.trim();
    final hasAvatar = avatarUrl?.isNotEmpty ?? false;
    final placeholderInitial = (user?.userName?.isNotEmpty ?? false)
      ? user!.userName!.trim()[0].toUpperCase()
      : (user?.email?.isNotEmpty ?? false)
        ? user!.email!.trim()[0].toUpperCase()
        : null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(loc.create_post_title),
        leading: BackButton(),
        actions: [
          TextButton(
            onPressed: _posting ? null : _submit,
            child: _posting ? SizedBox(width:40, height: 16, child: LinearProgressIndicator()) : Text(loc.post, style: TextStyle(color: Theme.of(context).primaryColor)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomPadding + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
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
                title: Text(Utils.currentUser?.userName ?? Utils.userName ?? ''),
                subtitle: GestureDetector(
                  onTap: () async {
                    final sel = await showModalBottomSheet<String>(
                      context: context,
                      builder: (ctx) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(title: Text(loc.privacy_public), onTap: () => Navigator.of(ctx).pop('public')),
                              ListTile(title: Text(loc.privacy_friends), onTap: () => Navigator.of(ctx).pop('friends')),
                              ListTile(title: Text(loc.privacy_private), onTap: () => Navigator.of(ctx).pop('private')),
                            ],
                          ),
                        );
                      },
                    );
                    if (sel != null) setState(() => _privacy = sel);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.public, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _privacy == 'public'
                            ? loc.privacy_public
                            : _privacy == 'friends'
                                ? loc.privacy_friends
                                : loc.privacy_private,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 160),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 6,
                    decoration: InputDecoration(
                      hintText: loc.create_post_hint,
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
              ),
              if (_media.isNotEmpty)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _media.length,
                    itemBuilder: (ctx, i) {
                      final file = File(_media[i].path);
                      final isVideo = _isVideoFile(_media[i]);
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            height: 100,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                            child: isVideo
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.videocam, size: 36, color: Colors.deepPurple),
                                        SizedBox(height: 6),
                                        Text(
                                          'Video',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  )
                                : Image.file(file, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() => _media.removeAt(i));
                              },
                              child: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 14)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.image), onPressed: _pickImages),
                    IconButton(icon: const Icon(Icons.videocam), onPressed: _pickVideo),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _ActionItem(icon: Icons.image, label: loc.photo, onTap: _pickImages),
                    _ActionItem(icon: Icons.videocam, label: loc.video, onTap: _pickVideo),
                    _ActionItem(icon: Icons.person_add_alt_1, label: loc.tag_people, onTap: () {}),
                    _ActionItem(icon: Icons.place, label: loc.add_location, onTap: () {}),
                    _ActionItem(icon: Icons.emoji_emotions, label: loc.feeling_activity, onTap: () {}),
                    _ActionItem(icon: Icons.event, label: loc.create_event, onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget{
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _ActionItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context){
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      onTap: onTap,
    );
  }
}
