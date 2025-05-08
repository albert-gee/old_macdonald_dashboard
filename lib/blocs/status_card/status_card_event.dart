import 'package:equatable/equatable.dart';

abstract class StatusCardEvent<T> extends Equatable {
  final T value;
  const StatusCardEvent(this.value);

  @override
  List<T> get props => [value];
}

class StatusCardChanged<T> extends StatusCardEvent<T> {
  const StatusCardChanged(super.value);
}
