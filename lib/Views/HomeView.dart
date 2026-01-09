import 'package:mangxahoi/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/AppBarComponent.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Components/CreatePostComponent.dart';
import 'package:mangxahoi/Views/CreatePostView.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Components/StoryBarComponent.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Service/SessionService.dart';
import 'package:mangxahoi/Utils.dart';

import 'PostDetailView.dart';

import '../Components/AppBarComponent.dart';
import '../Components/BottomNavigationBarComponent.dart';

class HomeView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _homeView();
  }
}

class _homeView extends State<HomeView> {
  final FeedService _service = FeedService();
  final List<PostModel> _posts = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _loadingMore = false;
  bool _refreshing = false;

  _homeView(){
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitial() async{
    _page = 1;
    try{
      final posts = await _service.getPosts(page: _page);
      setState((){
        _posts.clear();
        _posts.addAll(posts);
      });
      _maybeUpdateUserAvatarFromPosts(posts);
    }catch(e){
      // If backend not available or unauthorized, leave empty and log
      print('Error loading feed: $e');
      setState((){
        _posts.clear();
      });
    }
  }

  Future<void> _loadMore() async{
    if(_loadingMore) return;
    setState(()=> _loadingMore = true);
    _page++;
    try{
      final more = await _service.getPosts(page: _page);
      setState((){
        _posts.addAll(more);
        _loadingMore = false;
      });
      _maybeUpdateUserAvatarFromPosts(more);
    }catch(e){
      print('Error loading more feed: $e');
      setState(()=> _loadingMore = false);
    }
  }

  void _maybeUpdateUserAvatarFromPosts(List<PostModel> posts){
    if ((Utils.currentUser?.avatar?.trim().isNotEmpty ?? false) || Utils.currentUser == null) return;
    PostModel? mine;
    try {
      mine = posts.firstWhere(
        (p) => p.userId == Utils.currentUser!.id && (p.author.avatar?.trim().isNotEmpty ?? false),
      );
    } catch (_) {
      mine = null;
    }
    if (mine == null) return;
    final updatedUser = AuthUserModel(
      id: Utils.currentUser!.id,
      email: Utils.currentUser!.email,
      userName: Utils.currentUser!.userName,
      phone: Utils.currentUser!.phone,
      avatar: mine.author.avatar,
      role: Utils.currentUser!.role,
      isVerified: Utils.currentUser!.isVerified,
      address: Utils.currentUser!.address,
    );
    Utils.currentUser = updatedUser;
    SessionService.updateUser(updatedUser);
    setState((){});
  }

  void _onScroll(){
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200){
      _loadMore();
    }
  }

  Future<void> _onRefresh() async{
    setState(()=> _refreshing = true);
    await _loadInitial();
    setState(()=> _refreshing = false);
  }

  void _onCreatePost(String content) async{
    // Optimistic update: insert a temporary post while creating on server
    final author = Utils.currentUser ??
      AuthUserModel(id: '0', email: 'me@example.com', userName: 'Bạn');
    final tempPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: author.id,
      author: author,
      content: content,
      images: const [],
      imageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: 0,
      comments: 0,
    );

    setState(()=> _posts.insert(0, tempPost));

    try{
      final created = await _service.createPost({
        'content': content,
        'images': [],
        'visibility': 'public',
      });

      // Replace temporary post with created post from server (match by temp id)
      setState((){
        final idx = _posts.indexWhere((p) => p.id == tempPost.id);
        if(idx >= 0) _posts[idx] = created;
      });
    }catch(e){
      // Remove temporary post on failure and show message
      setState(()=> _posts.removeWhere((p) => p.id == tempPost.id));
      ScaffoldMessenger.of(Utils.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Không thể tạo bài viết.')));
    }
  }

  Future<void> _handleLike(PostModel post) async {
    final previousLiked = post.isLiked;
    final previousLikes = post.likes;

    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      if (post.likes < 0) post.likes = 0;
    });

    try {
      final result = await _service.toggleLike(post.id);
      if (!mounted) return;
      setState(() {
        post.isLiked = result['isLiked'] ?? post.isLiked;
        post.likes = result['likesCount'] ?? post.likes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        post.isLiked = previousLiked;
        post.likes = previousLikes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật lượt thích.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent('Home', onPostCreated: (p) => setState(() => _posts.insert(0, p))),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 3 + _posts.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index){
            if(index == 0) return StoryBarComponent();
            if (index == 1) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (Utils.currentUser?.avatar?.trim().isNotEmpty ?? false)
                            ? NetworkImage(Utils.currentUser!.avatar!.trim())
                            : null,
                        child: (Utils.currentUser?.avatar?.trim().isNotEmpty ?? false)
                            ? null
                            : Icon(Icons.person, color: Colors.grey[700]),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final created = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CreatePostView()));
                            if (created != null) {
                              setState(() => _posts.insert(0, created));
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
            if(index == 2) return Divider(thickness: 6, color: Colors.grey[200]);
            final postIndex = index - 3;
            if(postIndex < _posts.length){
              final p = _posts[postIndex];
              return PostCardComponent(
                post: p,
                onLike: () => _handleLike(p),
                onComment: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PostDetailView(post: p))).then((value){
                    if(value is PostModel){
                      setState((){
                        final idx = _posts.indexWhere((element) => element.id == value.id);
                        if(idx >= 0) _posts[idx] = value;
                      });
                    }
                  });
                },
              );
            }
            // loading more indicator
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }
}

