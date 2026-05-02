import 'package:dashboard/services/i_orchestrator_url_storage.dart';
import 'package:shared_preferences/shared_preferences.dart' as prefs;

typedef SharedPrefs = prefs.SharedPreferences;

class OrchestratorUrlStorage implements IOrchestratorUrlStorage {
  static const _key = 'orchestrator_url';

  @override
  Future<String?> readUrl() async {
    final storage = await SharedPrefs.getInstance();
    return storage.getString(_key);
  }

  @override
  Future<void> saveUrl(String url) async {
    final storage = await SharedPrefs.getInstance();
    await storage.setString(_key, url);
  }

  @override
  Future<void> clearUrl() async {
    final storage = await SharedPrefs.getInstance();
    await storage.remove(_key);
  }
}
