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

    return AppPanel(
      title: 'Actuator controls',
      subtitle:
          'Operate registered switchable actuator capabilities for chamber control.',
      tone: state.relayOptions.isEmpty
          ? AppPanelTone.warning
          : AppPanelTone.info,
      child: Column(
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
              onChanged: controller.selectRelay,
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
                    : () => controller.setRelay(true),
                icon: const Icon(Icons.power),
                label: const Text('On'),
              ),
              OutlinedButton.icon(
                onPressed: selected == null || state.relay.commandPending
                    ? null
                    : () => controller.setRelay(false),
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
          const SizedBox(height: AppDimensions.spacingL),
          const Divider(),
          const SizedBox(height: AppDimensions.spacingM),
          Text('Cooling automation', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppDimensions.spacingM),
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
                    prefixIcon: Icon(Icons.arrow_downward),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) controller.setMinCelsius(parsed);
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
                    prefixIcon: Icon(Icons.arrow_upward),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) controller.setMaxCelsius(parsed);
                  },
                ),
              ),
              FilledButton.icon(
                onPressed:
                    selected == null ||
                        state.selectedTemperature == null ||
                        state.controlPending
                    ? null
                    : () => controller.saveTemperatureRule(),
                icon: const Icon(Icons.save),
                label: const Text('Save rule'),
              ),
              Switch(
                value: state.controlEnabled,
                onChanged:
                    selected == null ||
                        state.selectedTemperature == null ||
                        state.controlPending
                    ? null
                    : controller.setControlEnabled,
              ),
              Text(
                state.controlPending
                    ? 'Saving'
                    : 'State: ${state.controlState}',
              ),
            ],
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
      ),
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
