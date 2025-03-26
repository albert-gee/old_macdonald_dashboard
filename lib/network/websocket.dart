import 'dart:convert';
import 'dart:ui';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Websocket {
  final Uri wsUrl;
  WebSocketChannel? channel;
  bool websocketConnecting =
      false; // Flag to indicate whether a WebSocket connection attempt is currently in progress.

  Websocket(String wsUrl) : wsUrl = Uri.parse(wsUrl);

  /// Establish a connection to the WebSocket server.
  Future<void> connect() async {
    // Check if a connection attempt is already in progress. If so, exit the function
    // early to prevent another concurrent attempt.
    if (websocketConnecting) {
      return;
    }

    // Set the flag to true, indicating that a connection attempt is now underway.
    websocketConnecting = true;

    // Connect to the WebSocket server at the specified URL.
    // The pingInterval is set to send a "ping" message every 15 seconds to keep the
    // connection alive and check its health. The connectTimeout is set to 20 seconds,
    // meaning the connection attempt will time out if not established within this duration.
    channel = IOWebSocketChannel.connect(wsUrl,
        pingInterval: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 15));

    try {
      // Await the ready property of the channel, which is a Future that completes when
      // the WebSocket connection is successfully established. This ensures that the
      // following code only runs after a successful connection.
      await channel!.ready;
      // Once the connection is established, set up the stream listeners to handle
      // incoming messages, errors, and connection closures.
      websocketConnecting = false;
    } catch (e) {
      // If an error occurs during the connection attempt or while waiting for the
      // connection to become ready, log the error and perform cleanup.
      print('WebSocket connection failed or stream error occurred: $e');
      // Set the channel to null to clean up and indicate that there is no active
      // WebSocket connection.
      channel = null;
      // Reset the websocketConnecting flag to allow future connection attempts.
      websocketConnecting = false;
    }
  }

  Future<void> disconnect() async {
    if (isConnected()) {
      await channel!.sink.close();
      channel = null;
    }
  }

  Future<bool> sendMessage(String messageJson) async {
    bool isSent = false;

    if (channel != null) {
      channel!.sink.add(messageJson);
      isSent = true;
    }

    return isSent;
  }

  // void listen() {
  //   print('Listening to WebSocket messages');
  //
  //   channel!.stream.listen(
  //     (message) {
  //       // stream sends a data event when a message is received
  //       print('Received message: $message');
  //       onMessageReceived(message);
  //     },
  //     onError: (error) {
  //       print('WebSocket error: $error');
  //     },
  //     onDone: () {
  //       // stream closes and sends a done event when the WebSocket connection is closed
  //       print('WebSocket connection closed');
  //     },
  //   );
  // }
  void listen(
      {required void Function(String) onMessageReceived,
      required VoidCallback onDone,
      required void Function(String) onError}) {
    channel!.stream.listen(
      (message) {
        // stream sends a data event when a message is received
        print('Received message: $message');
        onMessageReceived(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
        onError(
            error); // stream sends an error event if an error occurs while receiving data
      },
      onDone: () {
        // stream closes and sends a done event when the WebSocket connection is closed
        print('WebSocket connection closed');
        onDone();
      },
    );
  }

  bool isConnected() {
    return channel != null && channel!.closeCode == null;
  }

  Future<bool> sendJsonMessage(Map<String, dynamic> message) async {
    final messageJson = jsonEncode(message);
    return await sendMessage(messageJson);
  }


  // Future<bool> sendJsonMessage(String command, String payload) async {
  //   final messageMap = {
  //     'token': 'secret_token_123',
  //     'command': command,
  //     'payload': payload,
  //   };
  //
  //   final messageMap = {
  //     'token': 'secret_token_123',
  //     "command": "init_thread_network",
  //     "payload": {
  //       "channel": 15,
  //       "pan_id": 0x1234,
  //       "network_name": "My-OpenThread",
  //       "extended_pan_id": "dead00beef00cafe",
  //       "mesh_local_prefix": "fd00:db8:a0:0::/64",
  //       "master_key": "00112233445566778899aabbccddeeff",
  //       "pskc": "104810e2315100afd6bc9215a6bfac53"
  //     }
  //   };
  //
  //   final messageJson = jsonEncode(messageMap);
  //   return await sendMessage(messageJson);
  // }
}
