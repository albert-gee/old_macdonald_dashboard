import 'thread_active_dataset.dart';
import 'thread_address_state.dart';

final class ThreadStatus {
  final bool stackRunning;
  final bool interfaceUp;
  final bool attached;
  final bool meshcopPublished;
  final String role;
  final ThreadActiveDataset activeDataset;
  final ThreadAddressState addresses;

  const ThreadStatus({
    this.stackRunning = false,
    this.interfaceUp = false,
    this.attached = false,
    this.meshcopPublished = false,
    this.role = '',
    this.activeDataset = const ThreadActiveDataset(),
    this.addresses = const ThreadAddressState(),
  });

  ThreadStatus copyWith({
    bool? stackRunning,
    bool? interfaceUp,
    bool? attached,
    bool? meshcopPublished,
    String? role,
    ThreadActiveDataset? activeDataset,
    ThreadAddressState? addresses,
  }) {
    return ThreadStatus(
      stackRunning: stackRunning ?? this.stackRunning,
      interfaceUp: interfaceUp ?? this.interfaceUp,
      attached: attached ?? this.attached,
      meshcopPublished: meshcopPublished ?? this.meshcopPublished,
      role: role ?? this.role,
      activeDataset: activeDataset ?? this.activeDataset,
      addresses: addresses ?? this.addresses,
    );
  }
}
