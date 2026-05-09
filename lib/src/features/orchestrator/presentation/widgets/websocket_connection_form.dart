import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/core/widgets/app_labeled_text_field.dart';

class WebsocketConnectionForm extends ConsumerStatefulWidget {
  const WebsocketConnectionForm({super.key});

  @override
  ConsumerState<WebsocketConnectionForm> createState() =>
      _WebsocketConnectionFormState();
}

class _WebsocketConnectionFormState
    extends ConsumerState<WebsocketConnectionForm> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orchestratorConnectionControllerProvider);
    final controller =
        ref.read(orchestratorConnectionControllerProvider.notifier);

    if (_urlController.text != state.url) {
      _urlController.text = state.url;
      _urlController.selection = TextSelection.collapsed(
        offset: _urlController.text.length,
      );
    }

    final connected = state.status == WebSocketConnectionStatus.connected;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabeledTextField(
            controller: _urlController,
            label: 'WebSocket URL',
            hint: 'wss://192.168.4.1/ws',
            validator: _validateUrl,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            children: [
              ElevatedButton.icon(
                onPressed: state.loading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() != true) return;
                        controller.connect(_urlController.text.trim());
                      },
                icon: state.loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi),
                label: Text(connected ? 'Reconnect' : 'Connect'),
              ),
              OutlinedButton(
                onPressed: state.loading
                    ? null
                    : () {
                        _urlController.clear();
                        controller.clearSavedUrl();
                      },
                child: const Text('Clear'),
              ),
              if (connected)
                OutlinedButton.icon(
                  onPressed: state.loading ? null : controller.disconnect,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                ),
            ],
          ),
          if (state.message != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              state.message!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: state.success
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String? _validateUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'URL is required.';
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'ws' && uri.scheme != 'wss') ||
        uri.host.isEmpty) {
      return 'Enter a valid ws:// or wss:// URL.';
    }
    return null;
  }
}
