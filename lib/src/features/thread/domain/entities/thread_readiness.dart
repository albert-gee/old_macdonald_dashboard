enum ThreadReadinessState {
  unavailable,
  stopped,
  missingDataset,
  detached,
  attached,
  readyForCommissioning,
  unknown,
}

final class ThreadReadiness {
  final ThreadReadinessState state;
  final List<String> missingRequirements;
  final bool commissioningReadinessInferred;

  const ThreadReadiness({
    required this.state,
    required this.missingRequirements,
    this.commissioningReadinessInferred = false,
  });

  factory ThreadReadiness.derive({
    required bool connected,
    required bool hasThreadData,
    bool? enabled,
    bool? datasetPresent,
    bool? attached,
  }) {
    if (!connected || !hasThreadData) {
      return const ThreadReadiness(
        state: ThreadReadinessState.unavailable,
        missingRequirements: ['Connect to the Orchestrator.'],
      );
    }
    if (enabled == null || datasetPresent == null || attached == null) {
      return const ThreadReadiness(
        state: ThreadReadinessState.unknown,
        missingRequirements: ['Refresh Thread state.'],
      );
    }
    if (!enabled) {
      return const ThreadReadiness(
        state: ThreadReadinessState.stopped,
        missingRequirements: ['Thread stack is stopped.'],
      );
    }
    if (!datasetPresent) {
      return const ThreadReadiness(
        state: ThreadReadinessState.missingDataset,
        missingRequirements: ['Active Thread dataset is missing.'],
      );
    }
    if (!attached) {
      return const ThreadReadiness(
        state: ThreadReadinessState.detached,
        missingRequirements: ['Orchestrator is not attached to Thread.'],
      );
    }
    return const ThreadReadiness(
      state: ThreadReadinessState.readyForCommissioning,
      missingRequirements: [],
      commissioningReadinessInferred: true,
    );
  }

  bool get isReady =>
      state == ThreadReadinessState.attached ||
      state == ThreadReadinessState.readyForCommissioning;

  String get title => switch (state) {
    ThreadReadinessState.unavailable => 'Thread network status unavailable',
    ThreadReadinessState.stopped => 'Thread network is stopped',
    ThreadReadinessState.missingDataset => 'Thread network is not configured',
    ThreadReadinessState.detached => 'Thread network is running but detached',
    ThreadReadinessState.attached => 'Thread network is ready',
    ThreadReadinessState.readyForCommissioning => 'Thread network is ready.',
    ThreadReadinessState.unknown => 'Thread network status unavailable',
  };

  String get meaning => switch (state) {
    ThreadReadinessState.unavailable =>
      'Dashboard is not connected or has not received Thread state.',
    ThreadReadinessState.stopped => 'The Thread stack is not running.',
    ThreadReadinessState.missingDataset => 'No active Thread dataset exists.',
    ThreadReadinessState.detached =>
      'Thread is running, but the Orchestrator is not attached to a Thread mesh.',
    ThreadReadinessState.attached =>
      'Thread is running, configured, and attached.',
    ThreadReadinessState.readyForCommissioning =>
      'Thread is running, configured, and attached.',
    ThreadReadinessState.unknown => 'Dashboard has incomplete Thread state.',
  };

  String get impact => switch (state) {
    ThreadReadinessState.unavailable =>
      'Cannot confirm whether chamber Thread devices can communicate.',
    ThreadReadinessState.stopped =>
      'Thread sensors and actuators cannot communicate through the Orchestrator.',
    ThreadReadinessState.missingDataset => 'New Thread devices cannot join.',
    ThreadReadinessState.detached => 'Devices may be unreachable.',
    ThreadReadinessState.attached =>
      'Chamber Thread devices can be paired or operated, subject to Matter commissioning.',
    ThreadReadinessState.readyForCommissioning =>
      'Chamber Thread devices can be paired or operated, subject to Matter commissioning.',
    ThreadReadinessState.unknown =>
      'Cannot confirm whether chamber Thread devices can communicate.',
  };

  String get nextAction => switch (state) {
    ThreadReadinessState.unavailable =>
      'Connect to Orchestrator and refresh state.',
    ThreadReadinessState.stopped => 'Start Thread network.',
    ThreadReadinessState.missingDataset => 'Initialize Thread network.',
    ThreadReadinessState.detached =>
      'Refresh state, wait briefly, or restart Thread.',
    ThreadReadinessState.attached => 'Continue to Matter pairing.',
    ThreadReadinessState.readyForCommissioning => 'Continue to Matter pairing.',
    ThreadReadinessState.unknown => 'Refresh network state.',
  };
}
