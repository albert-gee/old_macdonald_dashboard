import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      title: 'Thread Network Readiness',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(readiness.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.explanation),
          if (readiness.commissioningReadinessInferred) ...[
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              'Commissioning readiness is inferred from Thread attachment and dataset presence. Border Router readiness is not separately reported yet.',
            ),
          ],
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
      title: 'Network State',
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
            title: 'Attachment',
            value: status.attached ? 'Attached' : 'Detached',
            active: status.attached,
          ),
          AppStatusCard(
            title: 'Role',
            value: role,
            active: role != 'Unknown' && role != 'Disabled',
          ),
          AppStatusCard(
            title: 'Dataset',
            value: status.meshcopPublished ? 'Present' : 'Missing',
            active: status.meshcopPublished,
          ),
          AppStatusCard(
            title: 'Commissioning',
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
      title: 'Dataset Summary',
      child: !datasetPresent
          ? const Text('No active dataset.')
          : dataset.isEmpty
          ? const Text(
              'Dataset is present. Detailed safe dataset summary is not available yet.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dataset is present.'),
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

  const ThreadOperatorActionsCard({super.key, required this.status});

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
      title: 'Operator Actions',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          ElevatedButton(
            onPressed: submitting ? null : controller.refreshThreadState,
            child: const Text('Refresh Thread state'),
          ),
          ElevatedButton(
            onPressed: submitting || status.stackRunning
                ? null
                : controller.enable,
            child: const Text('Start Thread'),
          ),
          ElevatedButton(
            onPressed: submitting || !status.stackRunning
                ? null
                : controller.disable,
            child: const Text('Stop Thread'),
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
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Use Advanced Diagnostics to initialize a Thread dataset with credentials.',
                      ),
                    ),
                  ),
            child: const Text('Create / Initialize Thread Network'),
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
      title: 'Recent Thread Events',
      child: threadEvents.isEmpty
          ? const Text('No Thread events received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: threadEvents
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
                      ),
                      child: Text('${_label(event.type)} - ${event.type}'),
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
      'thread.dataset_updated' => 'Thread dataset updated',
      _ when type.startsWith('command_failed.') => 'Thread command failed',
      _ => 'Thread event',
    };
  }
}

class ThreadAdvancedDiagnosticsCard extends StatelessWidget {
  final ThreadAddressState addresses;

  const ThreadAdvancedDiagnosticsCard({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Advanced Diagnostics',
      child: Column(
        children: [
          const ExpansionTile(
            title: Text('Raw Thread command buttons'),
            children: [ThreadCommandsCard()],
          ),
          ExpansionTile(
            title: const Text('Thread address lists'),
            children: [ThreadAddressCard(addresses: addresses)],
          ),
          const ExpansionTile(
            title: Text('Advanced manual dataset initialization'),
            children: [
              ThreadDatasetForm(
                title: 'Advanced manual dataset initialization',
                warning:
                    'This form is for development and recovery. It exposes low-level Thread network credentials.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
