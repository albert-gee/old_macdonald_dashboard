sealed class AppFailure {
  final String message;

  const AppFailure(this.message);

  @override
  String toString() => message;
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class WebSocketConnectionFailure extends AppFailure {
  const WebSocketConnectionFailure(super.message);
}

final class WebSocketDisconnectedFailure extends AppFailure {
  const WebSocketDisconnectedFailure([
    super.message = 'WebSocket is not connected.',
  ]);
}

final class WebSocketSendFailure extends AppFailure {
  const WebSocketSendFailure(super.message);
}

final class MessageParseFailure extends AppFailure {
  const MessageParseFailure(super.message);
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

final class AssetLoadFailure extends AppFailure {
  const AssetLoadFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
