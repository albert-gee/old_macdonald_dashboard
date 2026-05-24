import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class ChamberStatusCard extends ConsumerWidget {
  const ChamberStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamberControllerProvider);
    final status = state.status;
    return AppCard(
      title: 'Chamber Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            onPressed: state.loading
                ? null
                : ref.read(chamberControllerProvider.notifier).refreshStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
          const SizedBox(height: 12),
          Text('Temperature: ${status?.temperatureCelsius ?? '-'} C'),
          Text('Pressure: ${status?.pressureKpa ?? '-'} kPa'),
          Text(
            'Relay: ${status?.relayOn == null
                ? '-'
                : status!.relayOn!
                ? 'on'
                : 'off'}',
          ),
          const Text('Automation: not exposed by Orchestrator'),
          if (state.message != null) ...[
            const SizedBox(height: 12),
            Text(
              state.message!,
              style: TextStyle(
                color: state.success
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
