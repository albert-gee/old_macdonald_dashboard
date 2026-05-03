import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_url_repository.dart';
import 'orchestrator_connection_state.dart';

final class OrchestratorConnectionController
    extends StateNotifier<OrchestratorConnectionState> {
  final AppConfig _config;
  final OrchestratorUrlRepository _urlRepository;
  final OrchestratorConnectionRepository _connectionRepository;
  late final StreamSubscription<WebSocketConnectionStatus> _statusSubscription;

  OrchestratorConnectionController({
    required AppConfig config,
    required OrchestratorUrlRepository urlRepository,
    required OrchestratorConnectionRepository connectionRepository,
  })  : _config = config,
        _urlRepository = urlRepository,
        _connectionRepository = connectionRepository,
        super(OrchestratorConnectionState(url: config.defaultWebSocketUrl)) {
    _statusSubscription = _connectionRepository.status.listen((status) {
      state =
          state.copyWith(status: status, loading: false, clearMessage: true);
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
  }

  void updateUrl(String url) {
    state = state.copyWith(url: url, success: false, clearMessage: true);
  }

  Future<void> connect([String? url]) async {
    final targetUrl = (url ?? state.url).trim();
    state = state.copyWith(url: targetUrl, loading: true, clearMessage: true);

    final settings = WebSocketConnectionSettings.fromInput(
      targetUrl,
      rootCaAssetPath: _config.rootCaAssetPath,
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
    super.dispose();
  }
}
