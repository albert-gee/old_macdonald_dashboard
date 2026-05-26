import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/security/certificate_fingerprint.dart';
import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';

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

    return AppPanel(
      title: 'Secure trust',
      subtitle: secure
          ? 'WSS connections use pinned SHA-256 certificate fingerprints.'
          : 'Plain ws:// does not use TLS certificate pinning.',
      tone: trusted == null && secure
          ? AppPanelTone.warning
          : AppPanelTone.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMetricTile(
            label: 'Trusted certificate',
            value: trusted == null ? 'Not trusted' : 'Trusted',
            detail: host.isEmpty
                ? 'No host selected.'
                : trusted ?? 'Host: $host',
            tone: trusted == null ? AppMetricTone.warning : AppMetricTone.good,
          ),
          if (trusted == null && secure) ...[
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              'Pair before normal WSS connection.',
              style: TextStyle(color: AppColors.warning),
            ),
          ],
          if (observed != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text('Observed during pairing: $observed'),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
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
          const SizedBox(height: AppDimensions.spacingL),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Advanced manual fingerprint fallback'),
            children: [
              TextField(
                controller: _fingerprint,
                decoration: const InputDecoration(
                  labelText: 'Developer fallback fingerprint',
                  hintText: 'AA:BB:CC...',
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: host.isEmpty ? null : _saveManual,
                  icon: const Icon(Icons.build),
                  label: const Text('Save Manual Fingerprint'),
                ),
              ),
              if (_manualMessage != null) ...[
                const SizedBox(height: AppDimensions.spacingS),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_manualMessage!),
                ),
              ],
              const SizedBox(height: AppDimensions.spacingS),
            ],
          ),
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
