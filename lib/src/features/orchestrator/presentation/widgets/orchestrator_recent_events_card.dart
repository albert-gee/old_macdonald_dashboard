import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';

class OrchestratorRecentEventsCard extends ConsumerWidget {
  final bool showContainer;

  const OrchestratorRecentEventsCard({
    super.key,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref
        .watch(orchestratorRuntimeControllerProvider)
        .recentEvents
        .take(20);
    final content = events.isEmpty
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
          );
    if (!showContainer) return content;
    return AppPanel(
      title: 'Recent Events',
      tone: AppPanelTone.neutral,
      child: content,
    );
  }
}
