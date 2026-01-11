import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Model/SearchResult.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Service/SearchService.dart';
import 'package:mangxahoi/Views/PostDetailView.dart';
import 'package:mangxahoi/Views/Profile/UserProfileView.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class SearchView extends StatefulWidget {
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final TabController _tabController;
  final SearchService _searchService = SearchService();
  final FeedService _feedService = FeedService();

  List<AuthUserModel> _userResults = [];
  List<PostModel> _postResults = [];
  SearchPageInfo _userPage = const SearchPageInfo.empty();
  SearchPageInfo _postPage = const SearchPageInfo.empty();
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    final l10n = AppLocalizations.of(context);

    if (trimmed.length < 2) {
      setState(() {
        _error = l10n?.search_min_chars ?? 'Please type at least 2 characters';
        _userResults = [];
        _postResults = [];
        _userPage = const SearchPageInfo.empty();
        _postPage = const SearchPageInfo.empty();
        _hasSearched = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final result = await _searchService.search(trimmed, userLimit: 20, postLimit: 10);
      setState(() {
        _userResults = result.users.items;
        _postResults = result.posts.items;
        _userPage = result.users.pageInfo;
        _postPage = result.posts.pageInfo;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _userResults = [];
        _postResults = [];
        _userPage = const SearchPageInfo.empty();
        _postPage = const SearchPageInfo.empty();
        _error = l10n?.search_error ?? 'Unable to search users. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasSearched)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '${l10n?.search_title ?? 'Search'}: ${_userPage.total + _postPage.total}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsersTab(l10n),
              _buildPostsTab(l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(AppLocalizations? l10n) {
    if (!_hasSearched) {
      return Center(child: Text(l10n?.search_hint ?? 'Search users'));
    }

    if (_userResults.isEmpty) {
      return Center(child: Text(l10n?.search_no_results ?? 'No users found'));
    }

    return ListView.separated(
      itemCount: _userResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _userResults[index];
        final name = user.userName ?? user.email;
        final avatar = user.avatar;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
            child: (avatar == null || avatar.isEmpty)
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(name),
          subtitle: Text(user.email),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/profile/user',
              arguments: UserProfileArguments(userId: user.id, initialUser: user),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsTab(AppLocalizations? l10n) {
    if (!_hasSearched) {
      return Center(child: Text(l10n?.search_tab_posts_hint ?? 'Search posts'));
    }

    if (_postResults.isEmpty) {
      return Center(child: Text(l10n?.search_posts_empty ?? 'No posts found'));
    }

    return ListView.builder(
      itemCount: _postResults.length,
      itemBuilder: (context, index) {
        final post = _postResults[index];
        return PostCardComponent(
          post: post,
          onLike: () => _handleLike(post),
          onComment: () => _openPostDetail(post),
        );
      },
    );
  }

  Future<void> _openPostDetail(PostModel post) async {
    final updated = await Navigator.of(context).push<PostModel>(
      MaterialPageRoute(builder: (_) => PostDetailView(post: post)),
    );
    if (!mounted || updated == null) return;

    setState(() {
      final index = _postResults.indexWhere((p) => p.id == updated.id);
      if (index >= 0) {
        _postResults[index] = updated;
      }
    });
  }

  Future<void> _handleLike(PostModel post) async {
    final l10n = AppLocalizations.of(context);
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
      final result = await _feedService.toggleLike(post.id);
      if (!mounted) return;
      setState(() {
        post.isLiked = result['isLiked'] ?? post.isLiked;
        post.likes = result['likesCount'] ?? post.likes;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        post.isLiked = previousLiked;
        post.likes = previousLikes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.profile_like_error ?? 'Unable to update likes.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n?.search_hint ?? 'Search users',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => _performSearch(_controller.text),
            tooltip: l10n?.search_title ?? 'Search',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          tabs: [
            Tab(text: l10n?.search_tab_users ?? 'Users'),
            Tab(text: l10n?.search_tab_posts ?? 'Posts'),
          ],
        ),
      ),
      body: _buildBody(l10n),
    );
  }
}
