part of 'temperature_set_bloc.dart';

abstract class TemperatureSetEvent extends Equatable {
  const TemperatureSetEvent();

  @override
  List<Object> get props => [];
}

class TemperatureSetReceived extends TemperatureSetEvent {
  final String temperature;

  const TemperatureSetReceived(this.temperature);

  @override
  List<Object> get props => [temperature];
}
