import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../Model/ChatModels.dart';
import '../../Repository/ChatRepository.dart';
import '../../Service/ChatSocketManager.dart';
import '../../Utils.dart';

class ChatDetailView extends StatefulWidget {
  final ChatThreadModel? initialThread;
  final String? targetUserId;
  final String? targetDisplayName;
  final String? targetAvatar;

  const ChatDetailView({
    super.key,
    this.initialThread,
    this.targetUserId,
    this.targetDisplayName,
    this.targetAvatar,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final _repo = ChatRepository();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessageModel>[];
  final _dateFormat = DateFormat('HH:mm');
  final _primaryColor = const Color(0xFF1877F2);
  final _mutedColor = const Color(0xFF6B7280);
  final _background = const Color(0xFFF6F7FB);

  ChatThreadModel? _thread;
  String? _targetUserId;
  String? _targetName;
  String? _targetAvatar;
  String? _error;
  bool _loading = true;
  bool _sending = false;
  bool _fetchingOlder = false;
  bool _hasMore = true;
  String? _nextCursor;
  StreamSubscription<ChatSocketMessageEvent>? _messageSub;
  bool _uploadingMedia = false;

  String? get _currentUserId => Utils.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _thread = widget.initialThread;
    final other = _thread?.otherParticipant(_currentUserId);
    _targetUserId = widget.targetUserId ?? other?.userId;
    _targetName = widget.targetDisplayName ?? other?.displayName;
    _targetAvatar = widget.targetAvatar ?? other?.avatar;
    ChatSocketManager.instance.ensureConnected();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    ChatSocketManager.instance.leaveThread(_thread?.id);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    final threadId = _thread?.id;
    if (threadId == null) {
      setState(() {
        _loading = false;
        _hasMore = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.fetchMessages(threadId, limit: 30);
      setState(() {
        _thread = result.thread;
        _messages
          ..clear()
          ..addAll(result.messages);
        _hasMore = result.hasMore;
        _nextCursor = result.nextCursor;
        _loading = false;
      });
      ChatSocketManager.instance.joinThread(threadId);
      _subscribeToSocket(threadId);
      _scrollToBottom();
      _markThreadAsRead();
    } catch (e) {
      setState(() {
        _error = 'Không thể tải tin nhắn';
        _loading = false;
      });
    }
  }

  void _subscribeToSocket(String threadId) {
    _messageSub?.cancel();
    _messageSub = ChatSocketManager.instance.messages.listen((event) {
      if (event.thread.id != threadId) return;
      setState(() {
        _thread = event.thread;
        _upsertMessage(event.message);
      });
      _scrollToBottom();
      _markThreadAsRead();
    });
  }

  Future<void> _loadOlderMessages() async {
    if (!_hasMore || _fetchingOlder || _thread?.id == null) {
      return;
    }

    setState(() => _fetchingOlder = true);
    try {
      final result = await _repo.fetchMessages(
        _thread!.id,
        before: _nextCursor,
        limit: 20,
      );
      setState(() {
        _thread = result.thread;
        _messages.insertAll(0, result.messages);
        _hasMore = result.hasMore;
        _nextCursor = result.nextCursor;
        _fetchingOlder = false;
      });
    } catch (_) {
      setState(() => _fetchingOlder = false);
    }
  }

  Future<void> _sendMessage({String? overrideContent, List<ChatAttachment>? attachments}) async {
    if (_targetUserId == null || _sending) {
      if (_targetUserId == null) {
        _showSnack('Không xác định người nhận.');
      }
      return;
    }

    final shouldClearInput = overrideContent == null;
    final rawText = overrideContent ?? _inputController.text;
    final text = rawText.trim();
    final hasText = text.isNotEmpty;
    final hasAttachments = attachments != null && attachments.isNotEmpty;
    if (!hasText && !hasAttachments) {
      return;
    }

    setState(() => _sending = true);
    try {
      if (shouldClearInput) {
        _inputController.clear();
      }
      final result = await _repo.sendMessage(
        recipientId: _targetUserId!,
        threadId: _thread?.id,
        content: hasText ? text : null,
        attachments: attachments,
      );

      final threadId = result.thread.id;
      final shouldJoinRoom = _thread?.id != threadId;
      setState(() {
        _thread = result.thread;
        _upsertMessage(result.message);
      });
      if (shouldJoinRoom) {
        ChatSocketManager.instance.joinThread(threadId);
        _subscribeToSocket(threadId);
      }
      _scrollToBottom();
      _markThreadAsRead();
    } catch (e) {
      _showSnack('Gửi tin nhắn thất bại, thử lại sau.');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _handleMediaPick({required bool fromCamera}) async {
    if (_uploadingMedia || _sending) return;
    if (_targetUserId == null) {
      _showSnack('Không xác định người nhận.');
      return;
    }

    final picker = ImagePicker();
    try {
      setState(() => _uploadingMedia = true);
      List<XFile> files = [];
      if (fromCamera) {
        final captured = await picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 2048);
        if (captured != null) files = [captured];
      } else {
        files = await picker.pickMultiImage(imageQuality: 80, maxWidth: 2048);
      }
      if (files.isEmpty) return;

      final attachments = await _repo.uploadImages(files.map((f) => f.path).toList());
      if (attachments.isEmpty) {
        _showSnack('Không thể tải hình ảnh, thử lại sau.');
        return;
      }
      await _sendMessage(overrideContent: '', attachments: attachments);
    } catch (e) {
      _showSnack('Không thể chọn hoặc tải hình ảnh. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _uploadingMedia = false);
      }
    }
  }

  Future<void> _markThreadAsRead() async {
    final threadId = _thread?.id;
    if (threadId == null) return;
    final updated = await _repo.markThreadRead(threadId);
    if (updated != null && mounted) {
      setState(() => _thread = updated);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 48,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _upsertMessage(ChatMessageModel message) {
    // Prevent duplicate entries when both local send result and socket echo arrive.
    final existingIndex = _messages.indexWhere((m) => m.id == message.id);
    if (existingIndex >= 0) {
      _messages[existingIndex] = message;
    } else {
      _messages.add(message);
    }
  }

  Future<bool> _handleWillPop() async {
    Navigator.of(context).pop(_thread);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final title = _targetName ?? 'Chat';
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => _handleWillPop(),
              ),
              titleSpacing: 0,
              actions: [
                IconButton(
                  onPressed: () => _showSnack('Tính năng gọi sẽ có sau'),
                  icon: Icon(Icons.videocam_outlined, color: _primaryColor),
                ),
                IconButton(
                  onPressed: () => _showSnack('Tính năng thông tin sẽ có sau'),
                  icon: Icon(Icons.info_outline, color: _mutedColor),
                )
              ],
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: (_targetAvatar != null && _targetAvatar!.isNotEmpty)
                        ? NetworkImage(_targetAvatar!)
                        : null,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: (_targetAvatar == null || _targetAvatar!.isEmpty)
                        ? Text(
                            title.isNotEmpty ? title[0].toUpperCase() : '?',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Đang hoạt động',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: _mutedColor,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: _background,
          child: Column(
            children: [
              Expanded(child: _buildMessageArea()),
              _buildComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageArea() {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadInitialMessages, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _loadOlderMessages,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        itemCount: _messages.length + (_fetchingOlder ? 1 : 0),
        itemBuilder: (context, index) {
          if (_fetchingOlder && index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          final messageIndex = _fetchingOlder ? index - 1 : index;
          final message = _messages[messageIndex];
          final isMine = message.senderId == _currentUserId;
          return _buildMessageBubble(message, isMine);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMine) {
    final hasText = message.hasText;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: isMine ? 8 : 0),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: (_targetAvatar != null && _targetAvatar!.isNotEmpty)
                  ? NetworkImage(_targetAvatar!)
                  : null,
              backgroundColor: const Color(0xFFF3F4F6),
              child: (_targetAvatar == null || _targetAvatar!.isEmpty)
                  ? Text(_targetName?.isNotEmpty == true ? _targetName![0].toUpperCase() : '?',
                      style: const TextStyle(color: Color(0xFF1F2937)))
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.hasAttachments)
                  ...message.attachments.map((attachment) => _buildImageAttachment(attachment, isMine)).toList(),
                if (message.hasAttachments && hasText) const SizedBox(height: 6),
                if (hasText)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMine ? _primaryColor : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMine ? 20 : 6),
                        bottomRight: Radius.circular(isMine ? 6 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      message.content!.trim(),
                      style: GoogleFonts.plusJakartaSans(
                        color: isMine ? Colors.white : const Color(0xFF111827),
                        fontSize: 15,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _dateFormat.format(message.createdAt),
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _mutedColor),
                )
              ],
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_rounded, size: 16, color: _mutedColor),
          ]
        ],
      ),
    );
  }

  Widget _buildImageAttachment(ChatAttachment attachment, bool isMine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints: const BoxConstraints(maxWidth: 260, minWidth: 140, minHeight: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMine ? 18 : 8),
          topRight: Radius.circular(isMine ? 8 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMine ? 18 : 8),
          topRight: Radius.circular(isMine ? 8 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Image.network(
            attachment.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    final canSend = !_sending && _targetUserId != null;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: (_uploadingMedia || _sending) ? null : () => _handleMediaPick(fromCamera: false),
              icon: Icon(Icons.photo_outlined,
                  color: (_uploadingMedia || _sending) ? _mutedColor.withOpacity(0.5) : _mutedColor),
            ),
            IconButton(
              onPressed: (_uploadingMedia || _sending) ? null : () => _handleMediaPick(fromCamera: true),
              icon: Icon(Icons.camera_alt_outlined,
                  color: (_uploadingMedia || _sending) ? _mutedColor.withOpacity(0.5) : _mutedColor),
            ),
            if (_uploadingMedia)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'Nhắn gì đó...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: _mutedColor),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: canSend
                    ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF5B8CFF)])
                    : null,
                color: canSend ? null : _mutedColor.withOpacity(0.2),
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: canSend ? () => _sendMessage() : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
