import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_url_repository.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_connection_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = AppConfig(
    appTitle: 'App',
    appSubtitle: 'Sub',
    defaultWebSocketUrl: 'ws://default/ws',
    rootCaAssetPath: 'assets/rootCA.pem',
  );

  test('uses saved URL if present', () async {
    final controller = OrchestratorConnectionController(
      config: config,
      urlRepository: _UrlRepo(saved: 'ws://saved/ws'),
      connectionRepository: _ConnectionRepo(),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.url, 'ws://saved/ws');
  });

  test('uses default URL if no saved URL', () async {
    final controller = OrchestratorConnectionController(
      config: config,
      urlRepository: _UrlRepo(),
      connectionRepository: _ConnectionRepo(),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.url, 'ws://default/ws');
  });

  test('invalid URL emits validation failure', () async {
    final controller = OrchestratorConnectionController(
      config: config,
      urlRepository: _UrlRepo(),
      connectionRepository: _ConnectionRepo(),
    );
    await controller.connect('http://bad');
    expect(controller.state.message, contains('ws:// or wss://'));
  });

  test('successful connect saves URL', () async {
    final urlRepo = _UrlRepo();
    final controller = OrchestratorConnectionController(
      config: config,
      urlRepository: urlRepo,
      connectionRepository: _ConnectionRepo(),
    );
    await controller.connect('ws://host/ws');
    expect(urlRepo.saved, 'ws://host/ws');
    expect(controller.state.status, WebSocketConnectionStatus.connected);
  });

  test('disconnected connect failure produces safe error', () async {
    final controller = OrchestratorConnectionController(
      config: config,
      urlRepository: _UrlRepo(),
      connectionRepository: _ConnectionRepo(
          connectResult: const FailureResult(
        WebSocketDisconnectedFailure(),
      )),
    );
    await controller.connect('ws://host/ws');
    expect(controller.state.message, 'WebSocket is not connected.');
  });
}

final class _UrlRepo implements OrchestratorUrlRepository {
  String? saved;
  _UrlRepo({this.saved});

  @override
  Future<Result<void>> clearUrl() async {
    saved = null;
    return const Success(null);
  }

  @override
  Future<Result<String?>> readUrl() async => Success(saved);

  @override
  Future<Result<void>> saveUrl(String url) async {
    saved = url;
    return const Success(null);
  }
}

final class _ConnectionRepo implements OrchestratorConnectionRepository {
  final Result<void> connectResult;
  _ConnectionRepo({this.connectResult = const Success(null)});

  @override
  bool get isConnected => false;

  @override
  Stream<WebSocketConnectionStatus> get status => const Stream.empty();

  @override
  Future<Result<void>> connect(WebSocketConnectionSettings settings) async =>
      connectResult;

  @override
  Future<void> disconnect() async {}

  @override
  Future<Result<void>> sendRaw(String message) async => const Success(null);
}
