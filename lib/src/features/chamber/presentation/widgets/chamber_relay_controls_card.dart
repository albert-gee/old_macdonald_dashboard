import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';

class ChamberRelayControlsCard extends ConsumerWidget {
  const ChamberRelayControlsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamberControllerProvider);
    final controller = ref.read(chamberControllerProvider.notifier);
    final selected = state.relayOptions.contains(state.selectedRelay)
        ? state.selectedRelay
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPanel(
          title: 'Fan/relay actuator',
          subtitle:
              'Operate the selected On/Off actuator manually while automation is configured separately.',
          tone: state.relayOptions.isEmpty
              ? AppPanelTone.warning
              : AppPanelTone.info,
          child: _ActuatorControlSection(
            state: state,
            selected: selected,
            onChanged: controller.selectRelay,
            onSetRelay: controller.setRelay,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        AppPanel(
          title: 'Cooling automation',
          subtitle:
              'Save the temperature source, actuator, thresholds, and enabled state for the chamber cooling rule.',
          tone: _automationTone(state, selected),
          child: _CoolingAutomationSection(
            state: state,
            selected: selected,
            onMinChanged: controller.setMinCelsius,
            onMaxChanged: controller.setMaxCelsius,
            onSave: controller.saveTemperatureRule,
            onEnabledChanged: controller.setControlEnabled,
          ),
        ),
      ],
    );
  }

  AppPanelTone _automationTone(ChamberState state, DeviceSelection? selected) {
    if (state.controlError != null ||
        _ruleValidationMessage(state, selected) != null) {
      return AppPanelTone.warning;
    }
    if (state.controlEnabled) return AppPanelTone.success;
    return AppPanelTone.info;
  }
}

class _ActuatorControlSection extends StatelessWidget {
  final ChamberState state;
  final DeviceSelection? selected;
  final ValueChanged<DeviceSelection?> onChanged;
  final ValueChanged<bool> onSetRelay;

  const _ActuatorControlSection({
    required this.state,
    required this.selected,
    required this.onChanged,
    required this.onSetRelay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppMetricTile(
          label: 'Switchable actuator',
          value: _value(state, selected),
          detail: _detail(selected),
          icon: Icons.power_settings_new,
          tone: _tone(state, selected),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        if (state.relayOptions.isEmpty)
          const Text(
            'No switchable actuator capability is registered.',
            style: AppTextStyles.mutedBody,
          )
        else
          DropdownButtonFormField<DeviceSelection>(
            isExpanded: true,
            initialValue: selected,
            decoration: const InputDecoration(
              labelText: 'Actuator device function',
              prefixIcon: Icon(Icons.power),
            ),
            items: [
              for (final option in state.relayOptions)
                DropdownMenuItem(
                  value: option,
                  child: Text(
                    '${option.label}${option.reachable ? '' : ' (offline)'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        const SizedBox(height: AppDimensions.spacingM),
        Wrap(
          spacing: AppDimensions.spacingS,
          runSpacing: AppDimensions.spacingS,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: selected == null || state.relay.commandPending
                  ? null
                  : () => onSetRelay(true),
              icon: const Icon(Icons.power),
              label: const Text('On'),
            ),
            OutlinedButton.icon(
              onPressed: selected == null || state.relay.commandPending
                  ? null
                  : () => onSetRelay(false),
              icon: const Icon(Icons.power_off),
              label: const Text('Off'),
            ),
            if (state.relay.commandPending)
              const Text('Command accepted')
            else if (state.relay.lastCommandedOn != null)
              Text(
                state.relay.lastCommandedOn!
                    ? 'Last command: on'
                    : 'Last command: off',
              ),
          ],
        ),
        if (state.relay.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingS),
            child: Text(
              state.relay.error!,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
      ],
    );
  }

  String _value(ChamberState state, DeviceSelection? selected) {
    if (selected == null) return 'Unavailable';
    if (state.relay.commandPending) return 'Pending';
    if (state.relay.lastCommandedOn == null) return 'Ready';
    return state.relay.lastCommandedOn! ? 'Last on' : 'Last off';
  }

  String _detail(DeviceSelection? selected) {
    if (selected == null) return 'Select a device function before operating.';
    if (!selected.reachable) return 'Selected device is reported offline.';
    return 'Selected function: ${selected.label}';
  }

  AppMetricTone _tone(ChamberState state, DeviceSelection? selected) {
    if (selected == null) return AppMetricTone.neutral;
    if (state.relay.error != null) return AppMetricTone.warning;
    if (state.relay.commandPending) return AppMetricTone.pending;
    return AppMetricTone.good;
  }
}

class _CoolingAutomationSection extends StatelessWidget {
  final ChamberState state;
  final DeviceSelection? selected;
  final ValueChanged<double> onMinChanged;
  final ValueChanged<double> onMaxChanged;
  final VoidCallback onSave;
  final ValueChanged<bool> onEnabledChanged;

  const _CoolingAutomationSection({
    required this.state,
    required this.selected,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onSave,
    required this.onEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validationMessage = _ruleValidationMessage(state, selected);
    final canSave = validationMessage == null && !state.controlPending;
    final stateLabel = state.controlPending
        ? 'Saving'
        : _titleCase(state.controlState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppMetricTile(
          label: 'Automation state',
          value: stateLabel,
          detail: _automationDetail(state),
          icon: Icons.auto_mode,
          tone: _automationMetricTone(state, validationMessage),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        Wrap(
          spacing: AppDimensions.spacingM,
          runSpacing: AppDimensions.spacingM,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 180,
              child: TextFormField(
                key: ValueKey('min-${state.minCelsius}'),
                initialValue: state.minCelsius.toStringAsFixed(1),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Min C',
                  helperText: '-40 to 85 C',
                  prefixIcon: Icon(Icons.arrow_downward),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) onMinChanged(parsed);
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: TextFormField(
                key: ValueKey('max-${state.maxCelsius}'),
                initialValue: state.maxCelsius.toStringAsFixed(1),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Max C',
                  helperText: '-40 to 85 C',
                  prefixIcon: Icon(Icons.arrow_upward),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) onMaxChanged(parsed);
                },
              ),
            ),
            FilledButton.icon(
              onPressed: canSave ? onSave : null,
              icon: const Icon(Icons.save),
              label: const Text('Save rule'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: state.controlEnabled,
                  onChanged: canSave ? onEnabledChanged : null,
                ),
                const SizedBox(width: AppDimensions.spacingXS),
                const Text('Enabled'),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Text(
          validationMessage ??
              'Rule uses the selected temperature source and On/Off actuator.',
          style: validationMessage == null
              ? AppTextStyles.mutedBody
              : const TextStyle(color: AppColors.warning),
        ),
        if (state.controlError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingS),
            child: Text(
              state.controlError!,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
      ],
    );
  }

  String _automationDetail(ChamberState state) {
    if (state.controlError != null) return state.controlError!;
    if (state.controlPending) return 'Saving automation settings.';
    if (!state.controlEnabled) return 'Cooling automation is disabled.';
    return switch (state.controlState) {
      'cooling' => 'Actuator is on for cooling.',
      'idle' => 'Within configured range.',
      'stale' => 'Waiting for fresh sensor data.',
      'error' => 'Automation reported an error.',
      _ => 'Cooling automation is enabled.',
    };
  }

  AppMetricTone _automationMetricTone(
    ChamberState state,
    String? validationMessage,
  ) {
    if (state.controlPending) return AppMetricTone.pending;
    if (state.controlError != null ||
        validationMessage != null ||
        state.controlState == 'error' ||
        state.controlState == 'stale') {
      return AppMetricTone.warning;
    }
    if (!state.controlEnabled) return AppMetricTone.neutral;
    return AppMetricTone.good;
  }
}

String? _ruleValidationMessage(
  ChamberState state,
  DeviceSelection? selectedActuator,
) {
  if (state.selectedTemperature == null) {
    return 'Select a temperature source before saving automation.';
  }
  if (selectedActuator == null) {
    return 'Select an On/Off actuator before saving automation.';
  }
  if (!(state.minCelsius < state.maxCelsius)) {
    return 'Minimum temperature must be below maximum.';
  }
  const minAllowed = -40.0;
  const maxAllowed = 85.0;
  if (state.minCelsius < minAllowed ||
      state.minCelsius > maxAllowed ||
      state.maxCelsius < minAllowed ||
      state.maxCelsius > maxAllowed) {
    return 'Cooling thresholds must be between -40 C and 85 C.';
  }
  return null;
}

String _titleCase(String value) {
  if (value.isEmpty) return 'Idle';
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
