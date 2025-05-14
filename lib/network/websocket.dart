import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Websocket {
  final Uri _uri;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _connecting = false;

  Websocket(String url) : _uri = Uri.parse(url);

  bool get isConnecting => _connecting;

  bool isConnected() {
    return _channel != null && _channel!.closeCode == null;
  }

  Future<bool> connect({Duration timeout = const Duration(seconds: 5)}) async {
    if (_connecting || isConnected()) return isConnected();
    _connecting = true;

    try {
      final tempChannel = IOWebSocketChannel.connect(
        _uri,
        pingInterval: const Duration(seconds: 10),
        connectTimeout: timeout,
      );

      final completer = Completer<bool>();

      _subscription = tempChannel.stream.listen(
            (event) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (error) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );

      bool success = await completer.future.timeout(timeout);

      if (success) {
        _channel = tempChannel;
        return true;
      } else {
        await tempChannel.sink.close();
        return false;
      }
    } on TimeoutException {
      print('WebSocket connection timed out (attempt ');
      return false;
    } catch (e) {
      print('WebSocket error: $e');
      return false;
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
  }

  Future<bool> sendMessage(String message) async {
    if (isConnected()) {
      _channel!.sink.add(message);
      return true;
    }
    return false;
  }

  Future<bool> sendJsonMessage(Map<String, dynamic> message) async {
    return sendMessage(jsonEncode(message));
  }

  void listen({
    required void Function(String) onMessageReceived,
    required VoidCallback onDone,
    required void Function(String) onError,
  }) {
    _channel?.stream.listen(
          (message) => onMessageReceived(message),
      onError: (error) => onError(error.toString()),
      onDone: onDone,
    );
  }
}
