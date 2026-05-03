import 'dart:async';

abstract class IWebSocketClient {
  bool get isConnecting;
  bool get isConnected;

  Stream<String> get messages;

  Future<bool> connect({
    required String url,
    String? rootCAAsset,
    bool enableCompression = true,
    Duration pingInterval = const Duration(seconds: 10),
  });

  Future<bool> sendMessage(String message);

  Future<void> disconnect({
    int code = 1000,
    String reason = 'Client disconnect',
  });

  StreamSubscription<String> listen({
    required void Function(String message) onMessage,
    required void Function() onDone,
    required void Function(Object error) onError,
  });

  int? get closeCode;
  String? get closeReason;
}
