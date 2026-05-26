enum SystemReadinessState {
  disconnected,
  untrusted,
  connectedNoSnapshot,
  setupRequired,
  degraded,
  operational,
  unknown,
}

final class SystemReadiness {
  final SystemReadinessState state;
  final String title;
  final String meaning;
  final String impact;
  final String nextAction;
  final List<String> missingRequirements;

  const SystemReadiness({
    required this.state,
    required this.title,
    required this.meaning,
    required this.impact,
    required this.nextAction,
    this.missingRequirements = const [],
  });

  factory SystemReadiness.derive({
    required bool connected,
    required bool trusted,
    required bool hasSnapshot,
    required bool wifiReady,
    required bool threadReady,
    required bool matterReady,
    required int deviceCount,
    required int usableCapabilityCount,
  }) {
    if (!connected) {
      return const SystemReadiness(
        state: SystemReadinessState.disconnected,
        title: 'Dashboard is not connected to the Orchestrator.',
        meaning: 'No live runtime state is available.',
        impact: 'Live chamber controls and network status cannot be confirmed.',
        nextAction: 'Connect to the Orchestrator.',
        missingRequirements: ['WebSocket connection'],
      );
    }
    if (!trusted) {
      return const SystemReadiness(
        state: SystemReadinessState.untrusted,
        title: 'Certificate trust is required before secure connection.',
        meaning: 'The Dashboard has not trusted the Orchestrator certificate.',
        impact: 'Secure control should not continue until trust is paired.',
        nextAction: 'Pair and trust the Orchestrator certificate.',
        missingRequirements: ['Certificate trust'],
      );
    }
    if (!hasSnapshot) {
      return const SystemReadiness(
        state: SystemReadinessState.connectedNoSnapshot,
        title: 'Connection established, waiting for runtime state.',
        meaning: 'The WebSocket is connected but no snapshot has arrived.',
        impact: 'Network and device readiness are not confirmed yet.',
        nextAction: 'Wait briefly or reconnect.',
        missingRequirements: ['Runtime snapshot'],
      );
    }

    final missing = <String>[
      if (!wifiReady) 'Wi-Fi readiness',
      if (!threadReady) 'Thread Network readiness',
      if (!matterReady) 'Matter Device Network readiness',
      if (deviceCount == 0) 'Registered chamber devices',
      if (usableCapabilityCount == 0) 'Usable device capabilities',
    ];
    if (missing.isEmpty) {
      return const SystemReadiness(
        state: SystemReadinessState.operational,
        title: 'Dashboard is operational.',
        meaning:
            'Connection, runtime state, networks, and device capabilities are available.',
        impact: 'Normal chamber operation can continue.',
        nextAction: 'Continue chamber operation.',
      );
    }
    return SystemReadiness(
      state: SystemReadinessState.setupRequired,
      title: 'Dashboard setup is incomplete.',
      meaning: 'One or more required operating areas still need attention.',
      impact: 'Some chamber workflows may be unavailable or degraded.',
      nextAction: 'Review the setup checklist and missing requirements.',
      missingRequirements: missing,
    );
  }
}
