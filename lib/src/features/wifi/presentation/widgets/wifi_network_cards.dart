import 'package:flutter/material.dart';

import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_network_readiness.dart';
import 'package:dashboard/src/features/wifi/presentation/widgets/wifi_sta_connect_form.dart';

class WifiReadinessCard extends StatelessWidget {
  final WifiNetworkReadiness readiness;

  const WifiReadinessCard({super.key, required this.readiness});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPanel(
      title: 'Wi-Fi Network readiness',
      tone:
          readiness.state == WifiReadinessState.uplinkConnected ||
              readiness.state == WifiReadinessState.localOnly
          ? AppPanelTone.success
          : AppPanelTone.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wi-Fi provides local Dashboard access and optional uplink connectivity for the Orchestrator.',
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(readiness.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.meaning),
          const SizedBox(height: AppDimensions.spacingL),
          Text('Operational impact', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.impact),
          const SizedBox(height: AppDimensions.spacingL),
          Text('Next action', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.nextAction),
        ],
      ),
    );
  }
}

class WifiLocalAccessCard extends StatelessWidget {
  final WifiRuntimeSnapshot? wifi;
  final int websocketClients;

  const WifiLocalAccessCard({
    super.key,
    required this.wifi,
    required this.websocketClients,
  });

  @override
  Widget build(BuildContext context) {
    final apRunning = wifi?.apRunning ?? false;
    return AppPanel(
      title: 'Local Dashboard access',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Access point',
                value: apRunning ? 'Running' : 'Stopped',
                tone: apRunning ? AppMetricTone.good : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Local control path',
                value: apRunning ? 'Available' : 'Not available',
                tone: apRunning ? AppMetricTone.good : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Default local address',
                value: apRunning ? '192.168.4.1' : 'Unavailable',
                tone: apRunning ? AppMetricTone.info : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'WebSocket clients',
                value: '$websocketClients',
                tone: websocketClients > 0
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            apRunning
                ? 'The Orchestrator local access point is running. A Dashboard device can connect directly for setup and control.'
                : 'The Orchestrator local access point is not reported as running.',
          ),
          const SizedBox(height: AppDimensions.spacingS),
          const Text('Purpose: local setup and chamber control.'),
        ],
      ),
    );
  }
}

class WifiUplinkCard extends StatelessWidget {
  final WifiRuntimeSnapshot? wifi;
  final WifiSignalQuality signalQuality;

  const WifiUplinkCard({
    super.key,
    required this.wifi,
    required this.signalQuality,
  });

  @override
  Widget build(BuildContext context) {
    final configured = wifi?.staConfigured ?? false;
    final connected = wifi?.staConnected ?? false;
    final ipAddress = wifi?.staIp;
    final rssi = wifi?.rssi;
    return AppPanel(
      title: 'Uplink Wi-Fi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Configured',
                value: configured ? 'Yes' : 'No',
                tone: configured ? AppMetricTone.info : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Connected',
                value: connected ? 'Yes' : 'No',
                tone: connected ? AppMetricTone.good : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'IP address',
                value: ipAddress?.isNotEmpty == true
                    ? ipAddress!
                    : 'Not assigned',
                tone: ipAddress?.isNotEmpty == true
                    ? AppMetricTone.info
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'RSSI',
                value: rssi == null ? 'Unknown' : '$rssi dBm',
                tone: rssi == null
                    ? AppMetricTone.neutral
                    : rssi >= -75
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Signal quality',
                value: signalQuality.label,
                tone:
                    signalQuality == WifiSignalQuality.excellent ||
                        signalQuality == WifiSignalQuality.good
                    ? AppMetricTone.good
                    : signalQuality == WifiSignalQuality.unknown
                    ? AppMetricTone.neutral
                    : AppMetricTone.warning,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(_statusCopy(configured: configured, connected: connected)),
          const SizedBox(height: AppDimensions.spacingS),
          const Text(
            'Local chamber control can still work through the Orchestrator access point when uplink Wi-Fi is unavailable.',
          ),
          const SizedBox(height: AppDimensions.spacingS),
          const Text(
            'RSSI is a signal indicator, not an exact reliability guarantee.',
          ),
        ],
      ),
    );
  }

  String _statusCopy({required bool configured, required bool connected}) {
    if (connected) {
      return 'The Orchestrator is connected to the uplink Wi-Fi network.';
    }
    if (configured) {
      return 'The Orchestrator has Wi-Fi credentials but is not connected.';
    }
    return 'No uplink Wi-Fi credentials are configured.';
  }
}

class WifiConnectCard extends StatelessWidget {
  const WifiConnectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      title: 'Connect Orchestrator to Wi-Fi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Use this to connect the Orchestrator to your home/farm/lab Wi-Fi network. Local AP access remains the fallback control path.',
          ),
          SizedBox(height: AppDimensions.spacingL),
          WifiStaConnectForm(
            ssidLabel: 'Network name / SSID',
            submitLabel: 'Connect uplink Wi-Fi',
            submittingLabel: 'Connecting uplink...',
          ),
        ],
      ),
    );
  }
}

class WifiRecentActivityCard extends StatelessWidget {
  final List<OrchestratorEventLogEntry> events;

  const WifiRecentActivityCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final wifiEvents = events.where(_isWifiEvent).take(8).toList();
    return AppPanel(
      title: 'Recent Wi-Fi activity',
      child: wifiEvents.isEmpty
          ? const Text('No Wi-Fi activity received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wifiEvents
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
                      ),
                      child: Text(
                        '${_label(event.type)} - ${_time(event.receivedAt)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  bool _isWifiEvent(OrchestratorEventLogEntry event) {
    return event.type.startsWith('wifi.') ||
        event.type.startsWith('websocket.');
  }

  String _label(String type) {
    return switch (type) {
      'wifi.ap_started' => 'Local access point started',
      'wifi.ap_stopped' => 'Local access point stopped',
      'wifi.sta_connected' => 'Uplink Wi-Fi connected',
      'wifi.sta_disconnected' => 'Uplink Wi-Fi disconnected',
      'wifi.got_ip' => 'Uplink IP assigned',
      'wifi.lost_ip' => 'Uplink IP lost',
      'websocket.client_connected' => 'WebSocket client connected',
      'websocket.client_disconnected' => 'WebSocket client disconnected',
      _ => 'Wi-Fi activity',
    };
  }

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class WifiAdvancedDiagnosticsCard extends StatelessWidget {
  final WifiRuntimeSnapshot? wifi;
  final WebSocketRuntimeSnapshot? websocket;

  const WifiAdvancedDiagnosticsCard({
    super.key,
    required this.wifi,
    required this.websocket,
  });

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Advanced diagnostics',
      tone: AppPanelTone.neutral,
      child: ExpansionTile(
        title: const Text('For network troubleshooting and development.'),
        children: [
          _row('mode', wifi?.mode ?? 'unknown'),
          _row('ap_running', '${wifi?.apRunning ?? false}'),
          _row('sta_configured', '${wifi?.staConfigured ?? false}'),
          _row('sta_connected', '${wifi?.staConnected ?? false}'),
          _row('sta_ip', wifi?.staIp ?? '-'),
          _row('rssi', wifi?.rssi?.toString() ?? '-'),
          _row('websocket.clients', '${websocket?.clients ?? 0}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('$label: $value'),
      ),
    );
  }
}
