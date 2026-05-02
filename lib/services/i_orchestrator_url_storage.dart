abstract class IOrchestratorUrlStorage {
  Future<String?> readUrl();
  Future<void> saveUrl(String url);
  Future<void> clearUrl();
}
