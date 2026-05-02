class WebSocketConnectionSettings {
  final String url;
  final String? rootCAAsset;

  const WebSocketConnectionSettings({
    required this.url,
    required this.rootCAAsset,
  });

  static WebSocketConnectionSettings? fromInput(
    String input, {
    required String rootCaAssetPath,
  }) {
    final url = input.trim();
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.scheme != 'ws' && uri.scheme != 'wss') return null;
    if (uri.host.isEmpty) return null;

    return WebSocketConnectionSettings(
      url: url,
      rootCAAsset: uri.scheme == 'wss' ? rootCaAssetPath : null,
    );
  }
}
