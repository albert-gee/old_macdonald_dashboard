import 'package:dashboard/widget/content/dashboard/forms/wifi_sta_connect_form_widget.dart';
import 'package:dashboard/widget/content/page_header.dart';
import 'package:flutter/material.dart';

class WifiStaPage extends StatelessWidget {
  final String title;

  const WifiStaPage({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header with title
          PageHeaderWidget(title: title),
          const SizedBox(height: 20.0),


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
      ),
    );
  }
}
