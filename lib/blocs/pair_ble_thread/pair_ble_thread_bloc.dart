import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:dashboard/network/websocket.dart';

part 'pair_ble_thread_event.dart';
part 'pair_ble_thread_state.dart';

class PairBleThreadBloc extends Bloc<PairBleThreadEvent, PairBleThreadState> {
  final Websocket websocket;
  StreamSubscription<dynamic>? _messageSubscription;

  PairBleThreadBloc({required this.websocket}) : super(PairBleThreadInitial()) {

    on<PairBleThreadRequested>(_onPairRequested);
    on<PairBleThreadMessageReceived>(_onMessageReceived);
    on<PairBleThreadReset>(_onReset);

    _setupWebSocketListener();
  }

  Future<void> _onPairRequested(
      PairBleThreadRequested event,
      Emitter<PairBleThreadState> emit,
      ) async {
    print('PairBleThreadRequested event: $event');

    emit(PairBleThreadLoading());

    try {
      final message = {
        'command': 'pairing_ble_thread',
        'payload': {
          'node_id': event.nodeId,
          'pin': event.pin,
          'discriminator': event.discriminator,
        },
      };

      print('Sending json message: $message');

      await websocket.sendJsonMessage(message);
    } catch (e) {
      emit(PairBleThreadFailure(e.toString()));
    }
  }

  void _onMessageReceived(
      PairBleThreadMessageReceived event,
      Emitter<PairBleThreadState> emit,
      ) {
    print('PairBleThreadMessageReceived event: $event');

    try {
      final json = jsonDecode(event.message) as Map<String, dynamic>;
      final command = json['command'] as String;
      final payload = json['payload'];

      print('Received json message: $json');

      switch (command) {
        case 'pairing_progress':
          emit(PairBleThreadInProgress(
            (payload['progress'] as num).toDouble(),
            payload['message'] as String,
          ));
          break;
        case 'pairing_complete':
          emit(PairBleThreadSuccess());
          break;
        case 'pairing_error':
          emit(PairBleThreadFailure(payload['error'] as String));
          break;
      }
    } catch (e) {
      emit(PairBleThreadFailure('Failed to parse message: ${e.toString()}'));
    }
  }

  void _onReset(
      PairBleThreadReset event,
      Emitter<PairBleThreadState> emit,
      ) {
    emit(PairBleThreadInitial());
  }

  void _setupWebSocketListener() {
    _messageSubscription?.cancel();
    _messageSubscription = (websocket.channel)?.stream.listen(
          (message) {
        if (message is String) {
          add(PairBleThreadMessageReceived(message));
        }
      },
      onError: (error) => emit(PairBleThreadFailure(error.toString())),
      onDone: () => emit(PairBleThreadFailure('Connection closed')),
    );
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}