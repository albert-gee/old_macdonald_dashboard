import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';

class WifiStaConnectForm extends ConsumerStatefulWidget {
  const WifiStaConnectForm({super.key});

  @override
  ConsumerState<WifiStaConnectForm> createState() => _WifiStaConnectFormState();
}

class _WifiStaConnectFormState extends ConsumerState<WifiStaConnectForm> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(wifiStaConnectControllerProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
        if (next.success) _clearFields();
      }
    });

    final state = ref.watch(wifiStaConnectControllerProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabeledTextField(
            controller: _ssidController,
            label: 'SSID',
            enabled: !state.submitting,
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'SSID is required.' : null,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          AppLabeledTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            enabled: !state.submitting,
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'Password is required.' : null,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            children: [
              ElevatedButton.icon(
                onPressed: state.submitting ? null : _submit,
                icon: state.submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi),
                label: Text(state.submitting ? 'Connecting...' : 'Connect'),
              ),
              OutlinedButton(
                onPressed: state.submitting ? null : _clearFields,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    ref.read(wifiStaConnectControllerProvider.notifier).connect(
          WifiStaCredentials(
            ssid: _ssidController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _clearFields() {
    _ssidController.clear();
    _passwordController.clear();
  }
}
