import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/AppBarComponent.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Components/CreatePostComponent.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Components/StoryBarComponent.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Utils.dart';

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
    }catch(e){
      print('Error loading more feed: $e');
      setState(()=> _loadingMore = false);
    }
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
      appBar: AppBarComponent('Home'),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 3 + _posts.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index){
            if(index == 0) return StoryBarComponent();
            if(index == 1) return CreatePostComponent(onPost: _onCreatePost);
            if(index == 2) return Divider(thickness: 6, color: Colors.grey[200]);
            final postIndex = index - 3;
            if(postIndex < _posts.length){
              final p = _posts[postIndex];
              return PostCardComponent(
                post: p,
                onLike: () => _handleLike(p),
                onComment: (){
                  // navigate to comment page later
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

