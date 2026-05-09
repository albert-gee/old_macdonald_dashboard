import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/wifi/presentation/widgets/wifi_sta_connect_form.dart';

class WifiStaScreen extends ConsumerWidget {
  const WifiStaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(wifiStaStatusControllerProvider).status;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            title: 'Wi-Fi STA Status',
            child: Text(status),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const AppCard(
            title: 'Wi-Fi STA Connection',
            child: WifiStaConnectForm(),
          ),
        ],
      ),
    );
  }
}
