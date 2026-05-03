import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_active_dataset_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_address_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_commands_card.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_status_card.dart';

class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(threadStatusControllerProvider).status;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThreadStatusCard(status: status),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadActiveDatasetCard(dataset: status.activeDataset),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadAddressCard(addresses: status.addresses),
          const SizedBox(height: AppDimensions.spacingL),
          const ThreadCommandsCard(),
          const SizedBox(height: AppDimensions.spacingL),
          const ThreadDatasetForm(),
        ],
      ),
    );
  }
}
