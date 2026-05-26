import 'package:flutter/material.dart';

import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_recent_events_card.dart';

class RawMessageLogCard extends StatelessWidget {
  const RawMessageLogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      title: 'Raw protocol log',
      subtitle: 'Recent command, event, and runtime messages for debugging.',
      tone: AppPanelTone.neutral,
      child: OrchestratorRecentEventsCard(showContainer: false),
    );
  }
}
