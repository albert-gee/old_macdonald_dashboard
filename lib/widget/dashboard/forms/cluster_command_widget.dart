import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/cluster_command/cluster_command_bloc.dart';

class ClusterCommandWidget extends StatelessWidget {
  final TextEditingController destinationIdController = TextEditingController();
  final TextEditingController endpointIdController = TextEditingController();
  final TextEditingController clusterIdController = TextEditingController();
  final TextEditingController commandIdController = TextEditingController();
  final TextEditingController commandDataController = TextEditingController();

  ClusterCommandWidget({super.key});

  void _setDefaultValues() {
    destinationIdController.text = "0x1122";
    endpointIdController.text = "1";
    clusterIdController.text = "6";
    commandIdController.text = "1";
    commandDataController.text = "{}";
  }

  @override
  Widget build(BuildContext context) {
    final clusterCommandBloc = BlocProvider.of<ClusterCommandBloc>(context);

    return BlocListener<ClusterCommandBloc, ClusterCommandState>(
      listener: (context, state) {
        if (state is ClusterCommandSuccess) {
          _showSnackBar(context, "Command sent successfully!", Colors.green);
        } else if (state is ClusterCommandFailure) {
          _showSnackBar(context, "Error: ${state.error}", Colors.red);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Invoke Cluster Command",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),

          const Text(
            "Enter the details to invoke a cluster command on a Matter device. This includes the destination ID, endpoint ID, cluster ID, command ID, and the command data.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16.0),

          Row(
            children: [
              Expanded(child: _buildTextField(destinationIdController, "Destination ID")),
              const SizedBox(width: 16.0),
              Expanded(child: _buildTextField(endpointIdController, "Endpoint ID", true)),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(child: _buildTextField(clusterIdController, "Cluster ID", true)),
              const SizedBox(width: 16.0),
              Expanded(child: _buildTextField(commandIdController, "Command ID", true)),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildTextField(commandDataController, "Command Data"),
          const SizedBox(height: 16.0),
          Row(
            children: [
              _invokeButton(context, clusterCommandBloc),
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

  Widget _invokeButton(BuildContext context, ClusterCommandBloc bloc) {
    return ElevatedButton(
      onPressed: () => _sendClusterCommand(context, bloc),
      child: const Text("Invoke Command"),
    );
  }

  Widget _setDefaultButton() {
    return ElevatedButton(
      onPressed: _setDefaultValues,
      child: const Text("Set Default"),
    );
  }

  void _sendClusterCommand(BuildContext context, ClusterCommandBloc bloc) {
    final String destinationId = destinationIdController.text.trim();
    final String commandData = commandDataController.text.trim();

    final int? endpointId = int.tryParse(endpointIdController.text.trim());
    final int? clusterId = int.tryParse(clusterIdController.text.trim());
    final int? commandId = int.tryParse(commandIdController.text.trim());

    if (destinationId.isEmpty || commandData.isEmpty || endpointId == null || clusterId == null || commandId == null) {
      _showSnackBar(context, "Invalid input. Please check your fields.", Colors.red);
      return;
    }

    bloc.add(ClusterCommandRequested(
      destinationId: destinationId,
      endpointId: endpointId,
      clusterId: clusterId,
      commandId: commandId,
      commandDataField: commandData,
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
