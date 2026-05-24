import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';

final class WebSocketConnectionSettings {
  final String url;
  final String host;
  final bool secure;
  final bool allowUntrustedForPairing;
  final String? trustedFingerprint;
  final String? rootCAAsset;

  const WebSocketConnectionSettings({
    required this.url,
    required this.host,
    required this.secure,
    this.allowUntrustedForPairing = false,
    this.trustedFingerprint,
    required this.rootCAAsset,
  });

  static Result<WebSocketConnectionSettings> fromInput(
    String input, {
    String? rootCaAssetPath,
    String? trustedFingerprint,
    bool allowUntrustedForPairing = false,
  }) {
    final url = input.trim();
    if (url.isEmpty) {
      return const FailureResult(
        ValidationFailure('WebSocket URL is required.'),
      );
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
        host: uri.host,
        secure: uri.scheme == 'wss',
        allowUntrustedForPairing: allowUntrustedForPairing,
        trustedFingerprint: trustedFingerprint,
        rootCAAsset: uri.scheme == 'wss' ? rootCaAssetPath : null,
      ),
    );
  }
}
