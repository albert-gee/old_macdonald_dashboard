import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/security/certificate_trust_store.dart';
import 'package:dashboard/src/core/storage/preferences_store.dart';
import 'package:dashboard/src/core/storage/shared_preferences_store.dart';
import 'package:dashboard/src/core/websocket/websocket_client.dart';
import 'package:dashboard/src/features/chamber/data/repositories/chamber_repository_impl.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_controller.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';
import 'package:dashboard/src/features/devices/data/repositories/device_repository_impl.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/devices/presentation/controllers/device_list_controller.dart';
import 'package:dashboard/src/features/devices/presentation/controllers/device_list_state.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_cluster_repository.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_command_repository.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_cluster_controller.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_cluster_state.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_command_controller.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_command_state.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_controller.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_state.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_url_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/services/orchestrator_request_id_generator.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_connection_controller.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_connection_state.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_controller.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_command_controller.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_command_state.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_dataset_init_controller.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_dataset_init_state.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_status_controller.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_status_state.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_status.dart';
import 'package:dashboard/src/features/wifi/domain/repositories/wifi_command_repository.dart';
import 'package:dashboard/src/features/wifi/presentation/controllers/wifi_sta_connect_controller.dart';
import 'package:dashboard/src/features/wifi/presentation/controllers/wifi_sta_connect_state.dart';
import 'package:dashboard/src/features/wifi/presentation/controllers/wifi_sta_status_controller.dart';

import '../features/matter/data/datasources/matter_cluster_asset_data_source.dart';
import '../features/matter/data/repositories/matter_cluster_repository_impl.dart';
import '../features/matter/data/repositories/matter_command_repository_impl.dart';
import '../features/orchestrator/data/repositories/orchestrator_command_client_impl.dart';
import '../features/orchestrator/data/repositories/orchestrator_connection_repository_impl.dart';
import '../features/orchestrator/data/repositories/orchestrator_message_repository_impl.dart';
import '../features/orchestrator/data/repositories/orchestrator_url_repository_impl.dart';
import '../features/thread/data/repositories/thread_command_repository_impl.dart';
import '../features/wifi/data/repositories/wifi_command_repository_impl.dart';

final appConfigProvider = Provider<AppConfig>((ref) => const AppConfig.local());

final loggerProvider = Provider<Logger>((ref) => Logger());

final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => SharedPreferencesStore(),
);

final certificateTrustStoreProvider = Provider<CertificateTrustStore>(
  (ref) => CertificateTrustStore(store: ref.watch(preferencesStoreProvider)),
);

final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = IoWebSocketClient(logger: ref.watch(loggerProvider));
  ref.onDispose(client.dispose);
  return client;
});

final orchestratorUrlRepositoryProvider = Provider<OrchestratorUrlRepository>((
  ref,
) {
  return OrchestratorUrlRepositoryImpl(
    store: ref.watch(preferencesStoreProvider),
  );
});

final orchestratorConnectionRepositoryProvider =
    Provider<OrchestratorConnectionRepository>((ref) {
      return OrchestratorConnectionRepositoryImpl(
        webSocketClient: ref.watch(webSocketClientProvider),
      );
    });

final orchestratorMessageRepositoryProvider =
    Provider<OrchestratorMessageRepository>((ref) {
      return OrchestratorMessageRepositoryImpl(
        webSocketClient: ref.watch(webSocketClientProvider),
      );
    });

final orchestratorRequestIdGeneratorProvider =
    Provider<OrchestratorRequestIdGenerator>(
      (ref) => TimestampOrchestratorRequestIdGenerator(),
    );

final orchestratorCommandClientProvider = Provider<OrchestratorCommandClient>((
  ref,
) {
  final client = OrchestratorCommandClientImpl(
    connectionRepository: ref.watch(orchestratorConnectionRepositoryProvider),
    messageRepository: ref.watch(orchestratorMessageRepositoryProvider),
    requestIdGenerator: ref.watch(orchestratorRequestIdGeneratorProvider),
    logger: ref.watch(loggerProvider),
  );
  ref.onDispose(client.dispose);
  return client;
});

final orchestratorConnectionControllerProvider =
    StateNotifierProvider<
      OrchestratorConnectionController,
      OrchestratorConnectionState
    >((ref) {
      return OrchestratorConnectionController(
        config: ref.watch(appConfigProvider),
        urlRepository: ref.watch(orchestratorUrlRepositoryProvider),
        trustStore: ref.watch(certificateTrustStoreProvider),
        connectionRepository: ref.watch(
          orchestratorConnectionRepositoryProvider,
        ),
      );
    });

final orchestratorMessageStreamProvider = StreamProvider<OrchestratorMessage>((
  ref,
) {
  return ref.watch(orchestratorMessageRepositoryProvider).watchMessages();
});

final orchestratorRuntimeControllerProvider =
    StateNotifierProvider<
      OrchestratorRuntimeController,
      OrchestratorRuntimeState
    >((ref) {
      return OrchestratorRuntimeController(
        messages: ref
            .watch(orchestratorMessageRepositoryProvider)
            .watchMessages(),
        commandClient: ref.watch(orchestratorCommandClientProvider),
      );
    });

final wifiCommandRepositoryProvider = Provider<WifiCommandRepository>((ref) {
  return WifiCommandRepositoryImpl(
    client: ref.watch(orchestratorCommandClientProvider),
  );
});

final wifiStaConnectControllerProvider =
    StateNotifierProvider<WifiStaConnectController, WifiStaConnectState>((ref) {
      return WifiStaConnectController(
        repository: ref.watch(wifiCommandRepositoryProvider),
      );
    });

final wifiStaStatusControllerProvider =
    StateNotifierProvider<WifiStaStatusController, WifiStaStatus>((ref) {
      return WifiStaStatusController(
        messages: ref
            .watch(orchestratorMessageRepositoryProvider)
            .watchMessages(),
      );
    });

final threadCommandRepositoryProvider = Provider<ThreadCommandRepository>((
  ref,
) {
  return ThreadCommandRepositoryImpl(
    client: ref.watch(orchestratorCommandClientProvider),
  );
});

final threadCommandControllerProvider =
    StateNotifierProvider<ThreadCommandController, ThreadCommandState>((ref) {
      return ThreadCommandController(
        repository: ref.watch(threadCommandRepositoryProvider),
      );
    });

final threadDatasetInitControllerProvider =
    StateNotifierProvider<ThreadDatasetInitController, ThreadDatasetInitState>((
      ref,
    ) {
      return ThreadDatasetInitController(
        repository: ref.watch(threadCommandRepositoryProvider),
      );
    });

final threadStatusControllerProvider =
    StateNotifierProvider<ThreadStatusController, ThreadStatusState>((ref) {
      return ThreadStatusController(
        messages: ref
            .watch(orchestratorMessageRepositoryProvider)
            .watchMessages(),
      );
    });

final matterCommandRepositoryProvider = Provider<MatterCommandRepository>((
  ref,
) {
  return MatterCommandRepositoryImpl(
    client: ref.watch(orchestratorCommandClientProvider),
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    client: ref.watch(orchestratorCommandClientProvider),
  );
});

final deviceListControllerProvider =
    StateNotifierProvider<DeviceListController, DeviceListState>((ref) {
      return DeviceListController(
        repository: ref.watch(deviceRepositoryProvider),
      );
    });

final chamberRepositoryProvider = Provider<ChamberRepository>((ref) {
  return ChamberRepositoryImpl(
    client: ref.watch(orchestratorCommandClientProvider),
  );
});

final chamberControllerProvider =
    StateNotifierProvider<ChamberController, ChamberState>((ref) {
      return ChamberController(
        repository: ref.watch(chamberRepositoryProvider),
        deviceRepository: ref.watch(deviceRepositoryProvider),
        messages: ref
            .watch(orchestratorMessageRepositoryProvider)
            .watchMessages(),
      );
    });

final matterClusterRepositoryProvider = Provider<MatterClusterRepository>((
  ref,
) {
  return MatterClusterRepositoryImpl(
    dataSource: MatterClusterAssetDataSource(),
  );
});

final matterClusterControllerProvider =
    StateNotifierProvider<MatterClusterController, MatterClusterState>((ref) {
      return MatterClusterController(
        repository: ref.watch(matterClusterRepositoryProvider),
      );
    });

final matterCommandControllerProvider =
    StateNotifierProvider<MatterCommandController, MatterCommandState>((ref) {
      return MatterCommandController(
        repository: ref.watch(matterCommandRepositoryProvider),
      );
    });

final matterEventControllerProvider =
    StateNotifierProvider<MatterEventController, MatterEventState>((ref) {
      return MatterEventController(
        messages: ref
            .watch(orchestratorMessageRepositoryProvider)
            .watchMessages(),
      );
    });

final selectedDashboardDestinationProvider = StateProvider<int>((ref) => 0);

final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
