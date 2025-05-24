import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/styles/app_dimensions.dart';
import 'package:dashboard/widget/content/labeled_text_field.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';

/// A form widget for entering a WebSocket URL and controlling connection state.
class WebsocketConnectionFormWidget extends StatelessWidget {
  final TextEditingController urlTextFieldController = TextEditingController();

  WebsocketConnectionFormWidget({super.key});

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
            // URL input field
            LabeledTextField(
              controller: urlTextFieldController,
              label: "WebSocket URL",
              hint: "wss://192.168.4.1/ws",
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Action buttons
            Row(
              children: [
                // Connect / Reconnect button
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: isConnecting
                        ? null
                        : () => websocketBloc.add(
                              WebsocketConnectionConnectRequested(
                                urlTextFieldController.text,
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
                ),
                const SizedBox(width: AppDimensions.spacingM),

                // Clear button
                Flexible(
                  child: OutlinedButton(
                    onPressed: urlTextFieldController.clear,
                    child: const Text("Clear"),
                  ),
                ),

                // Disconnect button (only when connected)
                if (isConnected) ...[
                  const SizedBox(width: AppDimensions.spacingM),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () => websocketBloc.add(
                        const WebsocketConnectionDisconnectRequested(),
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

  /// Returns the color for the Connect button based on state.
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
