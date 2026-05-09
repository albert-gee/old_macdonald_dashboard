import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';
import 'matter_cluster_picker.dart';
import 'matter_form_validators.dart';

class MatterAttributeReadForm extends ConsumerStatefulWidget {
  final List<MatterCluster> clusters;

  const MatterAttributeReadForm({super.key, required this.clusters});

  @override
  ConsumerState<MatterAttributeReadForm> createState() =>
      _MatterAttributeReadFormState();
}

class _MatterAttributeReadFormState
    extends ConsumerState<MatterAttributeReadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nodeId = TextEditingController();
  final _endpointId = TextEditingController();
  MatterCluster? _cluster;
  MatterAttribute? _attribute;

  @override
  void dispose() {
    _nodeId.dispose();
    _endpointId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(matterCommandControllerProvider).submitting;
    return Form(
      key: _formKey,
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          _field(_nodeId, 'Node ID', matterRequiredValidator),
          _field(_endpointId, 'Endpoint ID', matterIntValidator),
          SizedBox(
            width: 280,
            child: MatterClusterPicker(
              clusters: widget.clusters,
              value: _cluster,
              onChanged: (value) => setState(() {
                _cluster = value;
                _attribute = null;
              }),
            ),
          ),
          _attributePicker(),
          ElevatedButton(
            onPressed: submitting ? null : _submit,
            child: const Text('Read Attribute'),
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
      width: 180,
      child: AppLabeledTextField(
        controller: controller,
        label: label,
        keyboardType: label == 'Endpoint ID' ? TextInputType.number : null,
        validator: validatorFactory(label),
      ),
    );
  }

  Widget _attributePicker() {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<MatterAttribute>(
        initialValue: _attribute,
        decoration: const InputDecoration(labelText: 'Attribute'),
        items: (_cluster?.attributes ?? const <MatterAttribute>[])
            .map(
              (attribute) => DropdownMenuItem(
                value: attribute,
                child: Text('${attribute.name} (${attribute.id})'),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _attribute = value),
        validator: (value) => value == null ? 'Attribute is required.' : null,
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true ||
        _cluster == null ||
        _attribute == null) {
      return;
    }
    ref.read(matterCommandControllerProvider.notifier).readAttribute(
          MatterAttributeReadRequest(
            nodeId: _nodeId.text.trim(),
            endpointId: int.parse(_endpointId.text.trim()),
            clusterId: _cluster!.numericId,
            attributeId: _attribute!.numericId,
          ),
        );
  }
}
