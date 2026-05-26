import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/core/widgets/app_status_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_active_dataset.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_address_state.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_status.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_address_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_commands_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';

class ThreadReadinessCard extends StatelessWidget {
  final ThreadReadiness readiness;

  const ThreadReadinessCard({super.key, required this.readiness});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      title: 'Thread Mesh Network readiness',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thread is the local mesh network used by chamber sensors and relays.',
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(readiness.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.meaning),
          if (readiness.commissioningReadinessInferred) ...[
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              'Commissioning readiness is inferred from Thread attachment and dataset presence. Border Router readiness is not separately reported yet.',
            ),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          Text('Chamber impact', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.impact),
          const SizedBox(height: AppDimensions.spacingL),
          Text('Missing requirements', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          if (readiness.missingRequirements.isEmpty)
            const Text('No missing requirements detected.')
          else
            ...readiness.missingRequirements.map((item) => Text('- $item')),
          const SizedBox(height: AppDimensions.spacingL),
          Text('Next safe action', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.nextAction),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            readiness.isReady
                ? 'Thread is ready for Matter-over-Thread devices. Continue to Matter pairing.'
                : 'Complete Thread setup before pairing relay or sensor devices.',
          ),
        ],
      ),
    );
  }
}

class ThreadDeviceImpactCard extends StatelessWidget {
  final ThreadReadiness readiness;

  const ThreadDeviceImpactCard({super.key, required this.readiness});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Chamber device connectivity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thread-based chamber sensors and actuators depend on this chamber device network when they use Matter-over-Thread.',
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            readiness.isReady
                ? 'Thread is ready for Matter-over-Thread chamber devices.'
                : 'Complete Thread setup before pairing or troubleshooting Thread sensors and relays.',
          ),
        ],
      ),
    );
  }
}

class ThreadNetworkStateCard extends StatelessWidget {
  final ThreadStatus status;
  final ThreadReadiness readiness;

  const ThreadNetworkStateCard({
    super.key,
    required this.status,
    required this.readiness,
  });

  @override
  Widget build(BuildContext context) {
    final role = _roleLabel(status.role, status.stackRunning, status.attached);
    return AppCard(
      title: 'Network state',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          AppStatusCard(
            title: 'Thread stack',
            value: status.stackRunning ? 'Running' : 'Stopped',
            active: status.stackRunning,
          ),
          AppStatusCard(
            title: 'Network configuration',
            value: status.meshcopPublished ? 'Dataset present' : 'Missing',
            active: status.meshcopPublished,
          ),
          AppStatusCard(
            title: 'Mesh attachment',
            value: status.attached ? 'Attached' : 'Detached',
            active: status.attached,
          ),
          AppStatusCard(
            title: 'Device role',
            value: role,
            active: role != 'Unknown' && role != 'Disabled',
          ),
          AppStatusCard(
            title: 'Pairing readiness',
            value: readiness.isReady ? 'Inferred ready' : 'Not ready',
            active: readiness.isReady,
          ),
        ],
      ),
    );
  }

  String _roleLabel(String value, bool running, bool attached) {
    if (!running) return 'Disabled';
    if (!attached) return 'Detached';
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'leader' => 'Leader',
      'router' => 'Router',
      'child' => 'Child',
      'detached' => 'Detached',
      'disabled' => 'Disabled',
      _ => 'Unknown',
    };
  }
}

class ThreadDatasetSummaryCard extends StatelessWidget {
  final bool datasetPresent;
  final ThreadActiveDataset dataset;

  const ThreadDatasetSummaryCard({
    super.key,
    required this.datasetPresent,
    required this.dataset,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Dataset / network configuration summary',
      child: !datasetPresent
          ? const Text('No Thread network is configured.')
          : dataset.isEmpty
          ? const Text(
              'Thread network is configured, but safe dataset details are not currently available.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configured: Yes'),
                const SizedBox(height: AppDimensions.spacingM),
                _row('Network name', dataset.networkName),
                _row(
                  'Channel',
                  dataset.channel == 0 ? '-' : '${dataset.channel}',
                ),
                _row('PAN ID', dataset.panId == 0 ? '-' : '${dataset.panId}'),
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Text('$label: ${value.isEmpty ? '-' : value}'),
    );
  }
}

class ThreadOperatorActionsCard extends ConsumerWidget {
  final ThreadStatus status;
  final ThreadReadiness readiness;
  final VoidCallback onInitializeNetwork;

  const ThreadOperatorActionsCard({
    super.key,
    required this.status,
    required this.readiness,
    required this.onInitializeNetwork,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(threadCommandControllerProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }
    });
    final state = ref.watch(threadCommandControllerProvider);
    final controller = ref.read(threadCommandControllerProvider.notifier);
    final submitting = state.submitting;
    return AppCard(
      title: 'Recommended action',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          ElevatedButton(
            onPressed: submitting ? null : controller.refreshThreadState,
            child: const Text('Refresh network state'),
          ),
          ElevatedButton(
            onPressed: submitting || status.stackRunning
                ? null
                : controller.enable,
            child: const Text('Start Thread network'),
          ),
          ElevatedButton(
            onPressed: submitting || !status.stackRunning
                ? null
                : controller.disable,
            child: const Text('Stop Thread network'),
          ),
          ElevatedButton(
            onPressed: submitting || !status.stackRunning
                ? null
                : controller.initBorderRouter,
            child: const Text('Start Border Router'),
          ),
          ElevatedButton(
            onPressed: submitting ? null : controller.deinitBorderRouter,
            child: const Text('Stop Border Router'),
          ),
          OutlinedButton(
            onPressed: submitting || status.meshcopPublished
                ? null
                : () {
                    onInitializeNetwork();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Automatic dataset generation is not available yet. Use advanced manual setup.',
                        ),
                      ),
                    );
                  },
            child: const Text('Initialize Thread network'),
          ),
          ElevatedButton(
            onPressed: submitting || !readiness.isReady
                ? null
                : () {
                    selectDashboardDestination(
                      ref,
                      DashboardDestinationKey.matter,
                    );
                  },
            child: const Text('Continue to Matter pairing'),
          ),
        ],
      ),
    );
  }
}

class ThreadRecentEventsCard extends StatelessWidget {
  final List<OrchestratorEventLogEntry> events;

  const ThreadRecentEventsCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final threadEvents = events.where(_isThreadEvent).take(8).toList();
    return AppCard(
      title: 'Recent Thread activity',
      child: threadEvents.isEmpty
          ? const Text('No Thread activity received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: threadEvents
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

  bool _isThreadEvent(OrchestratorEventLogEntry event) {
    return event.type.startsWith('thread.') ||
        event.type.startsWith('command_failed.thread.');
  }

  String _label(String type) {
    final normalized = type.replaceFirst('command_failed.', '');
    return switch (normalized) {
      'thread.enabled' => 'Thread started',
      'thread.disabled' => 'Thread stopped',
      'thread.attached' => 'Thread attached',
      'thread.detached' => 'Thread detached',
      'thread.role' => 'Thread role changed',
      'thread.dataset_updated' => 'Thread dataset updated',
      _ when type.startsWith('command_failed.') => 'Thread command failed',
      _ => 'Thread event',
    };
  }

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class ThreadAdvancedDiagnosticsCard extends StatelessWidget {
  final ThreadAddressState addresses;
  final bool expanded;
  final bool manualDatasetExpanded;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<bool> onManualDatasetExpandedChanged;

  const ThreadAdvancedDiagnosticsCard({
    super.key,
    required this.addresses,
    required this.expanded,
    required this.manualDatasetExpanded,
    required this.onExpandedChanged,
    required this.onManualDatasetExpandedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Advanced diagnostics',
      child: ExpansionTile(
        key: ValueKey('advanced-$expanded'),
        initiallyExpanded: expanded,
        onExpansionChanged: onExpandedChanged,
        title: const Text(
          'For development, recovery, and low-level Thread troubleshooting.',
        ),
        children: [
          const ExpansionTile(
            title: Text('Thread command diagnostics'),
            children: [ThreadCommandsCard()],
          ),
          ExpansionTile(
            title: const Text('Thread address lists'),
            children: [ThreadAddressCard(addresses: addresses)],
          ),
          ExpansionTile(
            key: ValueKey('manual-dataset-$manualDatasetExpanded'),
            initiallyExpanded: manualDatasetExpanded,
            onExpansionChanged: onManualDatasetExpandedChanged,
            title: const Text('Advanced manual dataset initialization'),
            children: const [
              ThreadDatasetForm(
                title: 'Advanced manual dataset initialization',
                warning:
                    'This form is for development and recovery. It includes low-level Thread credentials. Do not use it during normal operation unless you know what you are doing.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
