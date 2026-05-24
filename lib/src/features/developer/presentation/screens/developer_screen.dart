import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/features/developer/presentation/widgets/raw_matter_tools_card.dart';
import 'package:dashboard/src/features/developer/presentation/widgets/raw_message_log_card.dart';
import 'package:dashboard/src/features/developer/presentation/widgets/raw_thread_tools_card.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          RawMatterToolsCard(),
          SizedBox(height: AppDimensions.spacingL),
          RawThreadToolsCard(),
          SizedBox(height: AppDimensions.spacingL),
          RawMessageLogCard(),
        ],
      ),
    );
  }
}
