import 'package:dashboard/src/core/errors/result.dart';

abstract interface class PreferencesStore {
  Future<Result<String?>> readString(String key);

  Future<Result<void>> writeString(String key, String value);

  Future<Result<void>> remove(String key);
}
