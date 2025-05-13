import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/network/websocket.dart';

part 'read_attribute_command_event.dart';
part 'read_attribute_command_state.dart';

class ReadAttributeCommandBloc extends Bloc<ReadAttributeCommandEvent, ReadAttributeCommandState> {
  final Websocket websocket;
  StreamSubscription<dynamic>? _messageSubscription;

  ReadAttributeCommandBloc({required this.websocket}) : super(ReadAttributeCommandInitial()) {
    on<ReadAttributeCommandRequested>(_onCommandRequested);
    on<ReadAttributeCommandMessageReceived>(_onMessageReceived);
    on<ReadAttributeCommandReset>(_onReset);

    _setupWebSocketListener();
  }

  Future<void> _onCommandRequested(
      ReadAttributeCommandRequested event,
      Emitter<ReadAttributeCommandState> emit,
      ) async {
    print('ReadAttributeCommandRequested event: $event');

    try {
      final message = {
        'command': 'send_read_attr_command',
        'payload': {
          'node_id': event.nodeId,
          'endpoint_id': event.endpointId,
          'cluster_id': event.clusterId,
          'attribute_id': event.attributeId,
        },
      };

      print('Sending JSON message: $message');
      await websocket.sendJsonMessage(message);
    } catch (e) {
      emit(ReadAttributeCommandFailure(e.toString()));
    }
  }

  void _onMessageReceived(
      ReadAttributeCommandMessageReceived event,
      Emitter<ReadAttributeCommandState> emit,
      ) {
    print('ReadAttributeCommandMessageReceived event: $event');

    try {
      final jsonData = jsonDecode(event.message) as Map<String, dynamic>;
      final command = jsonData['command'] as String;
      final payload = jsonData['payload'] as Map<String, dynamic>? ?? {};

      print('Received JSON message: $jsonData');

      switch (command) {
        case 'read_attr_command_success':
          emit(ReadAttributeCommandSuccess(payload: payload));
          break;
        case 'read_attr_command_error':
          emit(ReadAttributeCommandFailure(payload['error'] as String? ?? "Unknown error"));
          break;
        default:
        // Handle unexpected commands if needed.
          break;
      }
    } catch (e) {
      emit(ReadAttributeCommandFailure('Failed to parse message: ${e.toString()}'));
    }
  }

  void _onReset(
      ReadAttributeCommandReset event,
      Emitter<ReadAttributeCommandState> emit,
      ) {
    emit(ReadAttributeCommandInitial());
  }

  void _setupWebSocketListener() {
    _messageSubscription?.cancel();
    _messageSubscription = (websocket.channel)?.stream.listen(
          (message) {
        if (message is String) {
          add(ReadAttributeCommandMessageReceived(message));
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
