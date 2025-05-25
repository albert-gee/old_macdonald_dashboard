import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/services/i_wifi_command_service.dart';
import 'package:get_it/get_it.dart' show GetIt;

part 'wifi_sta_connection_event.dart';

part 'wifi_sta_connection_state.dart';

class WifiStaConnectionBloc
    extends Bloc<WifiStaConnectionEvent, WifiStaConnectionState> {
  final IWifiCommandService _wifiCommandService;

  WifiStaConnectionBloc({IWifiCommandService? wifiCommandService})
      : _wifiCommandService =
            wifiCommandService ?? GetIt.I<IWifiCommandService>(),
        super(WifiStaConnectInitialState()) {
    on<WifiStaConnectionConnectRequested>((event, emit) async {
      emit(const WifiStaConnectLoadingState());
      try {
        await _wifiCommandService.sendStaConnectCommand(
          ssid: event.ssid,
          password: event.password,
        );
        // emit(success
        //     ? const WifiStaConnectSuccessState()
        //     : const WifiStaConnectFailureState("Failed to connect to Wi-Fi."));
      } catch (e) {
        emit(WifiStaConnectFailureState(e.toString()));
      }
    });
  }
}
