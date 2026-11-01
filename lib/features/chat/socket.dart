import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/env.dart';
import 'package:mobile/core/storage/storages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Managed Socket.IO lifecycle — single connection, auth handshake, auto-reconnect.
class MessagingSocket {
  MessagingSocket();
  IO.Socket? _s;
  final _listeners = <String, void Function(dynamic)>{};

  Future<void> connect() async {
    if (_s?.connected == true) return;
    final token = await SecureStore.access;
    _s = IO.io('${Env.socketUrl}/messaging', IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableReconnection()
      .setReconnectionDelay(1500)
      .build());
    for (final e in _listeners.entries) { _s!.on(e.key, e.value); }
    _s!.connect();
  }

  void on(String event, void Function(dynamic) cb) {
    _listeners[event] = cb;
    _s?.on(event, cb);
  }

  void off(String event) { _listeners.remove(event); _s?.off(event); }
  void emit(String event, dynamic data) => _s?.emit(event, data);
  void join(String convId) => emit('conversation:join', {'conversationId': convId});
  void leave(String convId) => emit('conversation:leave', {'conversationId': convId});
  void typingStart(String convId) => emit('typing:start', {'conversationId': convId});
  void typingStop(String convId) => emit('typing:stop', {'conversationId': convId});
  void disconnect() { _s?.disconnect(); _s = null; }
  bool get connected => _s?.connected ?? false;
}

final socketProvider = Provider<MessagingSocket>((ref) => MessagingSocket());
