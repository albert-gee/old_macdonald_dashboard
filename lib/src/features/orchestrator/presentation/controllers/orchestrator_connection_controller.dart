import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/security/certificate_fingerprint.dart';
import 'package:dashboard/src/core/security/certificate_trust_store.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_url_repository.dart';
import 'orchestrator_connection_state.dart';

final class OrchestratorConnectionController
    extends StateNotifier<OrchestratorConnectionState> {
  final AppConfig _config;
  final OrchestratorUrlRepository _urlRepository;
  final CertificateTrustStore? _trustStore;
  final OrchestratorConnectionRepository _connectionRepository;
  late final StreamSubscription<WebSocketConnectionStatus> _statusSubscription;
  late final StreamSubscription<String> _certificateSubscription;

  OrchestratorConnectionController({
    required AppConfig config,
    required OrchestratorUrlRepository urlRepository,
    CertificateTrustStore? trustStore,
    required OrchestratorConnectionRepository connectionRepository,
  }) : _config = config,
       _urlRepository = urlRepository,
       _trustStore = trustStore,
       _connectionRepository = connectionRepository,
       super(OrchestratorConnectionState(url: config.defaultWebSocketUrl)) {
    _statusSubscription = _connectionRepository.status.listen((status) {
      state = state.copyWith(
        status: status,
        loading: false,
        clearMessage: true,
      );
    });
    _certificateSubscription = _connectionRepository
        .observedCertificateFingerprints
        .listen((fingerprint) {
          state = state.copyWith(
            observedFingerprint: CertificateFingerprint.parse(
              fingerprint,
            ).compact,
          );
        });
    loadInitialUrl();
  }

  Future<void> loadInitialUrl() async {
    final savedUrl = await _urlRepository.readUrl();
    state = switch (savedUrl) {
      Success(value: final url?) => state.copyWith(url: url),
      Success(value: null) => state.copyWith(url: _config.defaultWebSocketUrl),
      FailureResult(failure: final failure) => state.copyWith(
        url: _config.defaultWebSocketUrl,
        message: failure.message,
      ),
    };
    await loadTrustForCurrentHost();
  }

  void updateUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    state = state.copyWith(
      url: url,
      host: uri?.host,
      success: false,
      clearMessage: true,
      clearTrustedFingerprint: true,
      clearObservedFingerprint: true,
    );
    loadTrustForCurrentHost();
  }

  Future<void> connect([String? url]) async {
    final targetUrl = (url ?? state.url).trim();
    final trustedFingerprint = await _trustedFingerprint(targetUrl);
    final uri = Uri.tryParse(targetUrl);
    if (uri?.scheme == 'wss' && trustedFingerprint == null) {
      state = state.copyWith(
        url: targetUrl,
        host: uri?.host,
        loading: false,
        message: 'No trusted Orchestrator fingerprint. Pair before connecting.',
        success: false,
        clearObservedFingerprint: true,
      );
      return;
    }
    state = state.copyWith(
      url: targetUrl,
      host: uri?.host,
      trustedFingerprint: trustedFingerprint,
      loading: true,
      pairing: false,
      clearMessage: true,
      clearObservedFingerprint: true,
    );

    final settings = WebSocketConnectionSettings.fromInput(
      targetUrl,
      rootCaAssetPath: _config.rootCaAssetPath,
      trustedFingerprint: trustedFingerprint,
    );
    switch (settings) {
      case FailureResult(failure: final failure):
        state = state.copyWith(
          loading: false,
          message: failure.message,
          success: false,
        );
        return;
      case Success(value: final value):
        if (_connectionRepository.isConnected) {
          await _connectionRepository.disconnect();
        }
        final result = await _connectionRepository.connect(value);
        switch (result) {
          case Success():
            await _urlRepository.saveUrl(targetUrl);
            state = state.copyWith(
              loading: false,
              status: WebSocketConnectionStatus.connected,
              message: 'Connected.',
              success: true,
            );
          case FailureResult(failure: final failure):
            state = state.copyWith(
              loading: false,
              status: WebSocketConnectionStatus.disconnected,
              message: failure.message,
              success: false,
            );
        }
    }
  }

  Future<String?> _trustedFingerprint(String targetUrl) async {
    final uri = Uri.tryParse(targetUrl);
    if (uri == null || uri.host.isEmpty) return null;
    final store = _trustStore;
    if (store == null) return null;
    final result = await store.readTrustedFingerprint(uri.host);
    return switch (result) {
      Success(value: final value) => value,
      FailureResult() => null,
    };
  }

  Future<void> loadTrustForCurrentHost() async {
    final uri = Uri.tryParse(state.url);
    final host = uri?.host;
    if (host == null || host.isEmpty) {
      state = state.copyWith(
        clearTrustedFingerprint: true,
        clearObservedFingerprint: true,
      );
      return;
    }
    final trusted = await _trustedFingerprint(state.url);
    state = state.copyWith(host: host, trustedFingerprint: trusted);
  }

  Future<void> pairAndCapture([String? url]) async {
    final targetUrl = (url ?? state.url).trim();
    final uri = Uri.tryParse(targetUrl);
    state = state.copyWith(
      url: targetUrl,
      host: uri?.host,
      loading: true,
      pairing: true,
      clearMessage: true,
      clearObservedFingerprint: true,
    );

    final settings = WebSocketConnectionSettings.fromInput(
      targetUrl,
      rootCaAssetPath: null,
      allowUntrustedForPairing: true,
    );
    switch (settings) {
      case FailureResult(failure: final failure):
        state = state.copyWith(
          loading: false,
          pairing: false,
          message: failure.message,
          success: false,
        );
      case Success(value: final value):
        if (_connectionRepository.isConnected) {
          await _connectionRepository.disconnect();
        }
        final result = await _connectionRepository.connect(value);
        state = switch (result) {
          Success() => state.copyWith(
            loading: false,
            status: WebSocketConnectionStatus.connected,
            message: state.observedFingerprint == null
                ? 'Connected in pairing mode. No certificate fingerprint was captured.'
                : 'Connected in pairing mode. Confirm trust to pin this Orchestrator.',
            success: true,
          ),
          FailureResult(failure: final failure) => state.copyWith(
            loading: false,
            pairing: false,
            status: WebSocketConnectionStatus.disconnected,
            message: failure.message,
            success: false,
          ),
        };
    }
  }

  Future<void> trustObservedFingerprint() async {
    final host = state.host;
    final observed = state.observedFingerprint;
    final store = _trustStore;
    if (host == null || host.isEmpty || observed == null || store == null) {
      state = state.copyWith(
        message: 'No observed certificate fingerprint to trust.',
        success: false,
      );
      return;
    }
    final result = await store.saveTrustedFingerprint(host, observed);
    state = switch (result) {
      Success() => state.copyWith(
        trustedFingerprint: CertificateFingerprint.parse(observed).compact,
        pairing: false,
        message: 'Trusted fingerprint saved.',
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        message: failure.message,
        success: false,
      ),
    };
  }

  Future<void> saveTrustedFingerprint(String fingerprint) async {
    final host = state.host;
    final store = _trustStore;
    if (host == null || host.isEmpty || store == null) return;
    final result = await store.saveTrustedFingerprint(host, fingerprint);
    state = switch (result) {
      Success() => state.copyWith(
        trustedFingerprint: CertificateFingerprint.parse(fingerprint).compact,
        message: 'Trusted fingerprint saved.',
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        message: failure.message,
        success: false,
      ),
    };
  }

  Future<void> clearTrustedFingerprint() async {
    final host = state.host;
    final store = _trustStore;
    if (host == null || host.isEmpty || store == null) return;
    await store.clearTrustedFingerprint(host);
    state = state.copyWith(
      clearTrustedFingerprint: true,
      message: 'Trusted fingerprint cleared.',
      success: true,
    );
  }

  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  Future<void> disconnect() async {
    await _connectionRepository.disconnect();
    state = state.copyWith(
      loading: false,
      status: WebSocketConnectionStatus.disconnected,
      message: 'Disconnected.',
      success: true,
    );
  }

  Future<void> clearSavedUrl() async {
    await _urlRepository.clearUrl();
    state = state.copyWith(url: '', clearMessage: true, success: false);
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _certificateSubscription.cancel();
    super.dispose();
  }
}
