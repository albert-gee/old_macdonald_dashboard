import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/pair_ble_thread/pair_ble_thread_bloc.dart';

class PairBleThreadWidget extends StatelessWidget {
  final TextEditingController nodeIdController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController discriminatorController = TextEditingController();

  PairBleThreadWidget({Key? key}) : super(key: key);

  void _setDefaultValues() {
    nodeIdController.text = "4386";
    pinController.text = "20202021";
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

        Row(
          children: [
            Expanded(child: _buildTextField(nodeIdController, "Node ID")),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(pinController, "PIN (6-11 digits)", true)),
          ],
        ),
        const SizedBox(height: 16.0),

        Row(
          children: [
            Expanded(child: _buildTextField(discriminatorController, "Discriminator (0-4095)", true)),
            const SizedBox(width: 16.0),
            _pairButton(context, pairBleThreadBloc),
            const SizedBox(width: 16.0),
            _setDefaultButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [bool isNumeric = false]) {
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
        if (state is PairBleThreadLoading || state is PairBleThreadInProgress) {
          return const CircularProgressIndicator();
        }

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
      "pin": pinController.text,
      "discriminator": discriminatorController.text,
    };

    print("Sending pairing request with data: $pairingRequest");

    bloc.add(PairBleThreadRequested(
      nodeId: pairingRequest["node_id"]!,
      pin: pairingRequest["pin"]!,
      discriminator: pairingRequest["discriminator"]!,
    ));

    // Clear the form fields
    nodeIdController.clear();
    pinController.clear();
    discriminatorController.clear();
  }
}