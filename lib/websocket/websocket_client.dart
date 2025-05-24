import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

/// A secure WebSocket client with optional TLS root CA and stream handling.
class WebSocketClient {
  WebSocket? _socket;
  bool _connecting = false;

  /// Whether the client is currently attempting to connect.
  bool get isConnecting => _connecting;

  /// Whether the WebSocket is connected and open.
  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  /// Stream of incoming string messages.
  ///
  /// Throws [StateError] if called before the connection is established.
  Stream<String> get messages {
    final socket = _socket;
    if (socket == null) {
      throw StateError('WebSocket connection not established.');
    }
    return socket.cast<String>();
  }

  /// Connects to the WebSocket server.
  ///
  /// [url] must be a `ws://` or `wss://` URI.
  /// Optionally provide [rootCAAsset] for secure TLS (wss).
  Future<bool> connect({
    required String url,
    String? rootCAAsset,
    bool enableCompression = true,
    Duration pingInterval = const Duration(seconds: 10),
  }) async {
    if (_connecting) return false;
    if (isConnected) return true;

    _connecting = true;
    try {
      // Set up a security context
      SecurityContext? context;
      if (url.startsWith('wss://') && rootCAAsset != null) {
        final certData = await rootBundle.loadString(rootCAAsset);
        context = SecurityContext();
        context.setTrustedCertificatesBytes(utf8.encode(certData));
      }

      // Connect to the WebSocket server
      _socket = await WebSocket.connect(
        url,
        compression: enableCompression
            ? CompressionOptions.compressionDefault
            : CompressionOptions.compressionOff,
        customClient: context != null ? HttpClient(context: context) : null,
      );

      // Client ping disabled — relying on server-side ping for keep-alive.
      _socket!.pingInterval = null;

      return true;
    } catch (e) {
      print('WebSocket connection failed: $e');
      return false;
    } finally {
      _connecting = false;
    }
  }

  /// Sends a string message over the WebSocket.
  ///
  /// Returns `true` if the message was sent.
  Future<bool> sendMessage(String message) async {
    if (!isConnected) return false;
    _socket!.add(message);
    return true;
  }

  /// Closes the WebSocket connection gracefully.
  Future<void> disconnect({
    int code = WebSocketStatus.normalClosure,
    String reason = 'Client disconnect',
  }) async {
    await _socket?.close(code, reason);
    _socket = null;
  }

  /// Adds listeners for incoming messages, errors, and close events.
  ///
  /// You can use [messages] for stream-based handling instead.
  void listen({
    required void Function(String) onMessage,
    required VoidCallback onDone,
    required void Function(Object error) onError,
  }) {
    final socket = _socket;
    if (socket == null) {
      throw StateError('WebSocket not connected.');
    }

    socket.listen(
      (event) {
        if (event is String) onMessage(event);
      },
      onDone: onDone,
      onError: onError,
      cancelOnError: true,
    );
  }

  /// Returns the WebSocket close code, if any.
  int? get closeCode => _socket?.closeCode;

  /// Returns the WebSocket close reason, if any.
  String? get closeReason => _socket?.closeReason;
}
