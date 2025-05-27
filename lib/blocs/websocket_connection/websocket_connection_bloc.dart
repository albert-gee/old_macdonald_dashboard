import 'dart:async';
import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_inbound_message_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'websocket_connection_event.dart';
part 'websocket_connection_state.dart';

class WebsocketConnectionBloc extends Bloc<WebsocketConnectionEvent, WebsocketConnectionState> {
  final WebSocketClient websocket;
  final WebSocketInboundMessageHandler messageHandler;

  StreamSubscription? _streamSub;
  String? _currentUrl;

  static const int _maxConnectionAttempts = 5;
  static const Duration _connectTimeout = Duration(seconds: 5);
  static const Duration _retryDelay = Duration(seconds: 2);

  final Logger _logger = Logger();

  WebsocketConnectionBloc({
    required this.websocket,
    required this.messageHandler,
  }) : super(WebsocketConnectionDisconnectedState()) {
    on<WebsocketConnectionConnectRequested>(_onConnectRequested);
    on<WebsocketConnectionDisconnectRequested>(_onDisconnectRequested);
    on<WebsocketConnectionDisconnected>(_onDisconnected);
  }

  Future<void> _onConnectRequested(
      WebsocketConnectionConnectRequested event,
      Emitter<WebsocketConnectionState> emit,
      ) async {
    emit(WebsocketConnectionConnectingState());
    _currentUrl = event.wsUri;
    await _saveUrl(_currentUrl!);

    try {
      final connected = await _tryConnect(_currentUrl!);
      if (connected) {
        emit(WebsocketConnectionConnectedState());
        _logger.i('WebSocket connected to \$_currentUrl');
      } else {
        emit(const WebsocketConnectionErrorState('Failed to connect'));
        _logger.w('WebSocket connection failed after \$_maxConnectionAttempts attempts');
      }
    } catch (e, stack) {
      emit(WebsocketConnectionErrorState('Error: \$e'));
      _logger.e('Unhandled WebSocket connection error', error: e, stackTrace: stack);
    }
  }

  Future<void> _saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orchestrator_url', url);
  }

  Future<void> _onDisconnectRequested(
      WebsocketConnectionDisconnectRequested event,
      Emitter<WebsocketConnectionState> emit,
      ) async {
    await _disconnect();
    emit(WebsocketConnectionDisconnectedState());
    _logger.i('WebSocket disconnected by user');
  }

  void _onDisconnected(
      WebsocketConnectionDisconnected event,
      Emitter<WebsocketConnectionState> emit,
      ) {
    emit(WebsocketConnectionDisconnectedState());
    _logger.i('WebSocket disconnected');
  }

  Future<bool> _tryConnect(String url) async {
    if (websocket.isConnected) return true;

    for (var attempt = 1; attempt <= _maxConnectionAttempts; attempt++) {
      try {
        final success = await websocket
            .connect(url: url, rootCAAsset: 'assets/rootCA.pem')
            .timeout(_connectTimeout);

        if (success) {
          await _streamSub?.cancel();
          websocket.listen(
            onMessage: _handleMessage,
            onDone: () => add(const WebsocketConnectionDisconnected()),
            onError: (_) => add(const WebsocketConnectionDisconnected()),
          );
          return true;
        }
      } on TimeoutException {
        _logger.w('Connection timed out (attempt \$attempt)');
      } catch (e, stack) {
        _logger.e('Connection error (attempt \$attempt)', error: e, stackTrace: stack);
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
    } on MessageParseException catch (e) {
      _logger.e('Message parse error: \${e.message}');
    } catch (e, stack) {
      _logger.e('Unexpected message handling error', error: e, stackTrace: stack);
    }
  }

  @override
  Future<void> close() async {
    await _streamSub?.cancel();
    return super.close();
  }
}