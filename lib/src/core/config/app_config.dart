class AppConfig {
  final String appTitle;
  final String appSubtitle;
  final String defaultWebSocketUrl;
  final String rootCaAssetPath;

  const AppConfig({
    required this.appTitle,
    required this.appSubtitle,
    required this.defaultWebSocketUrl,
    required this.rootCaAssetPath,
  });

  const AppConfig.local()
      : appTitle = 'Old MacDonald',
        appSubtitle = 'Controlled Environment',
        defaultWebSocketUrl = 'wss://192.168.4.1/ws',
        rootCaAssetPath = 'assets/rootCA.pem';
}
