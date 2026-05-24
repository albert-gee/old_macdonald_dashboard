final class CertificateFingerprint {
  final String compact;

  const CertificateFingerprint._(this.compact);

  factory CertificateFingerprint.parse(String value) {
    final compact = value
        .replaceAll(':', '')
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(compact)) {
      throw const FormatException('Expected SHA-256 fingerprint.');
    }
    return CertificateFingerprint._(compact);
  }

  String get display {
    final pairs = <String>[];
    for (var index = 0; index < compact.length; index += 2) {
      pairs.add(compact.substring(index, index + 2).toUpperCase());
    }
    return pairs.join(':');
  }
}
