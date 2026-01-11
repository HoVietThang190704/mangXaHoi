import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Components/profile/ProfileFeedSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHeaderSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHighlightsSection.dart';
import 'package:mangxahoi/Components/profile/ProfilePhotosSection.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Service/FeedService.dart';
import 'package:mangxahoi/Views/PostDetailView.dart';
import 'package:mangxahoi/Views/Profile/ProfilePhotosView.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Views/Profile/UserProfileView.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mangxahoi/Service/SettingsService.dart';
import 'package:mangxahoi/Service/SessionService.dart';
import 'package:mangxahoi/services/api_service.dart';
import 'package:mangxahoi/Service/UserService.dart';

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
  int _activeTab = 0;
  bool _isUploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();
  final SettingsService _settingsService = SettingsService();

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

  Future<XFile?> _selectAvatarSource() async {
    final loc = AppLocalizations.of(context)!;
    return showModalBottomSheet<XFile?>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(loc.profile_avatar_take_photo),
              onTap: () async {
                final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 2048);
                Navigator.of(sheetContext).pop(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(loc.profile_avatar_choose_gallery),
              onTap: () async {
                final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 2048);
                Navigator.of(sheetContext).pop(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(loc.common_cancel),
              onTap: () => Navigator.of(sheetContext).pop(null),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleChangeAvatar() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await _selectAvatarSource();
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final file = File(picked.path);
      final avatarUrl = await _settingsService.uploadAvatar(file);
      final updated = await _settingsService.updateProfile(avatarUrl: avatarUrl);
      await SessionService.updateUser(updated);
      if (!mounted) return;
      setState(() => _user = updated);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.profile_avatar_updated)));
    } catch (e) {
      debugPrint('Avatar update failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.profile_avatar_update_failed)));
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  List<String> get _highlights {
    final user = _user;
    final items = <String>[];
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
                              introDetails: _details,
                              friends: _friends,
                              activeIndex: _activeTab,
                              isUploadingAvatar: _isUploadingAvatar,
                              onTabChanged: (index) {
                                if (!mounted) return;
                                setState(() => _activeTab = index);
                              },
                              onAvatarTap: _handleChangeAvatar,
                              onFriendTap: (friend) async {
                                final userName = friend.name;
                                final userId = friend.id;
                                if (userId != null && userId.isNotEmpty) {
                                  Navigator.of(context).pushNamed('/profile/user', arguments: UserProfileArguments(userId: userId));
                                  return;
                                }
                                if (userName != null && userName.isNotEmpty) {
                                  try {
                                    final result = await UserService().searchUsers(userName, limit: 20);
                                    if (result.users.length == 1) {
                                      Navigator.of(context).pushNamed('/profile/user', arguments: UserProfileArguments(userId: result.users.first.id));
                                    } else if (result.users.isNotEmpty) {
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
                                final uid = Utils.currentUser?.id;
                                if (uid == null) return;
                                Navigator.of(context).pushNamed('/profile/friends', arguments: {'userId': uid, 'title': displayName});
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_activeTab == 0) ...[
                              ProfileFeedSection(
                                posts: _posts,
                                isLoading: _isLoading,
                                errorMessage: _error,
                                onRetry: _loadData,
                                onLike: _handleLike,
                                onComment: _openPostDetail,
                              ),
                            ] else if (_activeTab == 1) ...[
                              ProfilePhotosSection(photoUrls: _photoUrls, accentColor: accent, onPhotoTap: (index, url) {
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
                              }),
                            ] else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                child: const Text('No reels available.'),
                              ),
                            ],
                            if (_activeTab != 0) ...[
                              const SizedBox(height: 24),
                              ProfileHighlightsSection(
                                photoUrls: _photoUrls,
                                friends: _friends,
                                accentColor: accent,
                                showPhotos: _activeTab != 1,
                              ),
                            ],
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
}
