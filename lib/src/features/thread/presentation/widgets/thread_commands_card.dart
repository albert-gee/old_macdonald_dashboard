import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class ThreadCommandsCard extends ConsumerWidget {
  const ThreadCommandsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(threadCommandControllerProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
      }
    });
    final state = ref.watch(threadCommandControllerProvider);
    final controller = ref.read(threadCommandControllerProvider.notifier);
    final disabled = state.submitting;

    return AppCard(
      title: 'Thread Commands',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          _button('Enable Thread', disabled, controller.enable),
          _button('Disable Thread', disabled, controller.disable),
          _button('Refresh Status', disabled, controller.refreshStatus),
          _button('Refresh Attachment', disabled, controller.refreshAttachment),
          _button('Refresh Role', disabled, controller.refreshRole),
          _button(
            'Refresh Active Dataset',
            disabled,
            controller.refreshActiveDataset,
          ),
          _button(
            'Refresh Unicast Addresses',
            disabled,
            controller.refreshUnicastAddresses,
          ),
          _button(
            'Refresh Multicast Addresses',
            disabled,
            controller.refreshMulticastAddresses,
          ),
          _button('Init Border Router', disabled, controller.initBorderRouter),
          _button(
            'Deinit Border Router',
            disabled,
            controller.deinitBorderRouter,
          ),
        ],
      ),
    );
  }

  Widget _button(String label, bool disabled, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      child: Text(label),
    );
  }
}
