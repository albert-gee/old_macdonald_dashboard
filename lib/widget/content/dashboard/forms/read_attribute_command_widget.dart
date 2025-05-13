// import 'package:dashboard/blocs/read_attribute_command/read_attribute_command_bloc.dart';
// import 'package:dashboard/models/matter/cluster.dart';
// import 'package:dashboard/models/matter/xml_parser.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
//
// class ReadAttributeCommandWidget extends StatefulWidget {
//   const ReadAttributeCommandWidget({super.key});
//
//   @override
//   State<ReadAttributeCommandWidget> createState() =>
//       _ReadAttributeCommandWidgetState();
// }
//
// class _ReadAttributeCommandWidgetState
//     extends State<ReadAttributeCommandWidget> {
//   final TextEditingController nodeIdController =
//   TextEditingController(text: "0x1122");
//   final TextEditingController endpointIdController =
//   TextEditingController(text: "1");
//   final TextEditingController clusterIdController =
//   TextEditingController(text: "6");
//   final TextEditingController attributeIdController =
//   TextEditingController(text: "0");
//
//   Cluster? selectedCluster;
//   Attribute? selectedAttribute;
//   List<Cluster> clusters = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadClusters();
//   }
//
//   Future<void> _loadClusters() async {
//     final loadedClusters = await loadClusters();
//     setState(() {
//       clusters = loadedClusters;
//     });
//   }
//
//   void _sendReadAttrCommand(
//       BuildContext context, ReadAttributeCommandBloc bloc) {
//     final String nodeId = nodeIdController.text.trim();
//     final int? endpointId = int.tryParse(endpointIdController.text.trim());
//     final int? clusterId = int.tryParse(clusterIdController.text.trim());
//     final int? attributeId = int.tryParse(attributeIdController.text.trim());
//
//     if (nodeId.isEmpty ||
//         endpointId == null ||
//         clusterId == null ||
//         attributeId == null) {
//       _showSnackBar(context, "Invalid input. Please check your fields.", Colors.red);
//       return;
//     }
//
//     bloc.add(ReadAttributeCommandRequested(
//       nodeId: nodeId,
//       endpointId: endpointId,
//       clusterId: clusterId,
//       attributeId: attributeId,
//     ));
//   }
//
//   void _showSnackBar(BuildContext context, String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: color),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final readAttributeCommandBloc =
//     BlocProvider.of<ReadAttributeCommandBloc>(context);
//
//     return BlocListener<ReadAttributeCommandBloc, ReadAttributeCommandState>(
//       listener: (context, state) {
//         if (state is ReadAttributeCommandSuccess) {
//           _showSnackBar(context, "Command sent successfully!", Colors.green);
//         } else if (state is ReadAttributeCommandFailure) {
//           _showSnackBar(context, "Error: ${state.error}", Colors.red);
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Read Attribute",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 16.0),
//           const Text(
//             "Enter the details to read an attribute from a Matter device.",
//             style: TextStyle(fontSize: 14, color: Colors.white70),
//           ),
//           const SizedBox(height: 16.0),
//           Row(
//             children: [
//               Expanded(child: _buildTextField(nodeIdController, "Node ID")),
//               const SizedBox(width: 16.0),
//               Expanded(
//                   child: _buildTextField(endpointIdController, "Endpoint ID", true)),
//             ],
//           ),
//           const SizedBox(height: 16.0),
//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<Cluster>(
//                   isExpanded: true,
//                   value: selectedCluster,
//                   decoration: InputDecoration(
//                     labelText: "Cluster",
//                     labelStyle: const TextStyle(color: Colors.white70),
//                     border: const OutlineInputBorder(),
//                   ),
//                   items: clusters.map((cluster) {
//                     return DropdownMenuItem(
//                       value: cluster,
//                       child: Text(
//                         "${cluster.name} (${cluster.id})",
//                         style: const TextStyle(color: Colors.white),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (cluster) {
//                     setState(() {
//                       selectedCluster = cluster;
//                       clusterIdController.text = cluster?.id ?? '';
//                       selectedAttribute = null;
//                       attributeIdController.clear();
//                     });
//                   },
//                   dropdownColor: Colors.grey[900],
//                 ),
//               ),
//               const SizedBox(width: 16.0),
//               Expanded(
//                 child: DropdownButtonFormField<Attribute>(
//                   isExpanded: true,
//                   value: selectedAttribute,
//                   decoration: InputDecoration(
//                     labelText: "Attribute",
//                     labelStyle: const TextStyle(color: Colors.white70),
//                     border: const OutlineInputBorder(),
//                   ),
//                   items: (selectedCluster?.attributes ?? []).map((attr) {
//                     return DropdownMenuItem(
//                       value: attr,
//                       child: Text(
//                         "${attr.name} (${attr.id})",
//                         style: const TextStyle(color: Colors.white),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (attr) {
//                     setState(() {
//                       selectedAttribute = attr;
//                       attributeIdController.text = attr?.id ?? '';
//                     });
//                   },
//                   dropdownColor: Colors.grey[900],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16.0),
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: () =>
//                     _sendReadAttrCommand(context, readAttributeCommandBloc),
//                 child: const Text("Invoke Command"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label,
//       [bool isNumeric = false]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           hintText: label,
//           hintStyle: const TextStyle(color: Colors.white38),
//           border: const OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.white38),
//           ),
//           focusedBorder: const OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.lightBlueAccent),
//           ),
//         ),
//         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }
