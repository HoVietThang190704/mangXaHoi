import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../Model/ChatModels.dart';
import '../Utils.dart';
import '../services/api_service.dart';

class ChatSocketMessageEvent {
  final ChatThreadModel thread;
  final ChatMessageModel message;

  ChatSocketMessageEvent({required this.thread, required this.message});
}

class ChatSocketManager {
  ChatSocketManager._();
  static final ChatSocketManager instance = ChatSocketManager._();

  IO.Socket? _socket;
  bool _connecting = false;
  final _messageController = StreamController<ChatSocketMessageEvent>.broadcast();
  final _threadController = StreamController<ChatThreadModel>.broadcast();

  Stream<ChatSocketMessageEvent> get messages => _messageController.stream;
  Stream<ChatThreadModel> get threadUpdates => _threadController.stream;

  Future<void> ensureConnected() async {
    if (_socket != null) {
      if (_socket!.connected) return;
      if (!_connecting) {
        _socket!.connect();
      }
      return;
    }

    final token = Utils.accessToken;
    if (token == null || token.isEmpty) {
      return;
    }

    _connecting = true;
    try {
      final baseUrl = await ApiService.getBaseUrl();
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableReconnection()
            .setAuth({'token': token})
            .build(),
      );

      _socket!
        ..onConnect((_) {
          _connecting = false;
        })
        ..onConnectError((error) {
          _connecting = false;
        })
        ..onDisconnect((_) {})
        ..on('friend-chat:new-message', (data) {
          final event = _parseMessageEvent(data);
          if (event != null) {
            _messageController.add(event);
          }
        })
        ..on('friend-chat:thread-update', (data) {
          final thread = _parseThread(data);
          if (thread != null) {
            _threadController.add(thread);
          }
        });

      _socket!.connect();
    } catch (e) {
      _connecting = false;
    }
  }

  void joinThread(String threadId) {
    if (threadId.isEmpty) return;
    _socket?.emit('friend-chat:join-thread', {'threadId': threadId});
  }

  void leaveThread(String? threadId) {
    if (threadId == null || threadId.isEmpty) return;
    _socket?.emit('friend-chat:leave-thread', {'threadId': threadId});
  }

  void sendTyping(String threadId, bool isTyping) {
    if (threadId.isEmpty) return;
    _socket?.emit('friend-chat:typing', {'threadId': threadId, 'isTyping': isTyping});
  }

  ChatSocketMessageEvent? _parseMessageEvent(dynamic data) {
    if (data is! Map) return null;
    final threadJson = data['thread'];
    final messageJson = data['message'];
    if (threadJson is! Map || messageJson is! Map) return null;
    final thread = ChatThreadModel.fromJson(Map<String, dynamic>.from(threadJson as Map));
    final message = ChatMessageModel.fromJson(Map<String, dynamic>.from(messageJson as Map));
    return ChatSocketMessageEvent(thread: thread, message: message);
  }

  ChatThreadModel? _parseThread(dynamic data) {
    if (data is! Map) return null;
    return ChatThreadModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _connecting = false;
  }
}
