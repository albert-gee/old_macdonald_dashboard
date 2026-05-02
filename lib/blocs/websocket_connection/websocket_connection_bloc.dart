import 'dart:async';
import 'package:dashboard/services/i_orchestrator_url_storage.dart';
import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_inbound_message_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'websocket_connection_event.dart';
part 'websocket_connection_state.dart';

class WebsocketConnectionBloc
    extends Bloc<WebsocketConnectionEvent, WebsocketConnectionState> {
  final WebSocketClient websocket;
  final WebSocketInboundMessageHandler messageHandler;
  final IOrchestratorUrlStorage urlStorage;

  StreamSubscription<String>? _streamSub;
  String? _currentUrl;

  static const int _maxConnectionAttempts = 5;
  static const Duration _connectTimeout = Duration(seconds: 5);
  static const Duration _retryDelay = Duration(seconds: 2);

  final Logger _logger = Logger();

  WebsocketConnectionBloc({
    required this.websocket,
    required this.messageHandler,
    required this.urlStorage,
  }) : super(WebsocketConnectionDisconnectedState()) {
    on<WebsocketConnectionConnectRequested>(_onConnectRequested);
    on<WebsocketConnectionDisconnectRequested>(_onDisconnectRequested);
    on<WebsocketConnectionDisconnected>(_onDisconnected);
  }

  Future<void> _onConnectRequested(
    WebsocketConnectionConnectRequested event,
    Emitter<WebsocketConnectionState> emit,
  ) async {
    final url = event.wsUri.trim();
    if (!_isValidWebSocketUrl(url)) {
      emit(const WebsocketConnectionErrorState(
        'Enter a valid ws:// or wss:// URL.',
      ));
      return;
    }

    emit(WebsocketConnectionConnectingState());
    _currentUrl = url;
    await _disconnect();

    try {
      final connected = await _tryConnect(_currentUrl!);
      if (connected) {
        await urlStorage.saveUrl(_currentUrl!);
        emit(WebsocketConnectionConnectedState());
        _logger.i('WebSocket connected to $_currentUrl');
      } else {
        emit(const WebsocketConnectionErrorState('Failed to connect'));
        _logger.w(
            'WebSocket connection failed after $_maxConnectionAttempts attempts');
      }
    } catch (e, stack) {
      emit(const WebsocketConnectionErrorState('Failed to connect'));
      _logger.e('Unhandled WebSocket connection error',
          error: e, stackTrace: stack);
    }
  }

  bool _isValidWebSocketUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (uri.scheme != 'ws' && uri.scheme != 'wss') return false;
    return uri.host.isNotEmpty;
  }

  Future<void> _onDisconnectRequested(
    WebsocketConnectionDisconnectRequested event,
    Emitter<WebsocketConnectionState> emit,
  ) async {
    await _disconnect();
    emit(WebsocketConnectionDisconnectedState());
    _logger.i('WebSocket disconnected by user');
  }

  Future<void> _onDisconnected(
    WebsocketConnectionDisconnected event,
    Emitter<WebsocketConnectionState> emit,
  ) async {
    await _disconnect();
    emit(WebsocketConnectionDisconnectedState());
    _logger.i('WebSocket disconnected');
  }

  Future<bool> _tryConnect(String url) async {
    for (var attempt = 1; attempt <= _maxConnectionAttempts; attempt++) {
      try {
        final success =
            await websocket.connect(url: url).timeout(_connectTimeout);

        if (success) {
          await _streamSub?.cancel();
          _streamSub = null;
          _streamSub = websocket.listen(
            onMessage: _handleMessage,
            onDone: () => add(const WebsocketConnectionDisconnected()),
            onError: (_) => add(const WebsocketConnectionDisconnected()),
          );
          return true;
        }
      } on TimeoutException {
        _logger.w('Connection timed out (attempt \$attempt)');
      } catch (e, stack) {
        _logger.e('Connection error (attempt \$attempt)',
            error: e, stackTrace: stack);
      }

      await Future.delayed(_retryDelay);
    }

    return false;
  }

  Future<void> _disconnect() async {
    await _streamSub?.cancel();
    _streamSub = null;
    await websocket.disconnect();
  }

  void _handleMessage(String message) {
    try {
      messageHandler.handle(message);
    } catch (e, stack) {
      _logger.e('Unexpected message handling error',
          error: e, stackTrace: stack);
    }
  }

  @override
  Future<void> close() async {
    await _disconnect();
    return super.close();
  }
}
