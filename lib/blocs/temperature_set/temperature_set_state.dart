part of 'temperature_set_bloc.dart';

abstract class TemperatureSetState extends Equatable {
  const TemperatureSetState();

  @override
  List<Object> get props => [];
}

class TemperatureSetInitial extends TemperatureSetState {}

class TemperatureSetUpdated extends TemperatureSetState {
  final String temperature;

  const TemperatureSetUpdated(this.temperature);

  @override
  List<Object> get props => [temperature];
}
