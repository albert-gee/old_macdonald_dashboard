import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';

class ThreadDatasetInitFormWidget extends StatelessWidget {
  final TextEditingController channelController = TextEditingController();
  final TextEditingController panIdController = TextEditingController();
  final TextEditingController networkNameController = TextEditingController();
  final TextEditingController extendedPanIdController = TextEditingController();
  final TextEditingController meshLocalPrefixController = TextEditingController();
  final TextEditingController masterKeyController = TextEditingController();
  final TextEditingController pskcController = TextEditingController();

  ThreadDatasetInitFormWidget({Key? key}) : super(key: key);

  void _setDefaultValues() {
    channelController.text = "15";
    panIdController.text = "0x1234";
    networkNameController.text = "OpenThread-ESP";
    extendedPanIdController.text = "dead00beef00cafe";
    meshLocalPrefixController.text = "fd00:db8:a0:0::/64";
    masterKeyController.text = "00112233445566778899aabbccddeeff";
    pskcController.text = "104810e2315100afd6bc9215a6bfac53";
  }

  @override
  Widget build(BuildContext context) {
    final threadDatasetInitBloc = BlocProvider.of<ThreadDatasetInitBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Added title here
        const Text(
          "Thread Dataset",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16.0),

        // Row for Channel and PAN ID
        Row(
          children: [
            Expanded(child: _buildTextField(channelController, "Channel", true)),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(panIdController, "PAN ID", true)),
          ],
        ),
        const SizedBox(height: 16.0),

        // Row for Network Name and Extended PAN ID
        Row(
          children: [
            Expanded(child: _buildTextField(networkNameController, "Network Name")),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(extendedPanIdController, "Extended PAN ID")),
          ],
        ),
        const SizedBox(height: 16.0),

        // Row for Mesh Local Prefix and Master Key
        Row(
          children: [
            Expanded(child: _buildTextField(meshLocalPrefixController, "Mesh Local Prefix")),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(masterKeyController, "Master Key")),
          ],
        ),
        const SizedBox(height: 16.0),

        // PSKC field and the buttons
        Row(
          children: [
            Expanded(child: _buildTextField(pskcController, "PSKC")),
            const SizedBox(width: 16.0),
            // Buttons row
            Row(
              children: [
                _sendButton(context, threadDatasetInitBloc),
                const SizedBox(width: 16.0),
                _setDefaultButton(),
              ],
            ),
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

  Widget _sendButton(BuildContext context, ThreadDatasetInitBloc bloc) {
    return ElevatedButton(
      onPressed: () => _sendMessage(bloc),
      child: const Text("Send Data"),
    );
  }

  void _sendMessage(ThreadDatasetInitBloc bloc) {
    final dataset = {
      "command": "init_thread_network",
      "payload": {
        "channel": int.parse(channelController.text),
        "pan_id": int.parse(panIdController.text),
        "network_name": networkNameController.text,
        "extended_pan_id": extendedPanIdController.text,
        "mesh_local_prefix": meshLocalPrefixController.text,
        "master_key": masterKeyController.text,
        "pskc": pskcController.text,
      }
    };
    bloc.add(ThreadDatasetInitSendEvent(dataset));

    // Clear the form fields
    channelController.clear();
    panIdController.clear();
    networkNameController.clear();
    extendedPanIdController.clear();
    meshLocalPrefixController.clear();
    masterKeyController.clear();
    pskcController.clear();
  }

  Widget _setDefaultButton() {
    return ElevatedButton(
      onPressed: _setDefaultValues,
      child: const Text("Set Default"),
    );
  }
}