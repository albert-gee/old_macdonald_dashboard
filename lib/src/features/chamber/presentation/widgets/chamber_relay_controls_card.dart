import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
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

    return AppCard(
      title: 'Relay Controls',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.relayOptions.isEmpty)
            const Text('No relay capabilities registered.')
          else
            DropdownButtonFormField<DeviceSelection>(
              initialValue: selected,
              decoration: const InputDecoration(
                labelText: 'Relay capability',
                prefixIcon: Icon(Icons.power),
              ),
              items: [
                for (final option in state.relayOptions)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      '${option.label}${option.reachable ? '' : ' (offline)'}',
                    ),
                  ),
              ],
              onChanged: controller.selectRelay,
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
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
                const Text('Command pending')
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
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                state.relay.error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }
}
