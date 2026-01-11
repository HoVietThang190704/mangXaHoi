import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/profile/ProfileFeedSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHeaderSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHighlightsSection.dart';
import 'package:mangxahoi/Components/profile/ProfilePhotosSection.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/FriendStatus.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Service/FriendService.dart';
import 'package:mangxahoi/Service/UserService.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/Views/PostDetailView.dart';
import 'package:mangxahoi/Views/Profile/ProfilePhotosView.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Views/Chat/ChatViewArguments.dart';
import 'package:mangxahoi/Service/ChatSocketManager.dart';

class UserProfileArguments {
  final String userId;
  final AuthUserModel? initialUser;

  const UserProfileArguments({required this.userId, this.initialUser});
}

class UserProfileView extends StatefulWidget {
  final String userId;
  final AuthUserModel? initialUser;

  const UserProfileView({super.key, required this.userId, this.initialUser});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final FeedService _feedService = FeedService();
  final UserService _userService = UserService();
  final FriendService _friendService = FriendService();

  List<PostModel> _posts = const <PostModel>[];
  AuthUserModel? _user;
  bool _loadingProfile = true;
  bool _loadingPosts = true;
  String? _profileError;
  String? _postsError;
  int _activeTab = 0;
  FriendStatus _friendStatus = FriendStatus.none;
  bool _friendBusy = false;

  StreamSubscription<FriendSocketEvent>? _friendSub;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    _loadInitial();

    ChatSocketManager.instance.ensureConnected();
    _friendSub = ChatSocketManager.instance.friendEvents.listen((event) {
      if (event.type == 'friend_request_accepted') {
        final relatedUserId = event.payload['userId']?.toString();
        if (relatedUserId == widget.userId || Utils.currentUser?.id == widget.userId) {
          _loadProfile();
        }
      }
    });
  }

  Future<void> _loadInitial() async {
    await Future.wait([
      _loadProfile(),
      _loadPosts(),
      _loadFriendState(),
    ]);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await _userService.getPublicProfile(widget.userId);
      if (!mounted) return;
      setState(() => _user = profile);
    } catch (e) {
      if (!mounted) return;
      setState(() => _profileError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loadingPosts = true;
      _postsError = null;
    });

    try {
      final posts = await _feedService.getPostsByUser(widget.userId, pageSize: 50);
      if (!mounted) return;
      setState(() => _posts = posts);
    } catch (e) {
      if (!mounted) return;
      setState(() => _postsError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loadingPosts = false);
      }
    }
  }

  Future<void> _loadFriendState() async {
    final status = await _friendService.getStatus(widget.userId);
    if (!mounted) return;
    setState(() => _friendStatus = status);
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _loadProfile(),
      _loadPosts(),
      _loadFriendState(),
    ]);
  }

  bool get _isViewingSelf {
    final currentId = Utils.currentUser?.id;
    return currentId != null && currentId == widget.userId;
  }

  List<String> get _photoUrls {
    final urls = <String>{};
    for (final post in _posts) {
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        urls.add(post.imageUrl!);
      }
      for (final image in post.images) {
        if (image.isNotEmpty) {
          urls.add(image);
        }
      }
    }
    return urls.toList();
  }

  List<String> get _highlights {
    final highlights = <String>[];
    final address = _user?.address;
    if (address != null) {
      final city = address['city']?.toString();
      final country = address['country']?.toString();
      if (city != null && city.isNotEmpty) highlights.add(city);
      if (country != null && country.isNotEmpty && country != city) {
        highlights.add(country);
      }
    }
    return highlights;
  }

  List<ProfileDetail> get _details {
    final user = _user;
    if (user == null) return const <ProfileDetail>[];
    final items = <ProfileDetail>[
      ProfileDetail(icon: Icons.email_outlined, text: user.email),
    ];
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
        items.add(ProfileDetail(icon: Icons.location_on_outlined, text: parts.join(', ')));
      }
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
    return const <FriendPreview>[];
  }

  int? get _friendCount {
    final value = _user?.address?['friendCount'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (_friends.isNotEmpty) return _friends.length;
    return null;
  }

  String _displayName(AppLocalizations loc) {
    final user = _user;
    if (user == null) return loc.profile_user_title;
    final preferred = user.userName;
    return (preferred != null && preferred.isNotEmpty) ? preferred : user.email;
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
    } catch (_) {
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

  Future<void> _handleFriendAction() async {
    if (_friendBusy || _isViewingSelf) return;
    final loc = AppLocalizations.of(context)!;

    setState(() => _friendBusy = true);
    try {
      FriendStatus updated;
      if (_friendStatus == FriendStatus.none) {
        updated = await _friendService.sendFriendRequest(widget.userId);
        _showSnack(loc.profile_friend_request_sent);
      } else if (_friendStatus == FriendStatus.pendingSent) {
        updated = await _friendService.cancelFriendRequest(widget.userId);
        _showSnack(loc.profile_friend_request_cancelled);
      } else if (_friendStatus == FriendStatus.friends) {
        updated = await _friendService.removeFriend(widget.userId);
        _showSnack(loc.profile_friend_removed);
      } else {
        return;
      }

      if (mounted) {
        setState(() => _friendStatus = updated);
        await _loadProfile();
      }
    } catch (_) {
      if (mounted) {
        _showSnack(loc.profile_friend_request_failed);
      }
    } finally {
      if (mounted) {
        setState(() => _friendBusy = false);
      }
    }
  }

  Future<void> _handleAcceptRequest() async {
    if (_friendBusy) return;
    final loc = AppLocalizations.of(context)!;
    final requestId = _friendService.cachedRequestId;
    if (requestId == null) return;

    setState(() => _friendBusy = true);
    try {
      await _friendService.acceptFriendRequest(requestId);
      _showSnack(loc.profile_friend_accepted);
      if (mounted) {
        await _loadProfile();
        setState(() => _friendStatus = FriendStatus.friends);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(loc.profile_friend_request_failed);
      }
    } finally {
      if (mounted) {
        setState(() => _friendBusy = false);
      }
    }
  }

  Future<void> _handleRejectRequest() async {
    if (_friendBusy) return;
    final loc = AppLocalizations.of(context)!;
    final requestId = _friendService.cachedRequestId;
    if (requestId == null) return;

    setState(() => _friendBusy = true);
    try {
      await _friendService.rejectFriendRequest(requestId);
      _showSnack(loc.profile_friend_rejected);
      if (mounted) {
        setState(() => _friendStatus = FriendStatus.none);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(loc.profile_friend_request_failed);
      }
    } finally {
      if (mounted) {
        setState(() => _friendBusy = false);
      }
    }
  }

  void _handleMessage() {
    if (_user == null) {
      final loc = AppLocalizations.of(context)!;
      _showSnack(loc.profile_message_unavailable);
      return;
    }
    final loc = AppLocalizations.of(context)!;
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: ChatViewArguments(
        userId: _user!.id,
        displayName: _displayName(loc),
        avatar: _user!.avatar,
      ),
    );
  }

  Future<void> _openPostDetail(PostModel post) async {
    final updated = await Navigator.of(context).push<PostModel>(
      MaterialPageRoute(builder: (ctx) => PostDetailView(post: post)),
    );
    if (updated != null && mounted) {
      setState(() {
        final idx = _posts.indexWhere((element) => element.id == updated.id);
        if (idx >= 0) {
          _posts[idx] = updated;
        }
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget? _buildActionArea(AppLocalizations loc) {
    if (_isViewingSelf) return null;
    
    // Handle pending received - show accept/reject buttons
    if (_friendStatus == FriendStatus.pendingReceived) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _friendBusy ? null : _handleAcceptRequest,
              icon: _friendBusy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(loc.profile_pending_received),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _friendBusy ? null : _handleRejectRequest,
              icon: const Icon(Icons.close),
              label: Text(loc.profile_reject_request),
            ),
          ),
        ],
      );
    }
    
    late final String friendLabel;
    late final IconData friendIcon;
    switch (_friendStatus) {
      case FriendStatus.none:
        friendLabel = loc.profile_add_friend;
        friendIcon = Icons.person_add_alt;
        break;
      case FriendStatus.pendingSent:
        friendLabel = loc.profile_cancel_request;
        friendIcon = Icons.hourglass_bottom;
        break;
      case FriendStatus.friends:
        friendLabel = loc.profile_remove_friend;
        friendIcon = Icons.check;
        break;
      case FriendStatus.pendingReceived:
        friendLabel = loc.profile_pending_received;
        friendIcon = Icons.person;
        break;
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _friendBusy ? null : _handleFriendAction,
            icon: _friendBusy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(friendIcon),
            label: Text(friendLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _user == null ? null : _handleMessage,
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(loc.profile_message),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(AppLocalizations loc) {
    if (_loadingProfile && _user == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return ProfileErrorCard(
        message: _profileError ?? loc.profile_error_title,
        onRetry: _loadProfile,
      );
    }

    final accent = const Color(0xFF1877F2);
    final displayName = _displayName(loc);
    final initials = _initials(displayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderSection(
          accentColor: accent,
          displayName: displayName,
          initials: initials,
          avatarUrl: _user?.avatar,
          coverUrl: _user?.address?['coverUrl']?.toString(),
          friendCount: _friendCount,
          highlights: _highlights,
          introDetails: _details,
          friends: _friends,
          activeIndex: _activeTab,
          onTabChanged: (index) => setState(() => _activeTab = index),
          onFriendTap: (friend) async {
            final userName = friend.name;
            final userId = friend.id;
            if (userId != null && userId.isNotEmpty) {
              Navigator.of(context).pushNamed('/profile/user', arguments: UserProfileArguments(userId: userId));
              return;
            }
            // Fallback: search by name
            if (userName != null && userName.isNotEmpty) {
              try {
                final result = await _userService.searchUsers(userName, limit: 20);
                if (result.users.length == 1) {
                  Navigator.of(context).pushNamed('/profile/user', arguments: UserProfileArguments(userId: result.users.first.id));
                } else if (result.users.isNotEmpty) {
                  // Many results - open search page with query
                  Navigator.pushNamed(context, '/search', arguments: {'q': userName});
                } else {
                  final loc = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.profile_friend_not_found)));
                }
              } catch (_) {
                final loc = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.profile_friend_not_found)));
              }
            }
          },
          onViewAll: () {
            Navigator.of(context).pushNamed('/profile/friends', arguments: {'userId': widget.userId, 'title': displayName});
          },
          actionArea: _buildActionArea(loc),
          showAvatarAction: false,
        ),
        const SizedBox(height: 20),
        if (_activeTab == 0)
          ProfileFeedSection(
            posts: _posts,
            isLoading: _loadingPosts,
            errorMessage: _postsError,
            onRetry: _loadPosts,
            onLike: _handleLike,
            onComment: _openPostDetail,
          )
        else if (_activeTab == 1)
          ProfilePhotosSection(
            photoUrls: _photoUrls,
            accentColor: accent,
            onPhotoTap: (index, url) {
              PostModel? matched;
              for (final p in _posts) {
                if ((p.imageUrl?.trim() ?? '') == url || p.images.contains(url)) {
                  matched = p;
                  break;
                }
              }
              if (matched != null) {
                _openPostDetail(matched);
              } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfilePhotosView(photoUrls: _photoUrls, initialIndex: index)));
              }
            },
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Text('No reels available.'),
          ),
        const SizedBox(height: 24),
        ProfileHighlightsSection(
          photoUrls: _photoUrls,
          friends: _friends,
          accentColor: accent,
          showPhotos: _activeTab != 1,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _friendSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = _user?.userName ?? _user?.email ?? loc.profile_user_title;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: _buildProfileCard(loc),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
