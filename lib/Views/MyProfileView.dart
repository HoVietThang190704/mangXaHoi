import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Components/profile/ProfileFeedSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHeaderSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHighlightsSection.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/services/api_service.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final FeedService _feedService = FeedService();
  List<PostModel> _posts = [];
  AuthUserModel? _user = Utils.currentUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Utils.selectIndex = 1;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _fetchProfile();
      final posts = await _feedService.getPosts(page: 1, pageSize: 50);
      final filtered = profile == null
          ? posts
          : posts.where((post) => post.userId == profile.id).toList();

      if (!mounted) return;
      setState(() {
        _user = profile ?? _user;
        _posts = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<AuthUserModel?> _fetchProfile() async {
    try {
      final api = await ApiService.create(enableLog: false);
      final response = await api.getProfile();

      final candidate = _extractUserMap(response);
      if (candidate == null) {
        debugPrint('⚠️ No valid user payload in profile response');
        return _user;
      }

      final user = AuthUserModel.fromJson(candidate);
      Utils.currentUser = user;
      Utils.userName = user.userName ?? user.email;
      return user;
    } catch (e) {
      debugPrint('⚠️ Failed to fetch profile: $e');
      return _user;
    }
  }

  Map<String, dynamic>? _extractUserMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      final hasUserFields = value.containsKey('email') || value.containsKey('id') || value.containsKey('_id');
      if (hasUserFields) {
        return Map<String, dynamic>.from(value);
      }
      for (final key in ['data', 'user', 'profile']) {
        if (value.containsKey(key)) {
          final nested = _extractUserMap(value[key]);
          if (nested != null) return nested;
        }
      }
    }
    return null;
  }

  Future<void> _handleLike(PostModel post) async {
    final loc = AppLocalizations.of(context)!;
    final previousLiked = post.isLiked;
    final previousLikes = post.likes;

    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      if (post.likes < 0) post.likes = 0;
    });

    try {
      final result = await _feedService.toggleLike(post.id);
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
        SnackBar(content: Text(loc.profile_like_error)),
      );
    }
  }

  List<String> get _photoUrls {
    final urls = <String>{};
    for (final post in _posts) {
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        urls.add(post.imageUrl!);
      }
      for (final img in post.images) {
        if (img.isNotEmpty) urls.add(img);
      }
    }
    return urls.toList();
  }

  List<String> get _highlights {
    final user = _user;
    final items = <String>[];
    if (user?.role != null && user!.role!.isNotEmpty) {
      items.add(user.role!);
    }
    final address = user?.address;
    if (address != null) {
      final city = address['city']?.toString();
      final country = address['country']?.toString();
      if (city != null && city.isNotEmpty) items.add(city);
      if (country != null && country.isNotEmpty && (city == null || city != country)) {
        items.add(country);
      }
    }
    return items;
  }

  List<ProfileDetail> get _details {
    final user = _user;
    if (user == null) return const [];
    final items = <ProfileDetail>[];
    items.add(ProfileDetail(icon: Icons.email_outlined, text: user.email));
    if (user.phone != null && user.phone!.isNotEmpty) {
      items.add(ProfileDetail(icon: Icons.phone, text: user.phone!));
    }
    final address = user.address;
    if (address != null) {
      final parts = <String>[];
      for (final key in ['street', 'ward', 'district', 'city', 'country']) {
        final value = address[key];
        if (value is String && value.isNotEmpty) {
          parts.add(value);
        }
      }
      if (parts.isNotEmpty) {
        items.add(
          ProfileDetail(
            icon: Icons.location_on_outlined,
            text: parts.join(', '),
          ),
        );
      }
    }
    if (user.role != null && user.role!.isNotEmpty) {
      items.add(ProfileDetail(icon: Icons.work_outline, text: user.role!));
    }
    return items;
  }

  List<FriendPreview> get _friends {
    final raw = _user?.address?['friends'];
    if (raw is List) {
      return raw
          .map((entry) {
            if (entry is Map) {
              final name = entry['name']?.toString();
              final photo = entry['photo']?.toString();
              if (name != null && name.isNotEmpty) {
                return FriendPreview(name: name, photoUrl: photo);
              }
            }
            return null;
          })
          .whereType<FriendPreview>()
          .toList();
    }
    return const [];
  }

  int? get _friendCount {
    final value = _user?.address?['friendCount'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (_friends.isNotEmpty) return _friends.length;
    return null;
  }

  String _displayName(BuildContext context) {
    final user = _user;
    if (user == null) {
      return AppLocalizations.of(context)!.profile_default_display_name;
    }
    final preferred = user.userName;
    return (preferred != null && preferred.isNotEmpty) ? preferred : user.email;
  }

  String? get _avatarUrl => _user?.avatar;

  String _initials(String displayName) {
    final name = displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String? get _coverUrl {
    final address = _user?.address;
    if (address == null) return null;
    final dynamic value = address['coverUrl'];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF1877F2);
    final displayName = _displayName(context);
    final initials = _initials(displayName);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      bottomNavigationBar: BottomNavigationBarComponent(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(displayName, initials),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: _user == null
                      ? (_isLoading
                          ? const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : ProfileEmptyState(onRetry: _loadData))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileHeaderSection(
                              accentColor: accent,
                              displayName: displayName,
                              initials: initials,
                              avatarUrl: _avatarUrl,
                              coverUrl: _coverUrl,
                              friendCount: _friendCount,
                              highlights: _highlights,
                            ),
                            const SizedBox(height: 20),
                            ProfileHighlightsSection(
                              details: _details,
                              photoUrls: _photoUrls,
                              friends: _friends,
                              accentColor: accent,
                            ),
                            const SizedBox(height: 24),
                            ProfileFeedSection(
                              posts: _posts,
                              isLoading: _isLoading,
                              errorMessage: _error,
                              onRetry: _loadData,
                              onLike: _handleLike,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(String displayName, String initials) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
            child: _avatarUrl == null
                ? Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }
}
