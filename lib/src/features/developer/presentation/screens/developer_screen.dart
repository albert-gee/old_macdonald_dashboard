import 'package:flutter/material.dart';

import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/developer/presentation/widgets/raw_matter_tools_card.dart';
import 'package:dashboard/src/features/developer/presentation/widgets/raw_message_log_card.dart';
import 'package:dashboard/src/features/developer/presentation/widgets/raw_thread_tools_card.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Developer',
      description: 'Raw protocol tools and diagnostics for recovery work.',
      children: [
        AppPanel(
          title: 'Developer tools',
          subtitle:
              'Developer tools bypass normal operator workflows. Use for diagnostics and recovery.',
          tone: AppPanelTone.warning,
          child: Text(
            'Raw commands and technical fields are intentionally kept separate from operator pages.',
          ),
        ),
        RawMatterToolsCard(),
        RawThreadToolsCard(),
        RawMessageLogCard(),
      ],
    );
  }
}
