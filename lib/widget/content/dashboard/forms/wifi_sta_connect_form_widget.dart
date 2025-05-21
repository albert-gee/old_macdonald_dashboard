import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/wifi_sta_connect/wifi_sta_connect_bloc.dart';

class WifiStaConnectFormWidget extends StatelessWidget {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  WifiStaConnectFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final wifiStaConnectBloc = BlocProvider.of<WifiStaConnectBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Connect to Wi-Fi",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12.0),

        const Text(
          "To connect the Wi-Fi STA to an existing Wi-Fi websocket, enter the SSID and password below.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20.0),

        _buildTextField(ssidController, "SSID"),
        const SizedBox(height: 16.0),
        _buildTextField(passwordController, "Password", true),
        const SizedBox(height: 24.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _connectButton(context, wifiStaConnectBloc),
            const SizedBox(width: 16.0),
            _clearButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [bool isPassword = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlueAccent),
          ),
        ),
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _connectButton(BuildContext context, WifiStaConnectBloc bloc) {
    return ElevatedButton(
      onPressed: () => _connectToWifi(bloc),
      child: const Text("Connect"),
    );
  }

  void _connectToWifi(WifiStaConnectBloc bloc) {
    bloc.add(WifiStaConnectSendEvent(ssidController.text, passwordController.text));

    // Clear the form fields
    ssidController.clear();
    passwordController.clear();
  }

  Widget _clearButton() {
    return ElevatedButton(
      onPressed: () {
        ssidController.clear();
        passwordController.clear();
      },
      child: const Text("Clear"),
    );
  }
}
