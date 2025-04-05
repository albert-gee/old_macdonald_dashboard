import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/blocs/cluster_command/cluster_command_bloc.dart';

part 'temperature_set_event.dart';
part 'temperature_set_state.dart';

class TemperatureSetBloc extends Bloc<TemperatureSetEvent, TemperatureSetState> {
  final ClusterCommandBloc clusterCommandBloc;

  TemperatureSetBloc({required this.clusterCommandBloc}) : super(TemperatureSetInitial()) {
    on<TemperatureSetReceived>(_onTemperatureSetReceived);
  }

  // Handle the TemperatureSetReceived event
  Future<void> _onTemperatureSetReceived(
      TemperatureSetReceived event, Emitter<TemperatureSetState> emit) async {
    // Check if temperature exceeds 3000
    int temperature = int.parse(event.temperature);
    if (temperature > 3200) {
      // Raise ClusterCommandRequested event
      clusterCommandBloc.add(
        ClusterCommandRequested(
          destinationId: '0x1124',
          endpointId: 1,
          clusterId: 6,
          commandId: 2,
          commandDataField: '{}',
        ),
      );
    }

    emit(TemperatureSetUpdated(event.temperature));
  }
}
