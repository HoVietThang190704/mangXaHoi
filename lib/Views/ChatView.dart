import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mangxahoi/Model/ChatModels.dart';
import 'package:mangxahoi/Views/Chat/CreateGroupView.dart';
import 'package:mangxahoi/Repository/ChatRepository.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Service/ChatSocketManager.dart';
import 'package:mangxahoi/Utils.dart';

import '../Components/BottomNavigationBarComponent.dart';
import 'Chat/ChatDetailView.dart';
import 'Chat/ChatViewArguments.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _repo = ChatRepository();
  final _threads = <ChatThreadModel>[];
  final _searchController = TextEditingController();
  final _timeFormat = DateFormat('HH:mm');
  final _primaryColor = const Color(0xFF1877F2);
  final _backgroundColor = const Color(0xFFF6F7FB);
  final _mutedText = const Color(0xFF6B7280);
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  StreamSubscription<ChatSocketMessageEvent>? _messageSub;
  StreamSubscription<ChatThreadModel>? _threadSub;
  ChatViewArguments? _pendingArgs;
  bool _argsCaptured = false;
  bool _autoOpened = false;
  String _searchKeyword = '';

  String? get _currentUserId => Utils.currentUser?.id;

  List<ChatThreadModel> get _displayThreads {
    if (_searchKeyword.isEmpty) return List.unmodifiable(_threads);
    return _threads.where((thread) {
      final name = thread.otherParticipant(_currentUserId)?.displayName ?? '';
      final preview = thread.lastMessage ?? '';
      final query = _searchKeyword.toLowerCase();
      return name.toLowerCase().contains(query) || preview.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    Utils.selectIndex = 2;
    _loadThreads();
    _setupSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsCaptured) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ChatViewArguments) {
        _pendingArgs = args;
        _autoOpened = false;
      }
      _argsCaptured = true;
      _maybeOpenFromArgs();
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _threadSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setupSocket() {
    ChatSocketManager.instance.ensureConnected();
    _messageSub = ChatSocketManager.instance.messages.listen((event) {
      if (!mounted) return;
      setState(() {
        _upsertThread(event.thread);
      });
    });
    _threadSub = ChatSocketManager.instance.threadUpdates.listen((event) {
      if (!mounted) return;
      setState(() {
        _upsertThread(event);
      });
    });
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchKeyword = value.trim();
    });
  }

  Future<void> _loadThreads({bool refresh = false}) async {
    if (refresh) {
      setState(() => _refreshing = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await _repo.fetchThreads(page: 1, limit: 50);

      // Also fetch groups and merge them into the threads list so newly created
      // groups appear in the chat list. We map each group to a synthetic thread
      // where the group's name and avatar are shown as the participant.
      List<ChatThreadModel> groupThreads = [];
      try {
        final groups = await _repo.fetchGroups(page: 1, limit: 50);
        groupThreads = groups.map((g) => ChatThreadModel(
              id: 'group:${g.id}',
              participantIds: g.members,
              participants: [
                ChatParticipant(userId: g.id, userName: g.name, avatar: g.avatar)
              ],
              lastMessage: null,
              lastMessageAt: null,
              lastSenderId: null,
              unreadCount: 0,
              unreadByUser: {},
              createdAt: null,
              updatedAt: null,
            )).toList();
      } catch (_) {
        // Non-fatal: if fetching groups fails, continue showing threads only
      }

      if (!mounted) return;
      setState(() {
        _threads
          ..clear()
          ..addAll(groupThreads)
          ..addAll(result.threads);
        _loading = false;
        _refreshing = false;
      });
      _maybeOpenFromArgs();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _refreshing = false;
      });
    }
  }

  void _upsertThread(ChatThreadModel thread) {
    final idx = _threads.indexWhere((item) => item.id == thread.id);
    if (idx >= 0) {
      _threads[idx] = thread;
      final updated = _threads.removeAt(idx);
      _threads.insert(0, updated);
    } else {
      _threads.insert(0, thread);
    }
  }

  void _maybeOpenFromArgs() {
    if (_autoOpened) return;
    if (_pendingArgs == null || _pendingArgs?.userId == null) return;
    if (_loading) return;

    final argUserId = _pendingArgs!.userId!;
    final thread = _findThreadByUserId(argUserId);
    final args = _pendingArgs;
    _pendingArgs = null;

    if (thread != null) {
      _autoOpened = true;
      _openThread(thread: thread);
    } else if (args != null) {
      _autoOpened = true;
      _openThread(args: args);
    }
  }

  Future<void> _openThread({ChatThreadModel? thread, ChatViewArguments? args}) async {
    final participant = thread?.otherParticipant(_currentUserId);
    final targetArgs = args ?? ChatViewArguments(
      userId: participant?.userId,
      displayName: participant?.displayName,
      avatar: participant?.avatar,
    );

    if (targetArgs.userId == null || targetArgs.userId!.isEmpty) {
      _showSnack('Không tìm thấy thông tin người nhận.');
      return;
    }

    final updatedThread = await Navigator.of(context).push<ChatThreadModel>(
      MaterialPageRoute(
        builder: (_) => ChatDetailView(
          initialThread: thread?.id.isNotEmpty == true ? thread : null,
          targetUserId: targetArgs.userId,
          targetDisplayName: targetArgs.displayName,
          targetAvatar: targetArgs.avatar,
        ),
      ),
    );

    if (!mounted || updatedThread == null) return;
    setState(() {
      _upsertThread(updatedThread.copyWith(unreadCountOverride: 0));
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      extendBodyBehindAppBar: true,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: _backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPresenceStrip(),
            const SizedBox(height: 8),
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titleStyle = GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111827),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Tin nhắn', style: titleStyle),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/search'),
                icon: Icon(Icons.person_add_alt, color: _primaryColor),
                tooltip: AppLocalizations.of(context)!.search_title,
              ),
              IconButton(
                onPressed: () async {
                  final created = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateGroupView()));
                  if (created != null) {
                    // optionally reload threads to show group
                    _loadThreads();
                  }
                },
                icon: Icon(Icons.group_add, color: _primaryColor),
                tooltip: AppLocalizations.of(context)!.create_group_title,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: _handleSearchChanged,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF111827)),
            cursorColor: _primaryColor,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: _mutedText),
              hintText: 'Tìm kiếm trong tin nhắn',
              hintStyle: GoogleFonts.plusJakartaSans(color: _mutedText),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _mutedText.withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _mutedText.withOpacity(0.15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceStrip() {
    final items = _threads.take(10).toList();
    if (items.isEmpty) {
      return const SizedBox(height: 12);
    }
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemBuilder: (context, index) {
          final thread = items[index];
          final participant = thread.otherParticipant(_currentUserId);
          final label = participant?.displayName ?? 'Bạn bè';
          return GestureDetector(
            onTap: () => _openThread(thread: thread),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50]),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: (participant?.avatar != null && participant!.avatar!.isNotEmpty)
                        ? NetworkImage(participant.avatar!)
                        : null,
                    child: (participant?.avatar == null || participant!.avatar!.isEmpty)
                        ? Text(
                            _initialFor(participant?.displayName),
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 68,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _mutedText),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: items.length,
      ),
    );
  }

  Widget _buildContentArea() {
    if (_loading && !_refreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildStateMessage(
        icon: Icons.cloud_off,
        message: 'Không thể tải danh sách chat',
        action: () => _loadThreads(),
        actionLabel: 'Thử lại',
      );
    }

    if (_threads.isEmpty) {
      return _buildStateMessage(
        icon: Icons.forum_outlined,
        message: 'Hãy bắt đầu cuộc trò chuyện đầu tiên với bạn bè.',
        action: () => Navigator.pushNamed(context, '/search'),
        actionLabel: 'Tìm bạn bè',
      );
    }

    final display = _displayThreads;
    if (display.isEmpty) {
      return _buildStateMessage(
        icon: Icons.search_off,
        message: 'Không tìm thấy cuộc trò chuyện phù hợp.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadThreads(refresh: true),
      color: _primaryColor,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        itemBuilder: (context, index) {
          final thread = display[index];
          return _buildThreadTile(thread);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: display.length,
      ),
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required String message,
    VoidCallback? action,
    String? actionLabel,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 52, color: _mutedText),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: _mutedText, fontSize: 15),
          ),
        ),
        if (action != null && actionLabel != null) ...[
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(actionLabel),
          )
        ]
      ],
    );
  }

  Widget _buildThreadTile(ChatThreadModel thread) {
    final participant = thread.otherParticipant(_currentUserId);
    final unread = thread.unreadCount > 0;
    final accent = unread ? _primaryColor : const Color(0xFFE5E7EB);
    final preview = _threadPreview(thread);
    return GestureDetector(
      onTap: () => _openThread(thread: thread),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withOpacity(unread ? 0.6 : 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (participant?.avatar != null && participant!.avatar!.isNotEmpty)
                      ? NetworkImage(participant.avatar!)
                      : null,
                  backgroundColor: const Color(0xFFF3F4F6),
                  child: (participant?.avatar == null || participant!.avatar!.isEmpty)
                      ? Text(
                          _initialFor(participant?.displayName),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: unread ? _primaryColor : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          participant?.displayName ?? 'Người dùng',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimestamp(thread.lastMessageAt),
                        style: GoogleFonts.plusJakartaSans(
                          color: _mutedText,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: unread ? _primaryColor : _mutedText,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
            if (unread)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  thread.unreadCount.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  String _threadPreview(ChatThreadModel thread) {
    if (thread.lastMessage != null && thread.lastMessage!.trim().isNotEmpty) {
      return thread.lastMessage!.trim();
    }
    return thread.lastSenderId == _currentUserId ? 'Bạn đã gửi một tin nhắn' : 'Đối phương đã gửi tin nhắn';
  }

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) {
      return _timeFormat.format(time);
    }
    return DateFormat('dd/MM').format(time);
  }

  ChatThreadModel? _findThreadByUserId(String userId) {
    for (final thread in _threads) {
      if (thread.includesUser(userId)) {
        return thread;
      }
    }
    return null;
  }

  String _initialFor(String? text) {
    if (text == null || text.trim().isEmpty) {
      return '?';
    }
    final trimmed = text.trim();
    return trimmed.substring(0, 1).toUpperCase();
  }
}
