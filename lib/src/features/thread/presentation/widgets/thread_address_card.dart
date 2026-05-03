import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_address_state.dart';

class ThreadAddressCard extends StatelessWidget {
  final ThreadAddressState addresses;

  const ThreadAddressCard({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    final hasAddresses = addresses.unicastAddresses.isNotEmpty ||
        addresses.multicastAddresses.isNotEmpty;
    return AppCard(
      title: 'IP Addresses',
      child: hasAddresses
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _list(context, 'Unicast addresses', addresses.unicastAddresses),
                const SizedBox(height: AppDimensions.spacingM),
                _list(
                  context,
                  'Multicast addresses',
                  addresses.multicastAddresses,
                ),
              ],
            )
          : const Text('No addresses received yet.'),
    );
  }

  Widget _list(BuildContext context, String label, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spacingS),
        if (values.isEmpty) Text('No $label received yet.'),
        ...values.map(Text.new),
      ],
    );
  }
}
