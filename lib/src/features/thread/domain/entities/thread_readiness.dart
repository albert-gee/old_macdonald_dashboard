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
    this.commissioningReadinessInferred = true,
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
    );
  }

  bool get isReady =>
      state == ThreadReadinessState.attached ||
      state == ThreadReadinessState.readyForCommissioning;

  String get title => switch (state) {
    ThreadReadinessState.unavailable => 'Thread state is unavailable.',
    ThreadReadinessState.stopped => 'Thread is stopped.',
    ThreadReadinessState.missingDataset => 'No active Thread dataset.',
    ThreadReadinessState.detached => 'Thread is running but detached.',
    ThreadReadinessState.attached => 'Thread network is attached.',
    ThreadReadinessState.readyForCommissioning => 'Thread network is ready.',
    ThreadReadinessState.unknown => 'Thread readiness is unknown.',
  };

  String get explanation => switch (state) {
    ThreadReadinessState.unavailable =>
      'Connect to the Orchestrator and refresh Thread state.',
    ThreadReadinessState.stopped =>
      'Start Thread before pairing Matter-over-Thread devices.',
    ThreadReadinessState.missingDataset =>
      'Create or initialize a Thread network before pairing devices.',
    ThreadReadinessState.detached => 'Wait for attachment or restart Thread.',
    ThreadReadinessState.attached =>
      'Commissioning readiness is inferred from Thread attachment and dataset presence.',
    ThreadReadinessState.readyForCommissioning =>
      'You can proceed to Matter pairing.',
    ThreadReadinessState.unknown =>
      'The Dashboard does not have enough Thread data yet.',
  };

  String get nextAction => switch (state) {
    ThreadReadinessState.unavailable => 'Connect and refresh Thread state.',
    ThreadReadinessState.stopped => 'Start Thread.',
    ThreadReadinessState.missingDataset =>
      'Initialize a Thread dataset from Advanced Diagnostics.',
    ThreadReadinessState.detached =>
      'Refresh state, then restart Thread if needed.',
    ThreadReadinessState.attached => 'Continue to Matter pairing.',
    ThreadReadinessState.readyForCommissioning => 'Continue to Matter pairing.',
    ThreadReadinessState.unknown => 'Refresh Thread state.',
  };
}
