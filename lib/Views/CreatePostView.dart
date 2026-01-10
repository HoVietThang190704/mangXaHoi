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
  final TextEditingController _controller = TextEditingController();
  final FeedService _feedService = FeedService();
  String _privacy = 'public';
  bool _posting = false;
  final List<XFile> _media = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async{
    try{
      final imgs = await _picker.pickMultiImage();
      if(imgs != null && imgs.isNotEmpty){
        setState(()=> _media.addAll(imgs));
      }
    }catch(e){
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.create_post_error)));
    }
  }

  Future<void> _pickVideo() async{
    try{
      final v = await _picker.pickVideo(source: ImageSource.gallery);
      if(v != null) setState(()=> _media.add(v));
    }catch(e){
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.create_post_error)));
    }
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async{
    final content = _controller.text.trim();
    if(content.isEmpty) return;
    setState(()=> _posting = true);

    if (Utils.accessToken == null || Utils.accessToken!.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.login_first ?? 'Please login to post')));
      setState(()=> _posting = false);
      Navigator.of(context).pushNamed('/login');
      return;
    }

    try{
      if (_media.any((m) => (m.mimeType?.startsWith('video/') ?? false))) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.video_not_supported)));
        setState(()=> _posting = false);
        return;
      }
      final post = await _feedService.createPost({
        'content': content,
        'images': _media.map((e) => e.path).toList(),
        'visibility': _privacy,
      });
      Navigator.of(context).pop(post);
    }catch(e){
      final loc = AppLocalizations.of(context)!;
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.create_post_error}: $message')));
      print('_submit error: $e');
    }finally{
      if(mounted) setState(()=> _posting = false);
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
    return Scaffold(
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
      body: Column(
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
              onTap: () async{
                final sel = await showModalBottomSheet<String>(context: context, builder: (ctx){
                  return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(title: Text(loc.privacy_public), onTap: ()=> Navigator.of(ctx).pop('public')),
                    ListTile(title: Text(loc.privacy_friends), onTap: ()=> Navigator.of(ctx).pop('friends')),
                    ListTile(title: Text(loc.privacy_private), onTap: ()=> Navigator.of(ctx).pop('private')),
                  ]));
                });
                if(sel != null) setState(()=> _privacy = sel);
              },
              child: Row(children: [Icon(Icons.public, size: 16), SizedBox(width:6), Text(_privacy == 'public' ? loc.privacy_public : _privacy=='friends' ? loc.privacy_friends : loc.privacy_private)]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(hintText: loc.create_post_hint),
                autofocus: true,
              ),
            ),
          ),
          // Media previews
          if(_media.isNotEmpty)
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(horizontal:12, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _media.length,
                itemBuilder: (ctx, i){
                  final file = File(_media[i].path);
                  final isVideo = _media[i].mimeType?.startsWith('video/') ?? false;
                  return Stack(
                    children: [
                      Container(margin: EdgeInsets.only(right:8), width: 120, height:100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: isVideo ? Center(child: Icon(Icons.videocam, size: 40)) : Image.file(file, fit: BoxFit.cover)),
                      Positioned(top:4, right:4, child: InkWell(onTap: (){ setState(()=> _media.removeAt(i)); }, child: CircleAvatar(radius:12, child: Icon(Icons.close, size:14))))
                    ],
                  );
                },
              ),
            ),
          Container(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal:12, vertical: 8),
              children: [
                // color choices
                ...List.generate(8, (i) => Container(margin: EdgeInsets.only(right:8), width: 48, height:48, decoration: BoxDecoration(color: Colors.primaries[i % Colors.primaries.length], borderRadius: BorderRadius.circular(8)))),
                // Add buttons
                SizedBox(width:12),
                IconButton(icon: Icon(Icons.image), onPressed: _pickImages),
                IconButton(icon: Icon(Icons.videocam), onPressed: _pickVideo),
              ],
            ),
          ),
          Divider(height:1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                _ActionItem(icon: Icons.image, label: loc.photo, onTap: _pickImages),
                _ActionItem(icon: Icons.videocam, label: loc.video, onTap: _pickVideo),
                _ActionItem(icon: Icons.person_add_alt_1, label: loc.tag_people, onTap: (){}),
                _ActionItem(icon: Icons.place, label: loc.add_location, onTap: (){}),
                _ActionItem(icon: Icons.emoji_emotions, label: loc.feeling_activity, onTap: (){}),
                _ActionItem(icon: Icons.event, label: loc.create_event, onTap: (){}),
              ],
            ),
          ),
        ],
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
