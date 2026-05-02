import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/services/i_wifi_command_service.dart';

part 'wifi_sta_connection_event.dart';

part 'wifi_sta_connection_state.dart';

class WifiStaConnectionBloc
    extends Bloc<WifiStaConnectionEvent, WifiStaConnectionState> {
  final IWifiCommandService _wifiCommandService;

  WifiStaConnectionBloc({
    required IWifiCommandService wifiCommandService,
  })  : _wifiCommandService = wifiCommandService,
        super(WifiStaConnectInitialState()) {
    on<WifiStaConnectionConnectRequested>((event, emit) async {
      emit(const WifiStaConnectLoadingState());
      try {
        await _wifiCommandService.sendStaConnectCommand(
          ssid: event.ssid,
          password: event.password,
        );
        emit(const WifiStaConnectSuccessState());
      } catch (e) {
        emit(const WifiStaConnectFailureState(
          'Failed to send Wi-Fi STA connect command. Make sure the WebSocket is connected.',
        ));
      }
    });
  }
}
