import 'package:shared_preferences/shared_preferences.dart';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/storage/preferences_store.dart';

final class SharedPreferencesStore implements PreferencesStore {
  final Future<SharedPreferences> _preferences;

  SharedPreferencesStore({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance();

  @override
  Future<Result<String?>> readString(String key) async {
    try {
      return Success((await _preferences).getString(key));
    } catch (error) {
      return FailureResult(StorageFailure('Unable to read saved preference.'));
    }
  }

  @override
  Future<Result<void>> writeString(String key, String value) async {
    try {
      await (await _preferences).setString(key, value);
      return const Success(null);
    } catch (error) {
      return FailureResult(StorageFailure('Unable to save preference.'));
    }
  }

  @override
  Future<Result<void>> remove(String key) async {
    try {
      await (await _preferences).remove(key);
      return const Success(null);
    } catch (error) {
      return FailureResult(StorageFailure('Unable to remove preference.'));
    }
  }
}
