import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'matter_event_state.dart';

final class MatterEventController extends StateNotifier<MatterEventState> {
  late final StreamSubscription<OrchestratorMessage> _subscription;

  MatterEventController({required Stream<OrchestratorMessage> messages})
      : super(const MatterEventState()) {
    _subscription = messages.listen(_handleMessage);
  }

  void _handleMessage(OrchestratorMessage message) {
    final event = switch (message) {
      MatterCommissioningCompleteReceived(
        :final nodeId,
        :final fabricIndex,
      ) =>
        MatterCommissioningCompleteEvent(
          nodeId: nodeId,
          fabricIndex: fabricIndex,
        ),
      MatterAttributeReportReceived(:final report) =>
        MatterAttributeReportEvent(report),
      MatterSubscribeDoneReceived(:final nodeId, :final subscriptionId) =>
        MatterSubscribeDoneEvent(
          nodeId: nodeId,
          subscriptionId: subscriptionId,
        ),
      _ => null,
    };
    if (event == null) return;

    state = MatterEventState(
      recentEvents: [event, ...state.recentEvents].take(20).toList(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
