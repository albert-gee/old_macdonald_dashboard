import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/features/chamber/presentation/widgets/chamber_relay_controls_card.dart';
import 'package:dashboard/src/features/chamber/presentation/widgets/chamber_sensor_cards.dart';
import 'package:dashboard/src/features/chamber/presentation/widgets/chamber_status_card.dart';

class ChamberScreen extends StatelessWidget {
  const ChamberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          ChamberStatusCard(),
          SizedBox(height: AppDimensions.spacingL),
          ChamberSensorCards(),
          SizedBox(height: AppDimensions.spacingL),
          ChamberRelayControlsCard(),
        ],
      ),
    );
  }
}
