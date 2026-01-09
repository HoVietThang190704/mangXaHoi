import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/AppBarComponent.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Components/CreatePostComponent.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Components/StoryBarComponent.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FeedService _service = FeedService();
  final ScrollController _scrollController = ScrollController();
  final List<PostModel> _posts = [];
  int _page = 1;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loadingMore = false);
    _page = 1;
    try {
      final posts = await _service.getPosts(page: _page);
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(posts);
      });
    } catch (e) {
      debugPrint('Error loading feed: $e');
      if (!mounted) return;
      setState(() => _posts.clear());
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);

    final nextPage = _page + 1;
    try {
      final more = await _service.getPosts(page: nextPage);
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _posts.addAll(more);
        _loadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading more feed: $e');
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _onRefresh() => _loadInitial();

  Future<void> _onCreatePost(String content) async {
    final now = DateTime.now();
    final author = Utils.currentUser ??
        AuthUserModel(
          id: 'local-${now.millisecondsSinceEpoch}',
          email: 'user@localhost',
          userName: 'Bạn',
        );

    final tempPost = PostModel(
      id: 'temp-${now.millisecondsSinceEpoch}',
      userId: author.id,
      author: author,
      content: content,
      images: const [],
      createdAt: now,
      updatedAt: now,
    );

    setState(() => _posts.insert(0, tempPost));

    try {
      final created = await _service.createPost({
        'content': content,
        'visibility': 'public',
      });

      if (!mounted) return;
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == tempPost.id);
        if (idx >= 0) {
          _posts[idx] = created;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _posts.removeWhere((p) => p.id == tempPost.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo bài viết.')),
      );
    }
  }

  Future<void> _handleLike(PostModel post) async {
    final previousLiked = post.isLiked;
    final previousLikes = post.likes;

    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      if (post.likes < 0) {
        post.likes = 0;
      }
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
        const SnackBar(content: Text('Không thể cập nhật lượt thích.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarComponent('Home'),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 3 + _posts.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) return StoryBarComponent();
            if (index == 1) return CreatePostComponent(onPost: _onCreatePost);
            if (index == 2) return Divider(thickness: 6, color: Colors.grey[200]);

            final postIndex = index - 3;
            if (postIndex < _posts.length) {
              final post = _posts[postIndex];
              return PostCardComponent(
                post: post,
                onLike: () => _handleLike(post),
                onComment: () {},
              );
            }

            return const Padding(
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

