import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';

abstract interface class WebSocketClient {
  bool get isConnected;
  bool get isConnecting;
  Stream<String> get messages;
  Stream<WebSocketConnectionStatus> get status;

  Future<Result<void>> connect(WebSocketConnectionSettings settings);

  Future<Result<void>> send(String message);

  Future<void> disconnect({
    int code = 1000,
    String reason = 'Client disconnect',
  });

  Future<void> dispose();
}

/// `dart:io` WebSocket implementation for local desktop/mobile dashboard builds.
///
/// This client is intentionally not web-compatible.
final class IoWebSocketClient implements WebSocketClient {
  final Logger _logger;
  final StreamController<String> _messagesController =
      StreamController<String>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  bool _connecting = false;
  String? _currentUrl;

  IoWebSocketClient({Logger? logger}) : _logger = logger ?? Logger();

  @override
  bool get isConnecting => _connecting;

  @override
  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  @override
  Stream<String> get messages => _messagesController.stream;

  @override
  Stream<WebSocketConnectionStatus> get status => _statusController.stream;

  @override
  Future<Result<void>> connect(WebSocketConnectionSettings settings) async {
    if (_connecting) return const Success(null);
    if (isConnected) {
      if (_currentUrl == settings.url) return const Success(null);
      await disconnect(reason: 'Reconnect to different URL');
    }

    _connecting = true;
    _statusController.add(WebSocketConnectionStatus.connecting);

    try {
      SecurityContext? context;
      if (settings.rootCAAsset != null) {
        final certData = await rootBundle.loadString(settings.rootCAAsset!);
        context = SecurityContext()
          ..setTrustedCertificatesBytes(utf8.encode(certData));
      }

      final socket = await WebSocket.connect(
        settings.url,
        compression: CompressionOptions.compressionDefault,
        customClient: context != null ? HttpClient(context: context) : null,
      );
      socket.pingInterval = const Duration(seconds: 10);

      await _subscription?.cancel();
      _socket = socket;
      _subscription = socket.listen(
        (message) {
          if (message is String) _messagesController.add(message);
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.e(
            'WebSocket stream error',
            error: error,
            stackTrace: stackTrace,
          );
          _statusController.add(WebSocketConnectionStatus.disconnected);
        },
        onDone: () {
          _socket = null;
          _statusController.add(WebSocketConnectionStatus.disconnected);
        },
        cancelOnError: true,
      );

      _currentUrl = settings.url;
      _statusController.add(WebSocketConnectionStatus.connected);
      return const Success(null);
    } catch (error, stackTrace) {
      _logger.e(
        'WebSocket connection failed',
        error: error,
        stackTrace: stackTrace,
      );
      _currentUrl = null;
      _statusController.add(WebSocketConnectionStatus.disconnected);
      return FailureResult(
        WebSocketConnectionFailure('Unable to connect to WebSocket.'),
      );
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<Result<void>> send(String message) async {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) {
      return const FailureResult(WebSocketDisconnectedFailure());
    }

    try {
      socket.add(message);
      return const Success(null);
    } catch (error) {
      return FailureResult(WebSocketSendFailure('Unable to send command.'));
    }
  }

  @override
  Future<void> disconnect({
    int code = 1000,
    String reason = 'Client disconnect',
  }) async {
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close(code, reason);
    _socket = null;
    _currentUrl = null;
    _statusController.add(WebSocketConnectionStatus.disconnected);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _messagesController.close();
    await _statusController.close();
  }
}
