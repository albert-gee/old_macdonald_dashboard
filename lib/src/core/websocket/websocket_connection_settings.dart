import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';

final class WebSocketConnectionSettings {
  final String url;
  final String? rootCAAsset;

  const WebSocketConnectionSettings({
    required this.url,
    required this.rootCAAsset,
  });

  static Result<WebSocketConnectionSettings> fromInput(
    String input, {
    required String rootCaAssetPath,
  }) {
    final url = input.trim();
    if (url.isEmpty) {
      return const FailureResult(
          ValidationFailure('WebSocket URL is required.'));
    }

    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'ws' && uri.scheme != 'wss')) {
      return const FailureResult(
        ValidationFailure('Enter a valid ws:// or wss:// URL.'),
      );
    }
    if (uri.host.isEmpty) {
      return const FailureResult(
        ValidationFailure('WebSocket URL must include a host.'),
      );
    }

    return Success(
      WebSocketConnectionSettings(
        url: url,
        rootCAAsset: uri.scheme == 'wss' ? rootCaAssetPath : null,
      ),
    );
  }
}
