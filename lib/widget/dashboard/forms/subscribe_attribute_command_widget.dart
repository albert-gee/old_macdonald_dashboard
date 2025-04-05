import 'package:dashboard/blocs/subscribe_attribute/subscribe_attribute_command_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscribeAttributeCommandWidget extends StatelessWidget {
  final TextEditingController nodeIdController = TextEditingController();
  final TextEditingController endpointIdController = TextEditingController();
  final TextEditingController clusterIdController = TextEditingController();
  final TextEditingController attributeIdController = TextEditingController();
  final TextEditingController minIntervalController = TextEditingController();
  final TextEditingController maxIntervalController = TextEditingController();

  SubscribeAttributeCommandWidget({super.key});

  void _setDefaultValues() {
    nodeIdController.text = "0x1122";
    endpointIdController.text = "1";
    clusterIdController.text = "1029"; // TemperatureMeasurement
    attributeIdController.text = "0"; // MeasuredValue
    minIntervalController.text = "5";
    maxIntervalController.text = "30";
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SubscribeAttributeCommandBloc>(context);

    return BlocListener<SubscribeAttributeCommandBloc, SubscribeAttributeCommandState>(
      listener: (context, state) {
        if (state is SubscribeAttributeCommandSuccess) {
          _showSnackBar(context, "Subscribed successfully!", Colors.green);
        } else if (state is SubscribeAttributeCommandFailure) {
          _showSnackBar(context, "Error: ${state.error}", Colors.red);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Subscribe Attribute",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            "Enter the details to subscribe to an attribute on a Matter device.",
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
              Expanded(child: _buildTextField(minIntervalController, "Min Interval", true)),
              const SizedBox(width: 16.0),
              Expanded(child: _buildTextField(maxIntervalController, "Max Interval", true)),
            ],
          ),
          const SizedBox(height: 16.0),

          Row(
            children: [
              _invokeButton(context, bloc),
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

  Widget _invokeButton(BuildContext context, SubscribeAttributeCommandBloc bloc) {
    return ElevatedButton(
      onPressed: () => _sendSubscribeCommand(context, bloc),
      child: const Text("Subscribe"),
    );
  }

  Widget _setDefaultButton() {
    return ElevatedButton(
      onPressed: _setDefaultValues,
      child: const Text("Set Default"),
    );
  }

  void _sendSubscribeCommand(BuildContext context, SubscribeAttributeCommandBloc bloc) {
    final String nodeId = nodeIdController.text.trim();
    final int? endpointId = int.tryParse(endpointIdController.text.trim());
    final int? clusterId = int.tryParse(clusterIdController.text.trim());
    final int? attributeId = int.tryParse(attributeIdController.text.trim());
    final int? minInterval = int.tryParse(minIntervalController.text.trim());
    final int? maxInterval = int.tryParse(maxIntervalController.text.trim());

    if (nodeId.isEmpty || endpointId == null || clusterId == null || attributeId == null || minInterval == null || maxInterval == null) {
      _showSnackBar(context, "Invalid input. Please check your fields.", Colors.red);
      return;
    }

    bloc.add(SubscribeAttributeCommandRequested(
      nodeId: nodeId,
      endpointId: endpointId,
      clusterId: clusterId,
      attributeId: attributeId,
      minInterval: minInterval,
      maxInterval: maxInterval,
      autoResubscribe: false,
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
