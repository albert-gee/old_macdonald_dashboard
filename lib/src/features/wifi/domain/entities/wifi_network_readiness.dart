enum WifiReadinessState {
  unavailable,
  localOnly,
  uplinkConfiguredButDisconnected,
  uplinkConnected,
  offline,
  unknown,
}

enum WifiSignalQuality {
  unknown,
  excellent,
  good,
  weak,
  poor;

  static WifiSignalQuality fromRssi(int? rssi) {
    if (rssi == null) return WifiSignalQuality.unknown;
    if (rssi >= -55) return WifiSignalQuality.excellent;
    if (rssi >= -67) return WifiSignalQuality.good;
    if (rssi >= -75) return WifiSignalQuality.weak;
    return WifiSignalQuality.poor;
  }

  String get label => switch (this) {
    WifiSignalQuality.unknown => 'Unknown',
    WifiSignalQuality.excellent => 'Excellent',
    WifiSignalQuality.good => 'Good',
    WifiSignalQuality.weak => 'Weak',
    WifiSignalQuality.poor => 'Poor',
  };
}

final class WifiNetworkReadiness {
  final WifiReadinessState state;
  final WifiSignalQuality signalQuality;

  const WifiNetworkReadiness({
    required this.state,
    required this.signalQuality,
  });

  factory WifiNetworkReadiness.derive({
    required bool connected,
    required bool hasSnapshot,
    bool? apRunning,
    bool? staConfigured,
    bool? staConnected,
    String? staIp,
    int? rssi,
  }) {
    if (!connected || !hasSnapshot) {
      return WifiNetworkReadiness(
        state: WifiReadinessState.unavailable,
        signalQuality: WifiSignalQuality.fromRssi(rssi),
      );
    }
    if (apRunning == null || staConfigured == null || staConnected == null) {
      return WifiNetworkReadiness(
        state: WifiReadinessState.unknown,
        signalQuality: WifiSignalQuality.fromRssi(rssi),
      );
    }
    final hasUplinkIp = staIp != null && staIp.trim().isNotEmpty;
    if (staConnected && hasUplinkIp) {
      return WifiNetworkReadiness(
        state: WifiReadinessState.uplinkConnected,
        signalQuality: WifiSignalQuality.fromRssi(rssi),
      );
    }
    if (!apRunning && !staConnected) {
      return WifiNetworkReadiness(
        state: WifiReadinessState.offline,
        signalQuality: WifiSignalQuality.fromRssi(rssi),
      );
    }
    if (apRunning && staConfigured && !staConnected) {
      return WifiNetworkReadiness(
        state: WifiReadinessState.uplinkConfiguredButDisconnected,
        signalQuality: WifiSignalQuality.fromRssi(rssi),
      );
    }
    if (apRunning && !staConnected) {
      return WifiNetworkReadiness(
        state: WifiReadinessState.localOnly,
        signalQuality: WifiSignalQuality.fromRssi(rssi),
      );
    }
    return WifiNetworkReadiness(
      state: WifiReadinessState.unknown,
      signalQuality: WifiSignalQuality.fromRssi(rssi),
    );
  }

  String get title => switch (state) {
    WifiReadinessState.unavailable => 'Wi-Fi status unavailable',
    WifiReadinessState.offline => 'Wi-Fi access is unavailable',
    WifiReadinessState.localOnly => 'Local access is available',
    WifiReadinessState.uplinkConfiguredButDisconnected =>
      'Uplink Wi-Fi is disconnected',
    WifiReadinessState.uplinkConnected => 'Wi-Fi network is healthy',
    WifiReadinessState.unknown => 'Wi-Fi status unavailable',
  };

  String get meaning => switch (state) {
    WifiReadinessState.unavailable =>
      'Dashboard is not connected or has not received Orchestrator state.',
    WifiReadinessState.offline =>
      'Neither local AP nor uplink Wi-Fi is currently reported as connected.',
    WifiReadinessState.localOnly => 'The Orchestrator access point is running.',
    WifiReadinessState.uplinkConfiguredButDisconnected =>
      'Credentials are configured, but the Orchestrator is not connected to the uplink network.',
    WifiReadinessState.uplinkConnected =>
      'Local access is available and/or Orchestrator is connected to uplink Wi-Fi.',
    WifiReadinessState.unknown => 'Dashboard has incomplete Wi-Fi state.',
  };

  String get impact => switch (state) {
    WifiReadinessState.unavailable =>
      'Cannot confirm local access or uplink connectivity.',
    WifiReadinessState.offline =>
      'Dashboard may lose access to the Orchestrator.',
    WifiReadinessState.localOnly =>
      'Dashboard can connect locally; uplink/LAN access is not connected.',
    WifiReadinessState.uplinkConfiguredButDisconnected =>
      'Local control can still work through AP; LAN access may not.',
    WifiReadinessState.uplinkConnected =>
      'Dashboard can use the available network path.',
    WifiReadinessState.unknown =>
      'Cannot confirm local access or uplink connectivity.',
  };

  String get nextAction => switch (state) {
    WifiReadinessState.unavailable => 'Connect to the Orchestrator.',
    WifiReadinessState.offline => 'Check Orchestrator power/network state.',
    WifiReadinessState.localOnly =>
      'Connect Orchestrator to Wi-Fi if LAN access is needed.',
    WifiReadinessState.uplinkConfiguredButDisconnected =>
      'Check SSID/password/signal and reconnect.',
    WifiReadinessState.uplinkConnected => 'Continue chamber operation.',
    WifiReadinessState.unknown => 'Refresh Orchestrator state.',
  };
}
