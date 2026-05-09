import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'thread_status_state.dart';

final class ThreadStatusController extends StateNotifier<ThreadStatusState> {
  late final StreamSubscription<OrchestratorMessage> _subscription;

  ThreadStatusController({required Stream<OrchestratorMessage> messages})
      : super(const ThreadStatusState()) {
    _subscription = messages.listen(_handleMessage);
  }

  void _handleMessage(OrchestratorMessage message) {
    final current = state.status;
    final next = switch (message) {
      ThreadStackStatusReceived(:final running) =>
        current.copyWith(stackRunning: running),
      ThreadInterfaceStatusReceived(:final interfaceUp) =>
        current.copyWith(interfaceUp: interfaceUp),
      ThreadAttachmentStatusReceived(:final attached) =>
        current.copyWith(attached: attached),
      ThreadRoleReceived(:final role) => current.copyWith(role: role),
      ThreadActiveDatasetReceived(:final dataset) =>
        current.copyWith(activeDataset: dataset),
      ThreadUnicastAddressesReceived(:final addresses) => current.copyWith(
          addresses: current.addresses.copyWith(unicastAddresses: addresses),
        ),
      ThreadMulticastAddressesReceived(:final addresses) => current.copyWith(
          addresses: current.addresses.copyWith(multicastAddresses: addresses),
        ),
      ThreadMeshcopServiceStatusReceived(:final published) =>
        current.copyWith(meshcopPublished: published),
      _ => current,
    };

    if (!identical(next, current)) {
      state = ThreadStatusState(status: next);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
