import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/storage/shared_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('reads and writes strings', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesStore();

    final write = await store.writeString('url', 'ws://localhost/ws');
    expect(write, isA<Success<void>>());

    final read = await store.readString('url') as Success<String?>;
    expect(read.value, 'ws://localhost/ws');
  });
}
