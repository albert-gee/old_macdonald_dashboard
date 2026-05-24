final class CertificateTrustState {
  final String host;
  final String? trustedFingerprint;

  const CertificateTrustState({required this.host, this.trustedFingerprint});

  bool get hasTrustedFingerprint => trustedFingerprint != null;
}
