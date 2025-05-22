import 'package:dashboard/widget/content/dashboard/forms/wifi_sta_connect_form_widget.dart';
import 'package:flutter/material.dart';

class WifiStaPage extends StatelessWidget {
  const WifiStaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: WifiStaConnectFormWidget(),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
        const SizedBox(height: 50.0),
      ],
    );
  }
}
