import 'package:flutter/material.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Model/SearchUsersResult.dart';
import 'package:mangxahoi/Service/UserService.dart';
import 'package:mangxahoi/Views/Profile/UserProfileView.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class SearchView extends StatefulWidget {
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  final UserService _userService = UserService();
  List<AuthUserModel> _results = [];
  SearchPagination _pagination = const SearchPagination.empty();
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    final l10n = AppLocalizations.of(context);

    if (trimmed.length < 2) {
      setState(() {
        _error = l10n?.search_min_chars ?? 'Please type at least 2 characters';
        _results = [];
        _pagination = const SearchPagination.empty();
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
      final result = await _userService.searchUsers(trimmed, limit: 20);
      setState(() {
        _results = result.users;
        _pagination = result.pagination;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _results = [];
        _pagination = const SearchPagination.empty();
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

    if (_hasSearched && _results.isEmpty) {
      return Center(child: Text(l10n?.search_no_results ?? 'No users found'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${l10n?.search_title ?? 'Search'}: ${_pagination.total}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = _results[index];
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
          ),
        ),
      ],
    );
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
      ),
      body: _buildBody(l10n),
    );
  }
}
