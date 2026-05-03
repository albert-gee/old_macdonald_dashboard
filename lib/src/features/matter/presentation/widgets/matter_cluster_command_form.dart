import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'matter_cluster_picker.dart';
import 'matter_form_validators.dart';

class MatterClusterCommandForm extends ConsumerStatefulWidget {
  final List<MatterCluster> clusters;

  const MatterClusterCommandForm({super.key, required this.clusters});

  @override
  ConsumerState<MatterClusterCommandForm> createState() =>
      _MatterClusterCommandFormState();
}

class _MatterClusterCommandFormState
    extends ConsumerState<MatterClusterCommandForm> {
  final _formKey = GlobalKey<FormState>();
  final _destinationId = TextEditingController();
  final _endpointId = TextEditingController();
  final _commandId = TextEditingController();
  final _commandData = TextEditingController(text: '{}');
  MatterCluster? _cluster;

  @override
  void dispose() {
    _destinationId.dispose();
    _endpointId.dispose();
    _commandId.dispose();
    _commandData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(matterCommandControllerProvider).submitting;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            children: [
              _field(_destinationId, 'Destination ID', matterRequiredValidator),
              _field(_endpointId, 'Endpoint ID', matterIntValidator),
              SizedBox(
                width: 280,
                child: MatterClusterPicker(
                  clusters: widget.clusters,
                  value: _cluster,
                  onChanged: (value) => setState(() => _cluster = value),
                ),
              ),
              _field(_commandId, 'Command ID', matterIntValidator),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          AppLabeledTextField(
            controller: _commandData,
            label: 'Command data',
            maxLines: 4,
            validator: matterRequiredValidator('Command data'),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ElevatedButton(
            onPressed: submitting ? null : _submit,
            child: const Text('Invoke Cluster Command'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String? Function(String?) Function(String) validatorFactory,
  ) {
    return SizedBox(
      width: 200,
      child: AppLabeledTextField(
        controller: controller,
        label: label,
        keyboardType: label.contains('ID') && label != 'Destination ID'
            ? TextInputType.number
            : null,
        validator: validatorFactory(label),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true || _cluster == null) return;
    ref.read(matterCommandControllerProvider.notifier).invokeClusterCommand(
          MatterClusterCommandRequest(
            destinationId: _destinationId.text.trim(),
            endpointId: int.parse(_endpointId.text.trim()),
            clusterId: _cluster!.numericId,
            commandId: int.parse(_commandId.text.trim()),
            commandData: _commandData.text.trim(),
          ),
        );
  }
}
