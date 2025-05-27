import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dashboard/styles/app_dimensions.dart';
import 'package:dashboard/widget/content/labeled_text_field.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';

/// A form widget for entering a WebSocket URL and controlling connection state.
class WebsocketConnectionFormWidget extends StatefulWidget {
  const WebsocketConnectionFormWidget({super.key});

  @override
  State<WebsocketConnectionFormWidget> createState() =>
      _WebsocketConnectionFormWidgetState();
}

class _WebsocketConnectionFormWidgetState
    extends State<WebsocketConnectionFormWidget> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('orchestrator_url');
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledTextField(
              controller: _urlController,
              label: "WebSocket URL",
              hint: "wss://192.168.4.1/ws",
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
          ],
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
            : () => bloc.add(
          WebsocketConnectionConnectRequested(_urlController.text),
        ),
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
        onPressed: _urlController.clear,
        child: const Text("Clear"),
      ),
    );
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
