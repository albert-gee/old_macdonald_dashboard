import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/styles/app_dimensions.dart';
import 'package:dashboard/widget/content/labeled_text_field.dart';
import 'package:dashboard/blocs/wifi_sta_connect/wifi_sta_connection_bloc.dart';

/// A form for connecting the Wi-Fi STA interface to an existing Access Point.
///
/// Includes SSID and password input fields, and triggers a connect event
/// using [WifiStaConnectionBloc].
class WifiStaConnectFormWidget extends StatelessWidget {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  WifiStaConnectFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WifiStaConnectionBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructional text
        Text(
          "To connect the Wi-Fi STA to an existing AP, enter the SSID and password below.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppDimensions.spacingL),

        // SSID input
        LabeledTextField(
          controller: ssidController,
          label: "SSID",
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Password input
        LabeledTextField(
          controller: passwordController,
          label: "Password",
          obscureText: true,
        ),
        const SizedBox(height: AppDimensions.spacingL * 1.5),

        // Action buttons
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _connectToWifi(bloc),
              icon: const Icon(Icons.wifi),
              label: const Text("Connect"),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            OutlinedButton(
              onPressed: _clearFields,
              child: const Text("Clear"),
            ),
          ],
        ),
      ],
    );
  }

  void _connectToWifi(WifiStaConnectionBloc bloc) {
    bloc.add(WifiStaConnectionConnectRequested(
      ssidController.text,
      passwordController.text,
    ));
    _clearFields();
  }

  void _clearFields() {
    ssidController.clear();
    passwordController.clear();
  }
}
