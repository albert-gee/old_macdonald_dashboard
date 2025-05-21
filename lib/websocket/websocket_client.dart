import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class WebSocketClient {
  WebSocket? _socket;
  StreamController<String>? _controller;
  bool _connecting = false;

  bool get isConnecting => _connecting;

  bool isConnected() {
    return _socket != null && _socket!.readyState == WebSocket.open;
  }

  Future<bool> connect({
    required String urlStr,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_connecting || isConnected()) return isConnected();
    _connecting = true;

    try {
      final context = SecurityContext();
      final rootCA = await rootBundle.loadString('assets/rootCA.pem');
      context.setTrustedCertificatesBytes(utf8.encode(rootCA));

      final socket = await WebSocket.connect(
        urlStr,
        customClient: HttpClient(context: context),
      );

      socket.pingInterval = const Duration(seconds: 10);
      _socket = socket;

      _controller = StreamController<String>();
      _socket!.listen(
            (event) => _controller!.add(event.toString()),
        onDone: () => _controller?.close(),
        onError: (error) => _controller?.addError(error),
        cancelOnError: true,
      );

      return true;
    } catch (e) {
      print('WebSocket connection failed: $e');
      return false;
    } finally {
      _connecting = false;
    }
  }

  Stream<String> get stream {
    if (_controller == null) throw StateError('Stream is not initialized');
    return _controller!.stream;
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    await _controller?.close();
    _controller = null;
  }

  Future<bool> sendMessage(String message) async {
    if (isConnected()) {
      _socket!.add(message);
      return true;
    }
    return false;
  }

  Future<bool> sendJsonMessage(Map<String, dynamic> json) async {
    return sendMessage(jsonEncode(json));
  }

  void listen({
    required void Function(String) onMessageReceived,
    required VoidCallback onDone,
    required void Function(String) onError,
  }) {
    stream.listen(
      onMessageReceived,
      onDone: onDone,
      onError: (error) => onError(error.toString()),
      cancelOnError: true,
    );
  }
}
