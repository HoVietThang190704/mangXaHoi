import 'package:flutter/material.dart';
import 'package:mangxahoi/Service/UserService.dart';
import 'package:mangxahoi/Service/ChatService.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  _CreateGroupViewState createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();

  bool _creating = false;
  List<AuthUserModel> _searchResults = [];
  final List<AuthUserModel> _selected = [];

  void _onSearchChanged(String value) async {
    final term = value.trim();
    if (term.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final users = await _userService.searchUsers(term, limit: 20);
      if (!mounted) return;
      setState(() => _searchResults = users.users);
    } catch (e) {
      // ignore
    }
  }

  void _toggleSelect(AuthUserModel user) {
    setState(() {
      final idx = _selected.indexWhere((u) => u.id == user.id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(user);
      }
    });
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profile_message_unavailable)));
      return;
    }
    setState(() => _creating = true);
    try {
      final memberIds = _selected.map((e) => e.id).toList();
      final created = await _chatService.createGroup(name: name, memberIds: memberIds);
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.create_group_failed)));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.create_group_title),
        actions: [
          TextButton(
            onPressed: _creating ? null : _createGroup,
            child: _creating ? CircularProgressIndicator(strokeWidth: 2) : Text(l10n.create_group_button)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l10n.create_group_name_hint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: l10n.create_group_search_hint),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selected.map((u) => Chip(label: Text(u.userName ?? u.email), onDeleted: () => _toggleSelect(u))).toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemBuilder: (ctx, idx) {
                  final u = _searchResults[idx];
                  final isSelected = _selected.any((s) => s.id == u.id);
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: u.avatar != null ? NetworkImage(u.avatar!) : null, child: u.avatar == null ? Text((u.userName?.isNotEmpty ?? false) ? u.userName![0].toUpperCase() : 'U') : null),
                    title: Text(u.userName ?? u.email),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : Icon(Icons.add_circle_outline),
                    onTap: () => _toggleSelect(u),
                  );
                },
                separatorBuilder: (_, __) => Divider(height: 1),
                itemCount: _searchResults.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
