import 'package:equatable/equatable.dart';

class ThreadInterfaceStatusState extends Equatable {
  final bool isInterfaceUp;

  const ThreadInterfaceStatusState({required this.isInterfaceUp});

  factory ThreadInterfaceStatusState.initial() => const ThreadInterfaceStatusState(isInterfaceUp: false);

  ThreadInterfaceStatusState copyWith({bool? isInterfaceUp}) {
    return ThreadInterfaceStatusState(
      isInterfaceUp: isInterfaceUp ?? this.isInterfaceUp,
    );
  }

  @override
  List<Object> get props => [isInterfaceUp];
}
