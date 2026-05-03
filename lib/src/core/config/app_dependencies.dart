import 'package:dashboard/src/features/matter/data/repositories/i_matter_command_service.dart';
import 'package:dashboard/src/features/matter/data/repositories/matter_command_service.dart';
import 'package:dashboard/src/features/orchestrator/data/datasources/orchestrator_url_storage.dart';
import 'package:dashboard/src/features/orchestrator/data/repositories/i_orchestrator_url_storage.dart';
import 'package:dashboard/src/features/thread/data/repositories/i_thread_command_service.dart';
import 'package:dashboard/src/features/thread/data/repositories/thread_command_service.dart';
import 'package:dashboard/src/features/wifi/data/repositories/i_wifi_command_service.dart';
import 'package:dashboard/src/features/wifi/data/repositories/wifi_command_service.dart';
import 'package:dashboard/websocket/websocket_client.dart';

class AppDependencies {
  final WebSocketClient webSocketClient;
  final IOrchestratorUrlStorage orchestratorUrlStorage;
  final IThreadCommandService threadCommandService;
  final IWifiCommandService wifiCommandService;
  final IMatterCommandService matterCommandService;

  AppDependencies._({
    required this.webSocketClient,
    required this.orchestratorUrlStorage,
    required this.threadCommandService,
    required this.wifiCommandService,
    required this.matterCommandService,
  });

  factory AppDependencies.create() {
    final webSocketClient = WebSocketClient();

    return AppDependencies._(
      webSocketClient: webSocketClient,
      orchestratorUrlStorage: OrchestratorUrlStorage(),
      threadCommandService: ThreadCommandService(websocket: webSocketClient),
      wifiCommandService: WifiCommandService(websocket: webSocketClient),
      matterCommandService: MatterCommandService(websocket: webSocketClient),
    );
  }
}
