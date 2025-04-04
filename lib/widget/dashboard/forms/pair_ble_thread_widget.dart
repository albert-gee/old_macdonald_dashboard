import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/pair_ble_thread/pair_ble_thread_bloc.dart';

class PairBleThreadWidget extends StatelessWidget {
  final TextEditingController nodeIdController = TextEditingController();
  final TextEditingController setupCodeController = TextEditingController();
  final TextEditingController discriminatorController = TextEditingController();

  PairBleThreadWidget({super.key});

  void _setDefaultValues() {
    nodeIdController.text = "0x1122";
    setupCodeController.text = "20202021";
    discriminatorController.text = "3840";
  }

  @override
  Widget build(BuildContext context) {
    final pairBleThreadBloc = BlocProvider.of<PairBleThreadBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "BLE Thread Pairing",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16.0),
        const Text(
          "Enter the necessary information to pair a Matter device on a Thread network using BLE. This includes Node ID, Discriminator, and Setup Code.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(nodeIdController, "Node ID")),
            const SizedBox(width: 16.0),
            Expanded(
                child: _buildTextField(
                    discriminatorController, "Discriminator (0-4095)", true)),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    setupCodeController, "Setup Code (6-11 digits)", true)),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            _pairButton(context, pairBleThreadBloc),
            const SizedBox(width: 16.0),
            _setDefaultButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [bool isNumeric = false]) {
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
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _pairButton(BuildContext context, PairBleThreadBloc bloc) {
    return BlocBuilder<PairBleThreadBloc, PairBleThreadState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () => _sendPairingRequest(bloc),
          child: const Text("Start Pairing"),
        );
      },
    );
  }

  Widget _setDefaultButton() {
    return ElevatedButton(
      onPressed: _setDefaultValues,
      child: const Text("Set Default"),
    );
  }

  void _sendPairingRequest(PairBleThreadBloc bloc) {
    final pairingRequest = {
      "node_id": nodeIdController.text,
      "setup_code": setupCodeController.text, // Updated key
      "discriminator": discriminatorController.text,
    };

    print("Sending pairing request with data: $pairingRequest");

    bloc.add(PairBleThreadRequested(
      nodeId: pairingRequest["node_id"]!,
      setupCode: pairingRequest["setup_code"]!, // Updated key
      discriminator: pairingRequest["discriminator"]!,
    ));

    // Clear the form fields
    nodeIdController.clear();
    setupCodeController.clear();
    discriminatorController.clear();
  }
}
