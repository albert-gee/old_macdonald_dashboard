import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_state.dart';

class MatterRecentEventsCard extends ConsumerWidget {
  const MatterRecentEventsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(matterEventControllerProvider).recentEvents;
    return AppCard(
      title: 'Recent Events',
      child: events.isEmpty
          ? const Text('No Matter events received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: events.map(_eventText).map(Text.new).toList(),
            ),
    );
  }

  String _eventText(MatterEvent event) {
    return switch (event) {
      MatterCommissioningCompleteEvent(:final nodeId, :final fabricIndex) =>
        'Commissioning complete: node $nodeId, fabric $fabricIndex',
      MatterAttributeReportEvent(:final report) =>
        'Attribute report: node ${report.nodeId}, endpoint ${report.endpointId}, cluster ${report.clusterId}, attribute ${report.attributeId}: ${report.value}',
      MatterSubscribeDoneEvent(:final nodeId, :final subscriptionId) =>
        'Subscribe done: node $nodeId, subscription $subscriptionId',
    };
  }
}
