import 'package:equatable/equatable.dart';

class ThreadAddressState extends Equatable {
  final List<String> unicastAddresses;
  final List<String> multicastAddresses;

  const ThreadAddressState({
    required this.unicastAddresses,
    required this.multicastAddresses,
  });

  factory ThreadAddressState.initial() => const ThreadAddressState(
    unicastAddresses: [],
    multicastAddresses: [],
  );

  ThreadAddressState copyWith({
    List<String>? unicastAddresses,
    List<String>? multicastAddresses,
  }) {
    return ThreadAddressState(
      unicastAddresses: unicastAddresses ?? this.unicastAddresses,
      multicastAddresses: multicastAddresses ?? this.multicastAddresses,
    );
  }

  @override
  List<Object> get props => [unicastAddresses, multicastAddresses];
}
