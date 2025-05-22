import 'package:dashboard/widget/content/websocket/websocket_connection_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/widget/content/page_header.dart';

class MainPage extends StatelessWidget {
  final String title;

  const MainPage({
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

          WebsocketConnectFormWidget(),
        ],
      ),
    );
  }
}
