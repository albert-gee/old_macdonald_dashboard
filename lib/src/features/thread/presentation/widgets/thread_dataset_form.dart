import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';

class ThreadDatasetForm extends ConsumerStatefulWidget {
  const ThreadDatasetForm({super.key});

  @override
  ConsumerState<ThreadDatasetForm> createState() => _ThreadDatasetFormState();
}

class _ThreadDatasetFormState extends ConsumerState<ThreadDatasetForm> {
  final _formKey = GlobalKey<FormState>();
  final _channelController = TextEditingController();
  final _panIdController = TextEditingController();
  final _networkNameController = TextEditingController();
  final _extendedPanIdController = TextEditingController();
  final _meshLocalPrefixController = TextEditingController();
  final _networkKeyController = TextEditingController();
  final _pskcController = TextEditingController();

  @override
  void dispose() {
    _channelController.dispose();
    _panIdController.dispose();
    _networkNameController.dispose();
    _extendedPanIdController.dispose();
    _meshLocalPrefixController.dispose();
    _networkKeyController.dispose();
    _pskcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(threadDatasetInitControllerProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
      }
    });
    final state = ref.watch(threadDatasetInitControllerProvider);

    return AppCard(
      title: 'Thread Dataset',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppDimensions.spacingM,
              runSpacing: AppDimensions.spacingM,
              children: [
                _field(
                  controller: _channelController,
                  label: 'Channel',
                  validator: _requiredIntValidator('Channel'),
                ),
                _field(
                  controller: _panIdController,
                  label: 'PAN ID',
                  validator: _requiredIntValidator('PAN ID'),
                ),
                _field(
                  controller: _networkNameController,
                  label: 'Network name',
                  validator: _requiredValidator('Network name'),
                ),
                _field(
                  controller: _extendedPanIdController,
                  label: 'Extended PAN ID',
                  validator: _requiredValidator('Extended PAN ID'),
                ),
                _field(
                  controller: _meshLocalPrefixController,
                  label: 'Mesh-local prefix',
                  validator: _requiredValidator('Mesh-local prefix'),
                ),
                _field(
                  controller: _networkKeyController,
                  label: 'Network key',
                  validator: _requiredValidator('Network key'),
                ),
                _field(
                  controller: _pskcController,
                  label: 'PSKc',
                  validator: _requiredValidator('PSKc'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ElevatedButton.icon(
              onPressed: state.submitting ? null : _submit,
              icon: state.submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(state.submitting ? 'Submitting...' : 'Initialize'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: 260,
      child: AppLabeledTextField(
        controller: controller,
        label: label,
        keyboardType: label == 'Channel' || label == 'PAN ID'
            ? TextInputType.number
            : null,
        validator: validator,
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    ref.read(threadDatasetInitControllerProvider.notifier).submit(
          ThreadDatasetInitRequest(
            channel: int.parse(_channelController.text.trim()),
            panId: int.parse(_panIdController.text.trim()),
            networkName: _networkNameController.text.trim(),
            extendedPanId: _extendedPanIdController.text.trim(),
            meshLocalPrefix: _meshLocalPrefixController.text.trim(),
            networkKey: _networkKeyController.text.trim(),
            pskc: _pskcController.text.trim(),
          ),
        );
  }

  String? Function(String?) _requiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required.';
      }
      return null;
    };
  }

  String? Function(String?) _requiredIntValidator(String label) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return '$label is required.';
      if (int.tryParse(trimmed) == null) return '$label must be an integer.';
      return null;
    };
  }
}
