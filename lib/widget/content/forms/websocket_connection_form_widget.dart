import 'package:dashboard/services/i_orchestrator_url_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/labeled_text_field.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';

/// A form widget for entering a WebSocket URL and controlling connection state.
class WebsocketConnectionFormWidget extends StatefulWidget {
  final IOrchestratorUrlStorage urlStorage;

  const WebsocketConnectionFormWidget({
    super.key,
    required this.urlStorage,
  });

  @override
  State<WebsocketConnectionFormWidget> createState() =>
      _WebsocketConnectionFormWidgetState();
}

class _WebsocketConnectionFormWidgetState
    extends State<WebsocketConnectionFormWidget> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final savedUrl = await widget.urlStorage.readUrl();
    if (savedUrl != null && mounted) {
      setState(() {
        _urlController.text = savedUrl;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
      builder: (context, state) {
        final bloc = context.read<WebsocketConnectionBloc>();
        final isConnecting = state is WebsocketConnectionConnectingState;
        final isConnected = state is WebsocketConnectionConnectedState;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledTextField(
                controller: _urlController,
                label: "WebSocket URL",
                hint: "wss://192.168.4.1/ws",
                validator: _validateUrl,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              Row(
                children: [
                  _buildConnectButton(bloc, isConnecting, isConnected),
                  const SizedBox(width: AppDimensions.spacingM),
                  _buildClearButton(),
                  if (isConnected) ...[
                    const SizedBox(width: AppDimensions.spacingM),
                    _buildDisconnectButton(bloc),
                  ],
                ],
              ),
              if (state is WebsocketConnectionErrorState) ...[
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectButton(
    WebsocketConnectionBloc bloc,
    bool isConnecting,
    bool isConnected,
  ) {
    return Flexible(
      child: ElevatedButton.icon(
        onPressed: isConnecting
            ? null
            : () {
                if (_formKey.currentState?.validate() != true) return;
                bloc.add(
                  WebsocketConnectionConnectRequested(
                    _urlController.text.trim(),
                  ),
                );
              },
        icon: isConnecting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.wifi),
        label: Text(
          isConnecting
              ? "Connecting..."
              : isConnected
                  ? "Reconnect"
                  : "Connect",
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getConnectButtonColor(
            context,
            isConnected,
            isConnecting,
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Flexible(
      child: OutlinedButton(
        onPressed: () async {
          _urlController.clear();
          await widget.urlStorage.clearUrl();
        },
        child: const Text("Clear"),
      ),
    );
  }

  String? _validateUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return 'URL is required.';
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'ws' && uri.scheme != 'wss') ||
        uri.host.isEmpty) {
      return 'Enter a valid ws:// or wss:// URL.';
    }
    return null;
  }

  Widget _buildDisconnectButton(WebsocketConnectionBloc bloc) {
    return Flexible(
      child: OutlinedButton(
        onPressed: () =>
            bloc.add(const WebsocketConnectionDisconnectRequested()),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text("Disconnect"),
      ),
    );
  }

  Color _getConnectButtonColor(
    BuildContext context,
    bool isConnected,
    bool isConnecting,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isConnecting) return Theme.of(context).disabledColor;
    if (isConnected) return colorScheme.primary.withAlpha(180);
    return colorScheme.primary;
  }
}
