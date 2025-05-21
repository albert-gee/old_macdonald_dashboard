import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/network/websocket_client.dart';

part 'subscribe_attribute_command_event.dart';
part 'subscribe_attribute_command_state.dart';

class SubscribeAttributeCommandBloc extends Bloc<SubscribeAttributeCommandEvent, SubscribeAttributeCommandState> {
  final WebSocketClient websocket;
  StreamSubscription<dynamic>? _messageSubscription;

  SubscribeAttributeCommandBloc({required this.websocket}) : super(SubscribeAttributeCommandInitial()) {
    on<SubscribeAttributeCommandRequested>(_onCommandRequested);
    on<SubscribeAttributeCommandMessageReceived>(_onMessageReceived);
    on<SubscribeAttributeCommandReset>(_onReset);

    _setupWebSocketListener();
  }

  Future<void> _onCommandRequested(
      SubscribeAttributeCommandRequested event,
      Emitter<SubscribeAttributeCommandState> emit,
      ) async {
    print('SubscribeAttributeCommandRequested event: $event');

    try {
      final message = {
        'command': 'send_subscribe_attr_command',
        'payload': {
          'node_id': event.nodeId,
          'endpoint_id': event.endpointId,
          'cluster_id': event.clusterId,
          'attribute_id': event.attributeId,
          'min_interval': event.minInterval,
          'max_interval': event.maxInterval,
        },
      };

      print('Sending JSON message: $message');
      await websocket.sendJsonMessage(message);
    } catch (e) {
      emit(SubscribeAttributeCommandFailure(e.toString()));
    }
  }

  void _onMessageReceived(
      SubscribeAttributeCommandMessageReceived event,
      Emitter<SubscribeAttributeCommandState> emit,
      ) {
    print('SubscribeAttributeCommandMessageReceived event: $event');

    try {
      final jsonData = jsonDecode(event.message) as Map<String, dynamic>;
      final command = jsonData['command'] as String;
      final payload = jsonData['payload'] as Map<String, dynamic>? ?? {};

      print('Received JSON message: $jsonData');

      switch (command) {
        case 'subscribe_attr_command_success':
          emit(SubscribeAttributeCommandSuccess(payload: payload));
          break;
        case 'subscribe_attr_command_error':
          emit(SubscribeAttributeCommandFailure(payload['error'] as String? ?? "Unknown error"));
          break;
        default:
          break;
      }
    } catch (e) {
      emit(SubscribeAttributeCommandFailure('Failed to parse message: ${e.toString()}'));
    }
  }

  void _onReset(
      SubscribeAttributeCommandReset event,
      Emitter<SubscribeAttributeCommandState> emit,
      ) {
    emit(SubscribeAttributeCommandInitial());
  }

  void _setupWebSocketListener() {
    _messageSubscription?.cancel();
    _messageSubscription = (websocket.channel)?.stream.listen(
          (message) {
        if (message is String) {
          add(SubscribeAttributeCommandMessageReceived(message));
        }
      },
      onError: (error) => addError(error),
      onDone: () => addError('Connection closed'),
    );
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
