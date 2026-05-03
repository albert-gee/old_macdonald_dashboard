import 'dart:async';

import 'package:dashboard/src/features/thread/presentation/blocs/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_address/thread_address_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_interface_status/thread_interface_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_role/thread_role_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_stack_status/thread_stack_status_bloc.dart';
import 'package:dashboard/src/features/orchestrator/data/repositories/i_orchestrator_url_storage.dart';
import 'package:dashboard/src/features/orchestrator/presentation/blocs/websocket_connection_bloc.dart';
import 'package:dashboard/src/core/websocket/i_websocket_client.dart';
import 'package:dashboard/src/core/websocket/websocket_inbound_message_handler.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWebSocketClient implements IWebSocketClient {
  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  @override
  bool isConnecting = false;

  @override
  bool isConnected = false;

  String? lastConnectUrl;
  String? lastRootCAAsset;
  int connectCallCount = 0;
  int disconnectCallCount = 0;
  bool connectResult = true;

  @override
  Stream<String> get messages => _messages.stream;

  @override
  Future<bool> connect({
    required String url,
    String? rootCAAsset,
    bool enableCompression = true,
    Duration pingInterval = const Duration(seconds: 10),
  }) async {
    connectCallCount++;
    lastConnectUrl = url;
    lastRootCAAsset = rootCAAsset;
    isConnected = connectResult;
    return connectResult;
  }

  @override
  Future<bool> sendMessage(String message) async => isConnected;

  @override
  Future<void> disconnect({
    int code = 1000,
    String reason = 'Client disconnect',
  }) async {
    disconnectCallCount++;
    isConnected = false;
  }

  @override
  StreamSubscription<String> listen({
    required void Function(String message) onMessage,
    required void Function() onDone,
    required void Function(Object error) onError,
  }) {
    return _messages.stream.listen(
      onMessage,
      onDone: onDone,
      onError: onError,
      cancelOnError: true,
    );
  }

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  Future<void> close() => _messages.close();
}

class FakeUrlStorage implements IOrchestratorUrlStorage {
  String? savedUrl;
  int saveCallCount = 0;
  int clearCallCount = 0;

  @override
  Future<String?> readUrl() async => savedUrl;

  @override
  Future<void> saveUrl(String url) async {
    saveCallCount++;
    savedUrl = url;
  }

  @override
  Future<void> clearUrl() async {
    clearCallCount++;
    savedUrl = null;
  }
}

void main() {
  const rootCaAssetPath = 'assets/rootCA.pem';

  late FakeWebSocketClient client;
  late FakeUrlStorage urlStorage;
  late _HandlerFixture handlerFixture;
  late WebsocketConnectionBloc bloc;

  setUp(() {
    client = FakeWebSocketClient();
    urlStorage = FakeUrlStorage();
    handlerFixture = _HandlerFixture();
    bloc = WebsocketConnectionBloc(
      websocket: client,
      messageHandler: handlerFixture.handler,
      urlStorage: urlStorage,
      rootCaAssetPath: rootCaAssetPath,
    );
  });

  tearDown(() async {
    await bloc.close();
    await handlerFixture.close();
    await client.close();
  });

  test('invalid URL emits error and does not call connect', () async {
    final errorFuture = _waitForState<WebsocketConnectionErrorState>(bloc);

    bloc.add(const WebsocketConnectionConnectRequested('http://example.com'));

    final state = await errorFuture;
    expect(state.message, 'Enter a valid ws:// or wss:// URL.');
    expect(client.connectCallCount, 0);
  });

  test('ws URL connect calls rootCAAsset null', () async {
    final connectedFuture =
        _waitForState<WebsocketConnectionConnectedState>(bloc);

    bloc.add(const WebsocketConnectionConnectRequested('ws://192.168.4.1/ws'));

    await connectedFuture;
    expect(client.lastConnectUrl, 'ws://192.168.4.1/ws');
    expect(client.lastRootCAAsset, isNull);
  });

  test('wss URL connect calls configured root CA asset', () async {
    final connectedFuture =
        _waitForState<WebsocketConnectionConnectedState>(bloc);

    bloc.add(const WebsocketConnectionConnectRequested('wss://192.168.4.1/ws'));

    await connectedFuture;
    expect(client.lastConnectUrl, 'wss://192.168.4.1/ws');
    expect(client.lastRootCAAsset, rootCaAssetPath);
  });

  test('successful connect saves URL to storage', () async {
    final connectedFuture =
        _waitForState<WebsocketConnectionConnectedState>(bloc);

    bloc.add(const WebsocketConnectionConnectRequested('ws://192.168.4.1/ws'));

    await connectedFuture;
    expect(urlStorage.saveCallCount, 1);
    expect(urlStorage.savedUrl, 'ws://192.168.4.1/ws');
  });

  test('disconnect calls websocket.disconnect', () async {
    final disconnectedFuture =
        _waitForState<WebsocketConnectionDisconnectedState>(bloc);

    bloc.add(const WebsocketConnectionDisconnectRequested());

    await disconnectedFuture;
    expect(client.disconnectCallCount, 1);
  });
}

Future<T> _waitForState<T extends WebsocketConnectionState>(
  WebsocketConnectionBloc bloc,
) async {
  final completer = Completer<T>();
  late final StreamSubscription<WebsocketConnectionState> subscription;

  subscription = bloc.stream.listen((state) {
    if (state is T && !completer.isCompleted) {
      completer.complete(state);
    }
  });

  try {
    return await completer.future.timeout(const Duration(seconds: 1));
  } finally {
    await subscription.cancel();
  }
}

class _HandlerFixture {
  final ThreadStackStatusBloc threadStackStatusBloc = ThreadStackStatusBloc();
  final ThreadInterfaceStatusBloc threadInterfaceStatusBloc =
      ThreadInterfaceStatusBloc();
  final ThreadAttachmentStatusBloc threadAttachmentStatusBloc =
      ThreadAttachmentStatusBloc();
  final ThreadRoleBloc threadRoleBloc = ThreadRoleBloc();
  final ThreadActiveDatasetBloc threadActiveDatasetBloc =
      ThreadActiveDatasetBloc();
  final ThreadAddressBloc threadAddressBloc = ThreadAddressBloc();
  final ThreadMeshcopServiceStatusBloc threadMeshcopServiceStatusBloc =
      ThreadMeshcopServiceStatusBloc();

  late final WebSocketInboundMessageHandler handler =
      WebSocketInboundMessageHandler(
    threadStackStatusBloc: threadStackStatusBloc,
    threadInterfaceStatusBloc: threadInterfaceStatusBloc,
    threadAttachmentStatusBloc: threadAttachmentStatusBloc,
    threadRoleBloc: threadRoleBloc,
    threadActiveDatasetBloc: threadActiveDatasetBloc,
    threadAddressBloc: threadAddressBloc,
    threadMeshcopServiceStatusBloc: threadMeshcopServiceStatusBloc,
  );

  Future<void> close() async {
    await threadStackStatusBloc.close();
    await threadInterfaceStatusBloc.close();
    await threadAttachmentStatusBloc.close();
    await threadRoleBloc.close();
    await threadActiveDatasetBloc.close();
    await threadAddressBloc.close();
    await threadMeshcopServiceStatusBloc.close();
  }
}
