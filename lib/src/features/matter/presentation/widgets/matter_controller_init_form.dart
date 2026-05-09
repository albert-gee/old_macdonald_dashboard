import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'matter_form_validators.dart';

class MatterControllerInitForm extends ConsumerStatefulWidget {
  const MatterControllerInitForm({super.key});

  @override
  ConsumerState<MatterControllerInitForm> createState() =>
      _MatterControllerInitFormState();
}

class _MatterControllerInitFormState
    extends ConsumerState<MatterControllerInitForm> {
  final _formKey = GlobalKey<FormState>();
  final _nodeId = TextEditingController();
  final _fabricId = TextEditingController();
  final _listenPort = TextEditingController();

  @override
  void dispose() {
    _nodeId.dispose();
    _fabricId.dispose();
    _listenPort.dispose();
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
          _field(
            _nodeId,
            'Node ID',
            validator: matterUnsignedDecimalStringValidator('Node ID'),
          ),
          _field(_fabricId, 'Fabric ID'),
          _field(_listenPort, 'Listen port'),
          ElevatedButton(
            onPressed: submitting ? null : _submit,
            child: const Text('Initialize Controller'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 180,
      child: AppLabeledTextField(
        controller: controller,
        label: label,
        keyboardType: TextInputType.number,
        validator: validator ?? matterIntValidator(label),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    ref.read(matterCommandControllerProvider.notifier).initializeController(
          MatterControllerInitRequest(
            nodeId: _nodeId.text.trim(),
            fabricId: int.parse(_fabricId.text.trim()),
            listenPort: int.parse(_listenPort.text.trim()),
          ),
        );
  }
}
