import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/websocket/websocket_client.dart';

part 'wifi_sta_connect_event.dart';
part 'wifi_sta_connect_state.dart';

class WifiStaConnectBloc extends Bloc<WifiStaConnectEvent, WifiStaConnectState> {
  final WebSocketClient websocket;

  WifiStaConnectBloc({required this.websocket}) : super(const WifiStaConnectInitialState()) {
    on<WifiStaConnectSendEvent>((event, emit) async {
      emit(const WifiStaConnectLoadingState());
      try {
        final message = {
          "command": "wifi_sta_connect",
          "payload": {
            "ssid": event.ssid,
            "password": event.password,
          }
        };

        bool success = await websocket.sendJsonMessage(message);
        if (success) {
          emit(const WifiStaConnectSuccessState());
        } else {
          emit(const WifiStaConnectFailureState("Failed to connect to Wi-Fi."));
        }
      } catch (e) {
        emit(WifiStaConnectFailureState(e.toString()));
      }
    });
  }
}
