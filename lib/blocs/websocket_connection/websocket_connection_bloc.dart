import 'dart:async';
import 'package:dashboard/network/websocket.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/models/websocket_message.dart';

part 'websocket_connection_event.dart';
part 'websocket_connection_state.dart';

class WebsocketConnectionBloc extends Bloc<WebsocketConnectionEvent, WebsocketConnectionState> {
  final WebSocketMessageParser messageParser;
  final Websocket websocket;
  final void Function(WebSocketMessage) onMessageReceived;
  final void Function() onWebsocketDone;

  StreamSubscription? _streamSub;

  WebsocketConnectionBloc({
    required this.messageParser,
    required this.websocket,
    required this.onMessageReceived,
    required this.onWebsocketDone,
  }) : super(WebsocketConnectionDisconnectedState()) {
    on<WebsocketConnectionConnectingEvent>(_onConnecting);
    on<WebsocketConnectionDisconnectingEvent>(_onDisconnecting);
    on<WebsocketConnectionDisconnectedEvent>(_onDisconnected);
  }

  Future<void> _onConnecting(
      WebsocketConnectionConnectingEvent event,
      Emitter<WebsocketConnectionState> emit,
      ) async {
    emit(WebsocketConnectionConnectingState());

    try {
      final ws = await _connect();
      if (ws != null) {
        emit(WebsocketConnectionConnectedState());
      } else {
        emit(const WebsocketConnectionErrorState('Failed to connect'));
      }
    } catch (e) {
      emit(WebsocketConnectionErrorState('Error: $e'));
    }
  }

  Future<void> _onDisconnecting(
      WebsocketConnectionDisconnectingEvent event,
      Emitter<WebsocketConnectionState> emit,
      ) async {
    await _disconnect();
    emit(WebsocketConnectionDisconnectedState());
  }

  void _onDisconnected(
      WebsocketConnectionDisconnectedEvent event,
      Emitter<WebsocketConnectionState> emit,
      ) {
    emit(WebsocketConnectionDisconnectedState());
  }

  Future<Websocket?> _connect() async {
    if (websocket.isConnected()) return websocket;

    const maxAttempts = 5;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final success = await websocket.connect(timeout: const Duration(seconds: 5));
        if (success && websocket.isConnected()) {
          await _streamSub?.cancel();

          websocket.listen(
            onMessageReceived: _handleRawMessage,
            onDone: () {
              onWebsocketDone();
              add(const WebsocketConnectionDisconnectedEvent());
            },
            onError: (_) {
              add(const WebsocketConnectionDisconnectedEvent());
            },
          );

          return websocket;
        }
      } on TimeoutException {
        print('WebSocket connection timed out (attempt ${attempt + 1})');
      } catch (e) {
        print('WebSocket connection error (attempt ${attempt + 1}): $e');
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    return null;
  }

  Future<void> _disconnect() async {
    await _streamSub?.cancel();
    _streamSub = null;
    await websocket.disconnect();
  }

  void _handleRawMessage(String message) {
    try {
      final parsed = messageParser.parse(message);
      onMessageReceived(parsed);
    } on MessageParseException catch (e) {
      print('Error parsing message: ${e.message}');
    } catch (e) {
      print('Unexpected error parsing message: $e');
    }
  }

  @override
  Future<void> close() async {
    await _streamSub?.cancel();
    return super.close();
  }
}
