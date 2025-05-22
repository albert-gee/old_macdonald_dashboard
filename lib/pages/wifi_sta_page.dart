import 'package:dashboard/widget/content/card_widget.dart';
import 'package:dashboard/widget/content/forms/wifi_sta_connect_form_widget.dart';
import 'package:flutter/material.dart';

class WifiStaPage extends StatelessWidget {
  const WifiStaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardWidget(
          title: "Wi-Fi STA Connection",
          child: WifiStaConnectFormWidget(),
        ),
      ],
    );
  }
}
