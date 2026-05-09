import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_status.dart';

final class WifiStaStatusController extends StateNotifier<WifiStaStatus> {
  late final StreamSubscription<OrchestratorMessage> _subscription;

  WifiStaStatusController({required Stream<OrchestratorMessage> messages})
      : super(const WifiStaStatus()) {
    _subscription = messages.listen((message) {
      if (message case WifiStaStatusReceived(:final status)) {
        state = WifiStaStatus(status.isEmpty ? 'Unknown' : status);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
