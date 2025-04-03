import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'wifi_sta_status_event.dart';
part 'wifi_sta_status_state.dart';

class WifiStaStatusBloc extends Bloc<WifiStaStatusEvent, WifiStaStatusState> {
  WifiStaStatusBloc() : super(WifiStaStatusInitial()) {
    on<WifiStaStatusChanged>(_onStatusChanged);
  }

  Future<void> _onStatusChanged(
      WifiStaStatusChanged event,
      Emitter<WifiStaStatusState> emit,
      ) async {
    emit(WifiStaStatusUpdated(event.status));
  }
}