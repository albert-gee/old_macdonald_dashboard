import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/labeled_text_field.dart';
import 'package:dashboard/src/features/wifi/presentation/blocs/wifi_sta_connection_bloc.dart';

/// A form for connecting the Wi-Fi STA interface to an existing Access Point.
///
/// Includes SSID and password input fields, and triggers a connect event
/// using [WifiStaConnectionBloc].
class WifiStaConnectFormWidget extends StatefulWidget {
  const WifiStaConnectFormWidget({super.key});

  @override
  State<WifiStaConnectFormWidget> createState() =>
      _WifiStaConnectFormWidgetState();
}

class _WifiStaConnectFormWidgetState extends State<WifiStaConnectFormWidget> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WifiStaConnectionBloc>();

    return BlocConsumer<WifiStaConnectionBloc, WifiStaConnectionState>(
      listener: (context, state) {
        if (state is WifiStaConnectFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        } else if (state is WifiStaConnectSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wi-Fi STA connect command sent.')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WifiStaConnectLoadingState;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "To connect the Wi-Fi STA to an existing AP, enter the SSID and password below.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              LabeledTextField(
                controller: ssidController,
                label: "SSID",
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'SSID is required.'
                    : null,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              LabeledTextField(
                controller: passwordController,
                label: "Password",
                obscureText: true,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Password is required.' : null,
              ),
              const SizedBox(height: AppDimensions.spacingL * 1.5),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _connectToWifi(bloc),
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi),
                    label: Text(isLoading ? "Connecting..." : "Connect"),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  OutlinedButton(
                    onPressed: isLoading ? null : _clearFields,
                    child: const Text("Clear"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _connectToWifi(WifiStaConnectionBloc bloc) {
    if (_formKey.currentState?.validate() != true) return;
    bloc.add(WifiStaConnectionConnectRequested(
      ssidController.text.trim(),
      passwordController.text,
    ));
  }

  void _clearFields() {
    ssidController.clear();
    passwordController.clear();
  }
}
