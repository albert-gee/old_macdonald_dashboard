import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/security/certificate_fingerprint.dart';
import 'package:dashboard/src/core/storage/preferences_store.dart';

final class CertificateTrustStore {
  final PreferencesStore _store;

  CertificateTrustStore({required PreferencesStore store}) : _store = store;

  Future<Result<String?>> readTrustedFingerprint(String host) {
    return _store.readString(_key(host));
  }

  Future<Result<void>> saveTrustedFingerprint(String host, String fingerprint) {
    final normalized = CertificateFingerprint.parse(fingerprint).compact;
    return _store.writeString(_key(host), normalized);
  }

  Future<Result<void>> clearTrustedFingerprint(String host) {
    return _store.remove(_key(host));
  }

  String _key(String host) => 'certificate_trust.$host.sha256';
}
