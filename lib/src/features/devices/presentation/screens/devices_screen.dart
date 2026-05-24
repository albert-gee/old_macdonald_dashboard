import 'package:flutter/material.dart';

import 'package:dashboard/src/features/devices/presentation/widgets/device_list_card.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(child: DeviceListCard());
  }
}
