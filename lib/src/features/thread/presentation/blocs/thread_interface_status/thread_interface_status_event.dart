import 'package:equatable/equatable.dart';

abstract class ThreadInterfaceStatusEvent extends Equatable {
  const ThreadInterfaceStatusEvent();

  @override
  List<Object> get props => [];
}

class ThreadInterfaceStatusUpdated extends ThreadInterfaceStatusEvent {
  final bool isInterfaceUp;

  const ThreadInterfaceStatusUpdated(this.isInterfaceUp);

  @override
  List<Object> get props => [isInterfaceUp];
}
