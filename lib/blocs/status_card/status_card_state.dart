import 'package:equatable/equatable.dart';

abstract class StatusCardState<T> extends Equatable {
  final T value;
  const StatusCardState(this.value);

  @override
  List<Object?> get props => [value];
}

class StatusCardInitial<T> extends StatusCardState<T> {
  const StatusCardInitial(T value) : super(value);
}

class StatusCardUpdated<T> extends StatusCardState<T> {
  const StatusCardUpdated(T value) : super(value);
}
