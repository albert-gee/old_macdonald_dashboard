abstract class IWifiCommandService {
  /// Sends a command to connect to a Wi-Fi STA network.
  ///
  /// Throws an exception if the command fails or the connection is rejected.
  Future<void> sendStaConnectCommand({
    required String ssid,
    required String password,
  });
}
