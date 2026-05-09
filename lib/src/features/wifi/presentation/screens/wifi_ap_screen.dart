import 'package:flutter/material.dart';

import 'package:dashboard/src/core/widgets/empty_state_card.dart';

class WifiApScreen extends StatelessWidget {
  const WifiApScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateCard(
      title: 'Wi-Fi AP',
      icon: Icons.wifi_tethering,
      message: 'Wi-Fi AP controls are not available in this dashboard build.',
    );
  }
}
