import 'package:dashboard/src/core/security/certificate_fingerprint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes SHA-256 fingerprint', () {
    final fingerprint = CertificateFingerprint.parse(
      'aa bb cc dd ee ff 00 11 22 33 44 55 66 77 88 99 '
      'aa bb cc dd ee ff 00 11 22 33 44 55 66 77 88 99',
    );
    expect(fingerprint.compact, startsWith('aabbcc'));
    expect(fingerprint.display, startsWith('AA:BB:CC'));
  });
}
