import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'matter_form_validators.dart';

class MatterPairBleThreadForm extends ConsumerStatefulWidget {
  const MatterPairBleThreadForm({super.key});

  @override
  ConsumerState<MatterPairBleThreadForm> createState() =>
      _MatterPairBleThreadFormState();
}

class _MatterPairBleThreadFormState
    extends ConsumerState<MatterPairBleThreadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nodeId = TextEditingController();
  final _setupCode = TextEditingController();
  final _discriminator = TextEditingController();

  @override
  void dispose() {
    _nodeId.dispose();
    _setupCode.dispose();
    _discriminator.dispose();
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
          _field(_nodeId, 'Node ID'),
          _field(_setupCode, 'Setup code'),
          _field(_discriminator, 'Discriminator'),
          ElevatedButton(
            onPressed: submitting ? null : _submit,
            child: const Text('Pair BLE Thread'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return SizedBox(
      width: 200,
      child: AppLabeledTextField(
        controller: controller,
        label: label,
        validator: matterRequiredValidator(label),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    ref.read(matterCommandControllerProvider.notifier).pairBleThread(
          MatterPairBleThreadRequest(
            nodeId: _nodeId.text.trim(),
            setupCode: _setupCode.text.trim(),
            discriminator: _discriminator.text.trim(),
          ),
        );
  }
}
