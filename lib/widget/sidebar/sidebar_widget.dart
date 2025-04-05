import 'package:dashboard/widget/sidebar/ifconfig_status_widget.dart';
import 'package:dashboard/widget/sidebar/temperature_set_widget.dart';
import 'package:dashboard/widget/sidebar/thread_role_widget.dart';
import 'package:dashboard/widget/sidebar/thread_status_widget.dart';
import 'package:dashboard/widget/sidebar/websocket_connect_button_widget.dart';
import 'package:dashboard/widget/sidebar/wifi_sta_status_widget.dart';
import 'package:flutter/material.dart';

class SideBarWidget extends StatelessWidget {
  final Color backgroundColor;
  final double width;

  const SideBarWidget({
    super.key,
    required this.backgroundColor,
    required this.width
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: const IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.0),
                    WebsocketConnectButtonWidget(),

                    SizedBox(height: 10.0),
                    IfconfigStatusWidget(),

                    SizedBox(height: 10.0),
                    ThreadRoleWidget(),

                    SizedBox(height: 10.0),
                    ThreadStatusWidget(),

                    SizedBox(height: 10.0),
                    WifiStaStatusWidget(),

                    SizedBox(height: 10.0),
                    TemperatureSetWidget(),

                    // Add more widgets here as needed
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}