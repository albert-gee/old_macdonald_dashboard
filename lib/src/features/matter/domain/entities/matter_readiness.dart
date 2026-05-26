import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';

enum MatterReadinessState {
  unavailable,
  threadNotReady,
  controllerNotInitialized,
  readyToCommission,
  devicesCommissioned,
  unknown,
}

final class MatterReadiness {
  final MatterReadinessState state;
  final bool threadReadinessInferred;

  const MatterReadiness({
    required this.state,
    this.threadReadinessInferred = false,
  });

  factory MatterReadiness.derive({
    required bool connected,
    required bool hasSnapshot,
    required ThreadReadiness threadReadiness,
    bool? controllerInitialized,
    int? commissionedNodeCount,
  }) {
    if (!connected || !hasSnapshot) {
      return const MatterReadiness(state: MatterReadinessState.unavailable);
    }
    if (controllerInitialized == null || commissionedNodeCount == null) {
      return const MatterReadiness(state: MatterReadinessState.unknown);
    }
    if (!threadReadiness.isReady) {
      return MatterReadiness(
        state: MatterReadinessState.threadNotReady,
        threadReadinessInferred: threadReadiness.commissioningReadinessInferred,
      );
    }
    if (!controllerInitialized) {
      return MatterReadiness(
        state: MatterReadinessState.controllerNotInitialized,
        threadReadinessInferred: threadReadiness.commissioningReadinessInferred,
      );
    }
    if (commissionedNodeCount > 0) {
      return MatterReadiness(
        state: MatterReadinessState.devicesCommissioned,
        threadReadinessInferred: threadReadiness.commissioningReadinessInferred,
      );
    }
    return MatterReadiness(
      state: MatterReadinessState.readyToCommission,
      threadReadinessInferred: threadReadiness.commissioningReadinessInferred,
    );
  }

  bool get canPair =>
      state == MatterReadinessState.readyToCommission ||
      state == MatterReadinessState.devicesCommissioned;

  String get title => switch (state) {
    MatterReadinessState.unavailable => 'Matter status unavailable',
    MatterReadinessState.threadNotReady => 'Thread Network must be ready',
    MatterReadinessState.controllerNotInitialized =>
      'Matter controller is not initialized',
    MatterReadinessState.readyToCommission => 'Ready to commission devices',
    MatterReadinessState.devicesCommissioned => 'Matter devices commissioned',
    MatterReadinessState.unknown => 'Matter status unavailable',
  };

  String get meaning => switch (state) {
    MatterReadinessState.unavailable =>
      'Dashboard is not connected or has not received Orchestrator state.',
    MatterReadinessState.threadNotReady =>
      'Matter-over-Thread devices require the Thread network.',
    MatterReadinessState.controllerNotInitialized =>
      'Matter controller is not ready.',
    MatterReadinessState.readyToCommission =>
      'Matter controller and Thread prerequisites are ready.',
    MatterReadinessState.devicesCommissioned =>
      'At least one Matter node is known.',
    MatterReadinessState.unknown => 'Dashboard has incomplete Matter state.',
  };

  String get impact => switch (state) {
    MatterReadinessState.unavailable =>
      'Cannot confirm Matter commissioning status.',
    MatterReadinessState.threadNotReady =>
      'New Thread-based chamber devices cannot be paired reliably.',
    MatterReadinessState.controllerNotInitialized =>
      'Devices cannot be commissioned from this Orchestrator yet.',
    MatterReadinessState.readyToCommission =>
      'New chamber devices can be paired.',
    MatterReadinessState.devicesCommissioned =>
      'Device onboarding has started; check registry mappings and capabilities.',
    MatterReadinessState.unknown =>
      'Cannot confirm Matter commissioning status.',
  };

  String get nextAction => switch (state) {
    MatterReadinessState.unavailable => 'Connect to Orchestrator.',
    MatterReadinessState.threadNotReady => 'Fix Thread Network first.',
    MatterReadinessState.controllerNotInitialized =>
      'Initialize Matter controller.',
    MatterReadinessState.readyToCommission => 'Pair a chamber device.',
    MatterReadinessState.devicesCommissioned =>
      'Review commissioned devices and registry status.',
    MatterReadinessState.unknown => 'Refresh Orchestrator state.',
  };
}
