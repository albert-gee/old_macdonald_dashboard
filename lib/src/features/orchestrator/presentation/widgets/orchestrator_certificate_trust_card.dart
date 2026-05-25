import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
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
  String? _manualMessage;

  @override
  void dispose() {
    _fingerprint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orchestratorConnectionControllerProvider);
    final controller = ref.read(
      orchestratorConnectionControllerProvider.notifier,
    );
    final uri = Uri.tryParse(state.url);
    final secure = uri?.scheme == 'wss';
    final host = state.host ?? uri?.host ?? '';
    final trusted = _display(state.trustedFingerprint);
    final observed = _display(state.observedFingerprint);

    return AppCard(
      title: 'Certificate / Trust',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(host.isEmpty ? 'No host selected.' : 'Host: $host'),
          const SizedBox(height: 8),
          Text(
            secure
                ? 'WSS uses pinned SHA-256 certificate fingerprints.'
                : 'Plain ws:// does not use TLS certificate pinning.',
          ),
          const SizedBox(height: 8),
          Text(
            trusted == null
                ? 'No trusted fingerprint for this host.'
                : 'Trusted: $trusted',
          ),
          if (trusted == null && secure) ...[
            const SizedBox(height: 4),
            Text(
              'Pair before normal WSS connection.',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ],
          if (observed != null) ...[
            const SizedBox(height: 8),
            Text('Observed during pairing: $observed'),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: secure && host.isNotEmpty && !state.loading
                    ? controller.pairAndCapture
                    : null,
                icon: const Icon(Icons.link),
                label: const Text('Pair / Trust Orchestrator'),
              ),
              OutlinedButton.icon(
                onPressed: observed == null || state.loading
                    ? null
                    : controller.trustObservedFingerprint,
                icon: const Icon(Icons.verified_user),
                label: const Text('Trust Observed'),
              ),
              OutlinedButton.icon(
                onPressed: trusted == null || state.loading
                    ? null
                    : controller.clearTrustedFingerprint,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Trust'),
              ),
            ],
          ),
          const Divider(height: 24),
          TextField(
            controller: _fingerprint,
            decoration: const InputDecoration(
              labelText: 'Developer fallback fingerprint',
              hintText: 'AA:BB:CC...',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: host.isEmpty ? null : _saveManual,
            icon: const Icon(Icons.build),
            label: const Text('Save Manual Fingerprint'),
          ),
          if (_manualMessage != null) ...[
            const SizedBox(height: 8),
            Text(_manualMessage!),
          ],
        ],
      ),
    );
  }

  Future<void> _saveManual() async {
    try {
      await ref
          .read(orchestratorConnectionControllerProvider.notifier)
          .saveTrustedFingerprint(_fingerprint.text);
      setState(() => _manualMessage = 'Manual fingerprint saved.');
    } on FormatException catch (error) {
      setState(() => _manualMessage = error.message);
    }
  }

  String? _display(String? fingerprint) {
    if (fingerprint == null) return null;
    return CertificateFingerprint.parse(fingerprint).display;
  }
}
