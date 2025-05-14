import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';

class WebsocketConnectFormWidget extends StatelessWidget {
  final TextEditingController urlController = TextEditingController(text: "ws://192.168.4.1:80/ws");

  WebsocketConnectFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final websocketBloc = context.read<WebsocketConnectionBloc>();

    return BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
      builder: (context, state) {
        final bool isConnecting = state is WebsocketConnectionConnectingState;
        final bool isConnected = state is WebsocketConnectionConnectedState;
        final bool hasError = state is WebsocketConnectionErrorState;

        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0xff1e1e1e),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WebSocket Connection",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(urlController, "WebSocket URL"),
              const SizedBox(height: 20),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isConnecting
                        ? null
                        : () {
                      websocketBloc
                          .add(const WebsocketConnectionConnectingEvent());
                    },
                    icon: isConnecting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.wifi),
                    label: Text(isConnected
                        ? "Reconnect"
                        : isConnecting
                        ? "Connecting..."
                        : "Connect"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected
                          ? Colors.green
                          : isConnecting
                          ? Colors.grey
                          : Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => urlController.clear(),
                    child: const Text("Clear"),
                  ),
                  const SizedBox(width: 12),
                  if (isConnected)
                    OutlinedButton(
                      onPressed: () => websocketBloc
                          .add(const WebsocketConnectionDisconnectingEvent()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text("Disconnect"),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: "ws://192.168.4.1:80/ws",
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

}
