import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'i_websocket_client.dart';

/// A secure WebSocket client with optional TLS root CA and stream handling.
class WebSocketClient implements IWebSocketClient {
  WebSocket? _socket;
  bool _connecting = false;
  final Logger _logger = Logger();

  /// Whether the client is currently attempting to connect.
  @override
  bool get isConnecting => _connecting;

  /// Whether the WebSocket is connected and open.
  @override
  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  /// Stream of incoming string messages.
  ///
  /// Throws [StateError] if called before the connection is established.
  @override
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
  @override
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

      _socket!.pingInterval = pingInterval;

      return true;
    } catch (e) {
      _logger.e('WebSocket connection failed', error: e);
      return false;
    } finally {
      _connecting = false;
    }
  }

  /// Sends a string message over the WebSocket.
  ///
  /// Returns `true` if the message was sent.
  @override
  Future<bool> sendMessage(String message) async {
    if (!isConnected) return false;
    _socket!.add(message);
    return true;
  }

  /// Closes the WebSocket connection gracefully.
  @override
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
  @override
  StreamSubscription<String> listen({
    required void Function(String) onMessage,
    required VoidCallback onDone,
    required void Function(Object error) onError,
  }) {
    final socket = _socket;
    if (socket == null) {
      throw StateError('WebSocket not connected.');
    }

    return socket.cast<String>().listen(
          onMessage,
          onDone: onDone,
          onError: onError,
          cancelOnError: true,
        );
  }

  /// Returns the WebSocket close code, if any.
  @override
  int? get closeCode => _socket?.closeCode;

  /// Returns the WebSocket close reason, if any.
  @override
  String? get closeReason => _socket?.closeReason;
}
