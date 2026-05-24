import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_commands_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';

class RawThreadToolsCard extends StatelessWidget {
  const RawThreadToolsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      title: 'Raw Thread Tools',
      child: Column(
        children: [
          ThreadCommandsCard(),
          SizedBox(height: AppDimensions.spacingL),
          ThreadDatasetForm(),
        ],
      ),
    );
  }
}
