import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/security/certificate_fingerprint.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class OrchestratorCertificateTrustCard extends ConsumerStatefulWidget {
  const OrchestratorCertificateTrustCard({super.key});

  @override
  ConsumerState<OrchestratorCertificateTrustCard> createState() =>
      _OrchestratorCertificateTrustCardState();
}

class _OrchestratorCertificateTrustCardState
    extends ConsumerState<OrchestratorCertificateTrustCard> {
  final _fingerprint = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _fingerprint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = ref.watch(orchestratorConnectionControllerProvider).url;
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    final secure = uri?.scheme == 'wss';
    final store = ref.watch(certificateTrustStoreProvider);
    return AppCard(
      title: 'Certificate / Trust',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            secure
                ? 'WSS requires a matching trusted SHA-256 fingerprint.'
                : 'Plain ws:// does not use TLS certificate pinning.',
          ),
          const SizedBox(height: 8),
          if (host.isNotEmpty)
            FutureBuilder<Result<String?>>(
              future: store.readTrustedFingerprint(host),
              builder: (context, snapshot) {
                final result = snapshot.data;
                final trusted = result is Success<String?>
                    ? result.value
                    : null;
                return Text(
                  trusted == null
                      ? 'No trusted fingerprint for $host.'
                      : 'Trusted: ${CertificateFingerprint.parse(trusted).display}',
                );
              },
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _fingerprint,
            decoration: const InputDecoration(
              labelText: 'SHA-256 fingerprint',
              hintText: 'AA:BB:CC...',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: host.isEmpty ? null : () => _save(host),
                icon: const Icon(Icons.verified_user),
                label: const Text('Trust'),
              ),
              OutlinedButton.icon(
                onPressed: host.isEmpty ? null : () => _clear(host),
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ],
          ),
          if (_message != null) ...[const SizedBox(height: 8), Text(_message!)],
        ],
      ),
    );
  }

  Future<void> _save(String host) async {
    try {
      await ref
          .read(certificateTrustStoreProvider)
          .saveTrustedFingerprint(host, _fingerprint.text);
      setState(() => _message = 'Trusted fingerprint saved.');
    } on FormatException catch (error) {
      setState(() => _message = error.message);
    }
  }

  Future<void> _clear(String host) async {
    await ref.read(certificateTrustStoreProvider).clearTrustedFingerprint(host);
    setState(() => _message = 'Trusted fingerprint cleared.');
  }
}
