import 'package:dashboard/blocs/read_attribute_command/read_attribute_command_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReadAttributeCommandWidget extends StatelessWidget {
  final TextEditingController nodeIdController = TextEditingController();
  final TextEditingController endpointIdController = TextEditingController();
  final TextEditingController clusterIdController = TextEditingController();
  final TextEditingController attributeIdController = TextEditingController();

  ReadAttributeCommandWidget({super.key});

  void _setDefaultValues() {
    nodeIdController.text = "0x1122";
    endpointIdController.text = "1";
    clusterIdController.text = "6";
    attributeIdController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    final readAttributeCommandBloc = BlocProvider.of<ReadAttributeCommandBloc>(context);

    return BlocListener<ReadAttributeCommandBloc, ReadAttributeCommandState>(
      listener: (context, state) {
        if (state is ReadAttributeCommandSuccess) {
          _showSnackBar(context, "Command sent successfully!", Colors.green);
        } else if (state is ReadAttributeCommandFailure) {
          _showSnackBar(context, "Error: ${state.error}", Colors.red);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Read Attribute",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),

          const Text(
            "Enter the details to read an attribute from a Matter device. This includes the Node ID, Endpoint ID, Cluster ID, and Attribute ID.",
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
              Expanded(child: _buildTextField(endpointIdController, "Endpoint ID", true)),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(child: _buildTextField(clusterIdController, "Cluster ID", true)),
              const SizedBox(width: 16.0),
              Expanded(child: _buildTextField(attributeIdController, "Attribute ID", true)),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              _invokeButton(context, readAttributeCommandBloc),
              const SizedBox(width: 16.0),
              _setDefaultButton(),
            ],
          ),
        ],
      ),
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

  Widget _invokeButton(BuildContext context, ReadAttributeCommandBloc bloc) {
    return ElevatedButton(
      onPressed: () => _sendReadAttrCommand(context, bloc),
      child: const Text("Invoke Command"),
    );
  }

  Widget _setDefaultButton() {
    return ElevatedButton(
      onPressed: _setDefaultValues,
      child: const Text("Set Default"),
    );
  }

  void _sendReadAttrCommand(BuildContext context, ReadAttributeCommandBloc bloc) {
    final String nodeId = nodeIdController.text.trim();
    final int? endpointId = int.tryParse(endpointIdController.text.trim());
    final int? clusterId = int.tryParse(clusterIdController.text.trim());
    final int? attributeId = int.tryParse(attributeIdController.text.trim());

    if (nodeId.isEmpty || endpointId == null || clusterId == null || attributeId == null) {
      _showSnackBar(context, "Invalid input. Please check your fields.", Colors.red);
      return;
    }

    bloc.add(ReadAttributeCommandRequested(
      nodeId: nodeId,
      endpointId: endpointId,
      clusterId: clusterId,
      attributeId: attributeId,
    ));
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
