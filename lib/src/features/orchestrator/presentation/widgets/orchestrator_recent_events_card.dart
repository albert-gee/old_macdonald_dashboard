import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class OrchestratorRecentEventsCard extends ConsumerWidget {
  const OrchestratorRecentEventsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref
        .watch(orchestratorRuntimeControllerProvider)
        .recentEvents
        .take(20);
    return AppCard(
      title: 'Recent Events',
      child: events.isEmpty
          ? const Text('No events received yet.')
          : Column(
              children: [
                for (final event in events)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(event.type),
                    subtitle: Text(event.payload.toString()),
                    trailing: Text(
                      TimeOfDay.fromDateTime(event.receivedAt).format(context),
                    ),
                  ),
              ],
            ),
    );
  }
}
