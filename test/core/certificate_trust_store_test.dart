import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/security/certificate_trust_store.dart';
import 'package:dashboard/src/core/storage/shared_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves reads and clears trusted fingerprint by host', () async {
    SharedPreferences.setMockInitialValues({});
    final store = CertificateTrustStore(store: SharedPreferencesStore());
    const fingerprint =
        'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:'
        'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99';

    expect(
      await store.saveTrustedFingerprint('192.168.4.1', fingerprint),
      isA<Success<void>>(),
    );
    final read = await store.readTrustedFingerprint('192.168.4.1');
    expect((read as Success<String?>).value, startsWith('aabbcc'));

    await store.clearTrustedFingerprint('192.168.4.1');
    final cleared = await store.readTrustedFingerprint('192.168.4.1');
    expect((cleared as Success<String?>).value, isNull);
  });
}
