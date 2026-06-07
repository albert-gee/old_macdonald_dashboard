import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/overview/domain/operator_runtime.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(operatorRuntimeProvider);
    final threadCommand = ref.watch(threadCommandControllerProvider);
    final datasetCommand = ref.watch(threadDatasetInitControllerProvider);
    final matterCommand = ref.watch(matterCommandControllerProvider);

    return AppPageScaffold(
      title: 'Setup',
      description:
          'Guided bring-up for Orchestrator connection, Thread infrastructure, Matter controller, and device commissioning.',
      children: [
        _StepPanel(
          step: 'Step 1',
          title: 'Connect to Orchestrator',
          subtitle: runtime.connected
              ? 'Connected to ${runtime.endpoint}.'
              : 'Use the global Connect button in the top bar.',
          complete: runtime.connected,
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Connection',
                value: runtime.connection.status.name,
                detail: runtime.endpoint,
                tone: runtime.connected
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Last snapshot',
                value: ageLabel(runtime.lastSnapshotAt),
                detail: runtime.connected
                    ? 'Waiting for runtime state if this is Never.'
                    : 'Connect to WSS first.',
                tone: runtime.snapshotReceived
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
            ],
          ),
        ),
        _StepPanel(
          step: 'Step 2',
          title: 'Prepare Thread dataset',
          subtitle: runtime.threadDatasetPresent
              ? 'Active Thread dataset is present.'
              : 'Thread cannot start until an active dataset exists.',
          complete: runtime.threadDatasetPresent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppResponsiveGrid(
                children: [
                  AppMetricTile(
                    label: 'Dataset',
                    value: runtime.threadDatasetPresent ? 'Present' : 'Missing',
                    tone: runtime.threadDatasetPresent
                        ? AppMetricTone.good
                        : AppMetricTone.warning,
                  ),
                  AppMetricTile(
                    label: 'Network name',
                    value: runtime.snapshot?.thread.networkName ?? '-',
                    compact: true,
                  ),
                  AppMetricTile(
                    label: 'Channel',
                    value: runtime.snapshot?.thread.channel?.toString() ?? '-',
                    compact: true,
                  ),
                  AppMetricTile(
                    label: 'PAN ID',
                    value: runtime.snapshot?.thread.panId?.toString() ?? '-',
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingS,
                children: [
                  OutlinedButton.icon(
                    onPressed: threadCommand.submitting
                        ? null
                        : ref
                              .read(threadCommandControllerProvider.notifier)
                              .refreshActiveDataset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check dataset'),
                  ),
                  FilledButton.icon(
                    onPressed: datasetCommand.submitting
                        ? null
                        : () => ref
                              .read(
                                threadDatasetInitControllerProvider.notifier,
                              )
                              .submit(_defaultDataset()),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create default dataset'),
                  ),
                ],
              ),
              if (datasetCommand.message != null) ...[
                const SizedBox(height: AppDimensions.spacingS),
                Text(datasetCommand.message!, style: AppTextStyles.mutedBody),
              ],
            ],
          ),
        ),
        _StepPanel(
          step: 'Step 3',
          title: 'Enable Thread / Border Router',
          subtitle: runtime.threadDatasetPresent
              ? 'Start Thread, then initialize Border Router services.'
              : 'Create a dataset before enabling Thread.',
          complete: runtime.threadEnabled && runtime.threadAttached,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppResponsiveGrid(
                children: [
                  AppMetricTile(
                    label: 'Thread runtime',
                    value: runtime.threadEnabled ? 'Enabled' : 'Disabled',
                    detail: 'Role ${runtime.threadRole}',
                    tone: runtime.threadEnabled
                        ? AppMetricTone.good
                        : AppMetricTone.neutral,
                  ),
                  AppMetricTile(
                    label: 'Attachment',
                    value: runtime.threadAttached ? 'Attached' : 'Detached',
                    detail: runtime.threadDatasetPresent
                        ? 'Attachment may take time after startup.'
                        : 'Dataset required first.',
                    tone: runtime.threadAttached
                        ? AppMetricTone.good
                        : AppMetricTone.pending,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingS,
                children: [
                  FilledButton.icon(
                    onPressed:
                        !runtime.threadDatasetPresent ||
                            threadCommand.submitting
                        ? null
                        : ref
                              .read(threadCommandControllerProvider.notifier)
                              .enable,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Enable Thread'),
                  ),
                  OutlinedButton.icon(
                    onPressed: threadCommand.submitting
                        ? null
                        : ref
                              .read(threadCommandControllerProvider.notifier)
                              .initBorderRouter,
                    icon: const Icon(Icons.router_outlined),
                    label: const Text('Initialize Border Router'),
                  ),
                  OutlinedButton.icon(
                    onPressed: threadCommand.submitting
                        ? null
                        : ref
                              .read(threadCommandControllerProvider.notifier)
                              .refreshThreadState,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh status'),
                  ),
                ],
              ),
              if (!runtime.threadDatasetPresent) ...[
                const SizedBox(height: AppDimensions.spacingS),
                const Text(
                  'Thread cannot start until an active dataset exists. Create a dataset first.',
                  style: AppTextStyles.mutedBody,
                ),
              ],
              if (threadCommand.message != null) ...[
                const SizedBox(height: AppDimensions.spacingS),
                Text(threadCommand.message!, style: AppTextStyles.mutedBody),
              ],
            ],
          ),
        ),
        _StepPanel(
          step: 'Step 4',
          title: 'Initialize Matter platform/controller',
          subtitle: runtime.matterPlatformFailed
              ? 'Matter platform failed on the Orchestrator.'
              : 'Matter controller is required before commissioning.',
          complete: runtime.matterControllerInitialized,
          tone: runtime.matterPlatformFailed
              ? AppPanelTone.critical
              : AppPanelTone.info,
          child: runtime.matterPlatformFailed
              ? _MatterPlatformBlocked(runtime: runtime)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppResponsiveGrid(
                      children: [
                        AppMetricTile(
                          label: 'Platform',
                          value: runtime.matterPlatformInitialized == true
                              ? 'Initialized'
                              : 'Not reported',
                          tone: runtime.matterPlatformInitialized == true
                              ? AppMetricTone.good
                              : AppMetricTone.neutral,
                        ),
                        AppMetricTile(
                          label: 'Controller',
                          value: runtime.matterControllerInitialized
                              ? 'Initialized'
                              : 'Not initialized',
                          tone: runtime.matterControllerInitialized
                              ? AppMetricTone.good
                              : AppMetricTone.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    FilledButton.icon(
                      onPressed: matterCommand.submitting
                          ? null
                          : () => ref
                                .read(matterCommandControllerProvider.notifier)
                                .initializeController(
                                  const MatterControllerInitRequest(
                                    nodeId: '1',
                                    fabricId: 2,
                                    listenPort: 5540,
                                  ),
                                ),
                      icon: const Icon(Icons.memory),
                      label: const Text('Initialize Matter controller'),
                    ),
                    if (matterCommand.message != null) ...[
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        matterCommand.message!,
                        style: AppTextStyles.mutedBody,
                      ),
                    ],
                  ],
                ),
        ),
        _StepPanel(
          step: 'Step 5',
          title: 'Commission device',
          subtitle: _commissioningSubtitle(runtime),
          complete:
              runtime.deviceCount > 0 || runtime.commissionedNodeCount > 0,
          child: _CommissionDeviceForm(runtime: runtime),
        ),
      ],
    );
  }

  ThreadDatasetInitRequest _defaultDataset() {
    return const ThreadDatasetInitRequest(
      channel: 15,
      panId: 4660,
      networkName: 'OldMacdonald',
      extendedPanId: '1122334455667788',
      meshLocalPrefix: 'fd11:22::',
      networkKey: '00112233445566778899AABBCCDDEEFF',
      pskc: '00112233445566778899AABBCCDDEEFF',
    );
  }

  String _commissioningSubtitle(OperatorRuntime runtime) {
    if (runtime.matterPlatformFailed) {
      return 'Commissioning is blocked by the Matter platform failure.';
    }
    if (!runtime.matterControllerInitialized) {
      return 'Initialize the Matter controller before pairing devices.';
    }
    return 'Pair Matter-over-Thread devices, then refresh discovery.';
  }
}

class _StepPanel extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final bool complete;
  final Widget child;
  final AppPanelTone? tone;

  const _StepPanel({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.complete,
    required this.child,
    this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: '$step: $title',
      subtitle: subtitle,
      leading: Icon(
        complete ? Icons.check_circle : Icons.radio_button_unchecked,
      ),
      tone: tone ?? (complete ? AppPanelTone.success : AppPanelTone.info),
      child: child,
    );
  }
}

class _MatterPlatformBlocked extends StatelessWidget {
  final OperatorRuntime runtime;

  const _MatterPlatformBlocked({required this.runtime});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matter platform did not initialize on the Orchestrator.',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          'Controller initialization and device commissioning are blocked until firmware diagnostics are resolved.',
          style: AppTextStyles.mutedBody,
        ),
        const SizedBox(height: AppDimensions.spacingM),
        AppMetricTile(
          label: 'Reported platform error',
          value: runtime.matterPlatformError ?? 'Unknown platform failure',
          detail: 'Open Diagnostics for serial-log instructions.',
          tone: AppMetricTone.critical,
        ),
      ],
    );
  }
}

class _CommissionDeviceForm extends ConsumerStatefulWidget {
  final OperatorRuntime runtime;

  const _CommissionDeviceForm({required this.runtime});

  @override
  ConsumerState<_CommissionDeviceForm> createState() =>
      _CommissionDeviceFormState();
}

class _CommissionDeviceFormState extends ConsumerState<_CommissionDeviceForm> {
  final _nodeId = TextEditingController(text: '1001');
  final _setupCode = TextEditingController(text: '20202021');
  final _discriminator = TextEditingController(text: '3840');
  String _typeHint = 'unknown';

  @override
  void dispose() {
    _nodeId.dispose();
    _setupCode.dispose();
    _discriminator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final command = ref.watch(matterCommandControllerProvider);
    final blocked =
        widget.runtime.matterPlatformFailed ||
        !widget.runtime.matterControllerInitialized;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (blocked)
          const Text(
            'Commissioning is unavailable until Matter platform and controller prerequisites are healthy.',
            style: AppTextStyles.mutedBody,
          )
        else
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _field(_nodeId, 'Node ID'),
              _field(_setupCode, 'Setup code'),
              _field(_discriminator, 'Discriminator'),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<String>(
                  initialValue: _typeHint,
                  decoration: const InputDecoration(labelText: 'Device type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'temperature',
                      child: Text('Temperature sensor'),
                    ),
                    DropdownMenuItem(value: 'relay', child: Text('Relay')),
                    DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                  ],
                  onChanged: (value) =>
                      setState(() => _typeHint = value ?? 'unknown'),
                ),
              ),
              FilledButton.icon(
                onPressed: command.submitting ? null : _pair,
                icon: const Icon(Icons.add_link),
                label: const Text('Pair over BLE + Thread'),
              ),
            ],
          ),
        if (command.message != null) ...[
          const SizedBox(height: AppDimensions.spacingS),
          Text(command.message!, style: AppTextStyles.mutedBody),
        ],
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void _pair() {
    ref
        .read(matterCommandControllerProvider.notifier)
        .pairBleThread(
          MatterPairBleThreadRequest(
            nodeId: _nodeId.text.trim(),
            setupCode: _setupCode.text.trim(),
            discriminator: _discriminator.text.trim(),
          ),
        );
  }
}
