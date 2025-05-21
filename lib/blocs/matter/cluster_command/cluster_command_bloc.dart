import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:dashboard/network/websocket_client.dart';

part 'cluster_command_event.dart';
part 'cluster_command_state.dart';

class ClusterCommandBloc extends Bloc<ClusterCommandEvent, ClusterCommandState> {
  final WebSocketClient websocket;
  StreamSubscription<dynamic>? _messageSubscription;

  ClusterCommandBloc({required this.websocket}) : super(ClusterCommandInitial()) {
    on<ClusterCommandRequested>(_onCommandRequested);
    on<ClusterCommandMessageReceived>(_onMessageReceived);
    on<ClusterCommandReset>(_onReset);

    _setupWebSocketListener();
  }

  Future<void> _onCommandRequested(
      ClusterCommandRequested event,
      Emitter<ClusterCommandState> emit,
      ) async {
    print('ClusterCommandRequested event: $event');

    try {
      final message = {
        'command': 'invoke_cluster_command',
        'payload': {
          'destination_id': event.destinationId,
          'endpoint_id': event.endpointId,
          'cluster_id': event.clusterId,
          'command_id': event.commandId,
          'command_data': event.commandData,
        },
      };

      print('Sending JSON message: $message');

      await websocket.sendJsonMessage(message);
    } catch (e) {
      emit(ClusterCommandFailure(e.toString()));
    }
  }

  void _onMessageReceived(
      ClusterCommandMessageReceived event,
      Emitter<ClusterCommandState> emit,
      ) {
    print('ClusterCommandMessageReceived event: $event');

    try {
      final json = jsonDecode(event.message) as Map<String, dynamic>;
      final command = json['command'] as String;
      final payload = json['payload'] as Map<String, dynamic>? ?? {};

      print('Received JSON message: $json');

      switch (command) {
        case 'invoke_cluster_command_success':
          emit(ClusterCommandSuccess());
          break;
        case 'invoke_cluster_command_error':
          emit(ClusterCommandFailure(payload['error'] as String? ?? "Unknown error"));
          break;
      }
    } catch (e) {
      emit(ClusterCommandFailure('Failed to parse message: ${e.toString()}'));
    }
  }

  void _onReset(
      ClusterCommandReset event,
      Emitter<ClusterCommandState> emit,
      ) {
    emit(ClusterCommandInitial());
  }

  void _setupWebSocketListener() {
    _messageSubscription?.cancel();
    _messageSubscription = (websocket.channel)?.stream.listen(
          (message) {
        if (message is String) {
          add(ClusterCommandMessageReceived(message));
        }
      },
      onError: (error) => emit(ClusterCommandFailure(error.toString())),
      onDone: () => emit(ClusterCommandFailure('Connection closed')),
    );
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
