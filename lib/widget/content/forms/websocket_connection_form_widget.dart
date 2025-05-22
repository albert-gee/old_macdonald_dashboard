import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/styles/app_dimensions.dart';
import 'package:dashboard/widget/content/labeled_text_field.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';

/// Form widget for establishing a WebSocket connection.
///
/// Provides a labeled input field for the connection URL and
/// a set of context-aware control buttons: Connect, Clear, and Disconnect.
class WebsocketConnectFormWidget extends StatelessWidget {
  /// Controller for the WebSocket URL input field.
  final TextEditingController urlController = TextEditingController();

  WebsocketConnectFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final websocketBloc = context.read<WebsocketConnectionBloc>();

    return BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
      builder: (context, state) {
        final isConnecting = state is WebsocketConnectionConnectingState;
        final isConnected = state is WebsocketConnectionConnectedState;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input for the WebSocket URL
            LabeledTextField(
              controller: urlController,
              label: "WebSocket URL",
              hint: "wss://192.168.4.1/ws",
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Action buttons: Connect, Clear, Disconnect
            Row(
              children: [
                // Connect / Reconnect button
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: isConnecting
                        ? null
                        : () => websocketBloc.add(
                      WebsocketConnectionConnectingEvent(
                        urlController.text,
                      ),
                    ),
                    icon: isConnecting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.wifi),
                    label: Text(
                      isConnected
                          ? "Reconnect"
                          : isConnecting
                          ? "Connecting..."
                          : "Connect",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected
                          ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 180)
                          : isConnecting
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(width: AppDimensions.spacingM),

                // Clear button
                Flexible(
                  child: OutlinedButton(
                    onPressed: urlController.clear,
                    child: const Text("Clear"),
                  ),
                ),

                // Disconnect button (visible only when connected)
                if (isConnected) ...[
                  const SizedBox(width: AppDimensions.spacingM),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () => websocketBloc.add(
                        const WebsocketConnectionDisconnectingEvent(),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text("Disconnect"),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}
