import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_commands_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';

class RawThreadToolsCard extends StatelessWidget {
  const RawThreadToolsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      title: 'Raw Thread diagnostics',
      subtitle:
          'Low-level Thread commands and manual dataset recovery tools.',
      tone: AppPanelTone.neutral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Thread command diagnostics'),
            subtitle: Text(
              'Sends raw Thread commands directly to the Orchestrator for diagnostics.',
            ),
            children: [
              ThreadCommandsCard(),
              SizedBox(height: AppDimensions.spacingM),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Manual Thread dataset initialization'),
            subtitle: Text(
              'Development/recovery only. This includes low-level Thread credentials.',
            ),
            children: [
              ThreadDatasetForm(
                title: 'Manual Thread dataset initialization',
                warning:
                    'This form is for development and recovery. It includes low-level Thread credentials. Do not use it during normal operation unless you know what you are doing.',
              ),
              SizedBox(height: AppDimensions.spacingM),
            ],
          ),
        ],
      ),
    );
  }
}
