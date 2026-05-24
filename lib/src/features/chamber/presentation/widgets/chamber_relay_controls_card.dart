import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class ChamberRelayControlsCard extends ConsumerStatefulWidget {
  const ChamberRelayControlsCard({super.key});

  @override
  ConsumerState<ChamberRelayControlsCard> createState() =>
      _ChamberRelayControlsCardState();
}

class _ChamberRelayControlsCardState
    extends ConsumerState<ChamberRelayControlsCard> {
  final _relayDevice = TextEditingController();

  @override
  void dispose() {
    _relayDevice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chamberControllerProvider);
    final controller = ref.read(chamberControllerProvider.notifier);
    return AppCard(
      title: 'Relay Controls',
      child: Column(
        children: [
          TextField(
            controller: _relayDevice,
            decoration: const InputDecoration(labelText: 'Relay device ID'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: state.loading
                    ? null
                    : () => controller.setRelay(_relayDevice.text.trim(), true),
                icon: const Icon(Icons.power),
                label: const Text('On'),
              ),
              OutlinedButton.icon(
                onPressed: state.loading
                    ? null
                    : () =>
                          controller.setRelay(_relayDevice.text.trim(), false),
                icon: const Icon(Icons.power_off),
                label: const Text('Off'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
