import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(operatorRuntimeProvider);
    final rawSnapshot = runtime.snapshot?.rawPayload ?? const {};
    final recentErrors = runtime.runtime.recentMessages
        .where((entry) => entry.error)
        .take(20)
        .toList();

    return AppPageScaffold(
      title: 'Diagnostics',
      description:
          'Actionable Orchestrator, protocol, and hardware diagnostics for finishing setup.',
      children: [
        AppPanel(
          title: 'Known hardware state',
          subtitle:
              'These checks explain whether validation is blocked by host connectivity or Orchestrator health.',
          leading: const Icon(Icons.health_and_safety_outlined),
          tone: runtime.matterPlatformFailed
              ? AppPanelTone.critical
              : AppPanelTone.info,
          footer: runtime.matterPlatformFailed
              ? const _MatterFailureExplanation()
              : null,
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'WSS',
                value: runtime.connected ? 'Connected' : 'Disconnected',
                detail: runtime.endpoint,
                tone: runtime.connected
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Matter platform',
                value: runtime.matterPlatformFailed
                    ? 'Failed'
                    : runtime.matterPlatformInitialized == true
                    ? 'Initialized'
                    : 'Unknown',
                detail:
                    runtime.matterPlatformError ??
                    'No platform error reported in the latest snapshot.',
                tone: runtime.matterPlatformFailed
                    ? AppMetricTone.critical
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Thread',
                value: runtime.threadDatasetPresent
                    ? runtime.threadRole
                    : 'Dataset missing',
                detail:
                    'Enabled ${runtime.threadEnabled}, attached ${runtime.threadAttached}',
                tone: runtime.threadDatasetPresent
                    ? AppMetricTone.info
                    : AppMetricTone.warning,
              ),
            ],
          ),
        ),
        AppPanel(
          title: 'Hardware validation commands',
          subtitle:
              'Use these from the Dashboard host when connected to the Orchestrator AP.',
          leading: const Icon(Icons.usb_outlined),
          tone: AppPanelTone.info,
          trailing: IconButton(
            tooltip: 'Copy hardware validation command sequence',
            onPressed: () => _copy(context, _hardwareCommands),
            icon: const Icon(Icons.copy),
          ),
          child: SelectableText(
            _hardwareCommands,
            style: AppTextStyles.mutedBody,
          ),
        ),
        AppPanel(
          title: 'Recent errors',
          subtitle: recentErrors.isEmpty
              ? 'No command or protocol errors recorded in this session.'
              : 'Latest command and protocol failures.',
          leading: const Icon(Icons.error_outline),
          tone: recentErrors.isEmpty
              ? AppPanelTone.neutral
              : AppPanelTone.warning,
          trailing: IconButton(
            tooltip: 'Copy recent errors',
            onPressed: () => _copy(
              context,
              jsonEncode([
                for (final entry in recentErrors)
                  {
                    'title': entry.title,
                    'received_at': entry.receivedAt.toIso8601String(),
                    'payload': entry.payload,
                  },
              ]),
            ),
            icon: const Icon(Icons.copy),
          ),
          child: recentErrors.isEmpty
              ? const Text('No recent errors.', style: AppTextStyles.mutedBody)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in recentErrors)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingS,
                        ),
                        child: Text(
                          '${entry.title}: ${entry.payload}',
                          style: AppTextStyles.mutedBody,
                        ),
                      ),
                  ],
                ),
        ),
        AppPanel(
          title: 'Latest state_snapshot',
          subtitle:
              'Collapsed raw snapshot for support and firmware debugging.',
          leading: const Icon(Icons.data_object),
          tone: rawSnapshot.isEmpty ? AppPanelTone.neutral : AppPanelTone.info,
          trailing: IconButton(
            tooltip: 'Copy latest snapshot',
            onPressed: () => _copy(context, _prettyJson(rawSnapshot)),
            icon: const Icon(Icons.copy),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Show raw snapshot'),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  rawSnapshot.isEmpty
                      ? 'No state_snapshot received yet.'
                      : _prettyJson(rawSnapshot),
                  style: AppTextStyles.mutedBody,
                ),
              ),
            ],
          ),
        ),
        AppPanel(
          title: 'Protocol log',
          subtitle:
              'Last 100 inbound snapshots, command results, events, and errors.',
          leading: const Icon(Icons.receipt_long_outlined),
          tone: AppPanelTone.neutral,
          child: runtime.runtime.recentMessages.isEmpty
              ? const Text(
                  'No WSS protocol messages recorded yet.',
                  style: AppTextStyles.mutedBody,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in runtime.runtime.recentMessages.take(20))
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingS,
                        ),
                        child: Text(
                          '${entry.receivedAt.toIso8601String()}  ${entry.title}',
                          style: entry.error
                              ? AppTextStyles.mutedBody.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                )
                              : AppTextStyles.mutedBody,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  static const String _hardwareCommands = '''
ls -l /dev/ttyACM0 /dev/ttyUSB0 /dev/ttyUSB1
ls -l /dev/serial/by-id 2>/dev/null || true
lsof /dev/ttyACM0 /dev/ttyUSB0 /dev/ttyUSB1 2>/dev/null || true
ping -c 2 -W 2 192.168.4.1
openssl s_client -connect 192.168.4.1:443 -servername 192.168.4.1 -CAfile assets/rootCA.pem -verify_return_error
wscat --ca assets/rootCA.pem -c wss://192.168.4.1/ws
''';

  static String _prettyJson(Map<String, Object?> value) {
    if (value.isEmpty) return '{}';
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  static Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard.')));
  }
}

class _MatterFailureExplanation extends StatelessWidget {
  const _MatterFailureExplanation();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matter platform is not initialized',
          style: AppTextStyles.sectionTitle,
        ),
        SizedBox(height: AppDimensions.spacingS),
        Text(
          'The Orchestrator firmware booted but CHIP/Matter platform initialization failed. Device commissioning and Matter controller operations are blocked until this is fixed.',
          style: AppTextStyles.mutedBody,
        ),
        SizedBox(height: AppDimensions.spacingS),
        Text(
          'Known serial evidence: Configuration Manager initialization failed: 5001105, CHIP stack initialization failed, Failed to initialize Matter interface: ESP_FAIL, then main_task returned from app_main(). If logs show a checksum mismatch between flashed and built applications, rebuild and flash the intended Orchestrator firmware.',
          style: AppTextStyles.mutedBody,
        ),
      ],
    );
  }
}
