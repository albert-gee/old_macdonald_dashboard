final class ThreadAddressState {
  final List<String> unicastAddresses;
  final List<String> multicastAddresses;

  const ThreadAddressState({
    this.unicastAddresses = const [],
    this.multicastAddresses = const [],
  });

  ThreadAddressState copyWith({
    List<String>? unicastAddresses,
    List<String>? multicastAddresses,
  }) {
    return ThreadAddressState(
      unicastAddresses: unicastAddresses ?? this.unicastAddresses,
      multicastAddresses: multicastAddresses ?? this.multicastAddresses,
    );
  }
}
