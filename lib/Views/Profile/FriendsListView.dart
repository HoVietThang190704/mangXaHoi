import 'package:flutter/material.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Service/FriendService.dart';
import 'package:mangxahoi/Service/UserService.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class FriendsListArguments {
  final String userId;
  final String? title;

  FriendsListArguments({required this.userId, this.title});
}

class FriendsListView extends StatefulWidget {
  final FriendsListArguments args;

  const FriendsListView({super.key, required this.args});

  @override
  State<FriendsListView> createState() => _FriendsListViewState();
}

class _FriendsListViewState extends State<FriendsListView> {
  final FriendService _friendService = FriendService();
  final UserService _userService = UserService();

  List<dynamic> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  final int _limit = 50;
  bool _hasMore = true;

  bool get _isSelf => Utils.currentUser?.id != null && Utils.currentUser!.id == widget.args.userId;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
      _items = [];
    });

    try {
      if (_isSelf) {
        final items = await _friendService.getFriends(page: _page, limit: _limit);
        if (!mounted) return;
        setState(() {
          _items = items;
          _hasMore = items.length == _limit;
        });
      } else {
        final profile = await _userService.getPublicProfile(widget.args.userId);
        final raw = profile.address?['friends'];
        final list = <dynamic>[];
        if (raw is List) {
          for (final entry in raw) {
            if (entry is Map) {
              final id = entry['id']?.toString();
              final name = entry['name']?.toString();
              final photo = entry['photo']?.toString();
              if (name != null && name.isNotEmpty) {
                list.add({'id': id, 'name': name, 'avatar': photo});
              }
            }
          }
        }
        if (!mounted) return;
        setState(() {
          _items = list;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || !_isSelf) return;
    setState(() => _loadingMore = true);
    _page += 1;
    try {
      final items = await _friendService.getFriends(page: _page, limit: _limit);
      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _hasMore = items.length == _limit;
      });
    } catch (e) {
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _onTapFriend(dynamic item) async {
    final id = item is Map ? item['id']?.toString() : (item as dynamic).id?.toString();
    final name = item is Map ? item['name']?.toString() : (item as dynamic).name?.toString();

    if (id != null && id.isNotEmpty) {
      Navigator.of(context).pushNamed('/profile/user', arguments: id);
    }

    if (name != null && name.isNotEmpty) {
      try {
        final res = await _userService.searchUsers(name, limit: 20);
        if (res.users.length == 1) {
          Navigator.of(context).pushNamed('/profile/user', arguments: res.users.first.id);
        } else if (res.users.isNotEmpty) {
          Navigator.of(context).pushNamed('/search', arguments: {'q': name});
        } else {
          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.profile_friend_not_found)));
        }
      } catch (_) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.profile_friend_not_found)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = widget.args.title ?? (_isSelf ? loc.profile_my_friends : loc.profile_section_friends);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 120) {
                        _loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: _items.length + (_loadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        if (idx >= _items.length) return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                        final item = _items[idx];
                        final name = item is Map ? item['name']?.toString() ?? '' : (item as dynamic).name ?? '';
                        final avatar = item is Map ? item['avatar']?.toString() : (item as dynamic).avatar?.toString();
                        return ListTile(
                          leading: avatar != null && avatar.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(avatar))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(name),
                          onTap: () => _onTapFriend(item),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
