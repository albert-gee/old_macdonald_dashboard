import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ifconfig_status_event.dart';
part 'ifconfig_status_state.dart';

class IfconfigStatusBloc extends Bloc<IfconfigStatusEvent, IfconfigStatusState> {
  IfconfigStatusBloc() : super(IfconfigStatusInitial()) {
    on<IfconfigStatusChanged>(_onStatusChanged);
  }

  Future<void> _onStatusChanged(
      IfconfigStatusChanged event,
      Emitter<IfconfigStatusState> emit,
      ) async {
    emit(IfconfigStatusUpdated(event.status));
  }
}