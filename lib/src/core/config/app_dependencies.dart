import 'package:dashboard/services/i_matter_command_service.dart';
import 'package:dashboard/services/i_orchestrator_url_storage.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:dashboard/services/i_wifi_command_service.dart';
import 'package:dashboard/services/matter_command_service.dart';
import 'package:dashboard/services/orchestrator_url_storage.dart';
import 'package:dashboard/services/thread_command_service.dart';
import 'package:dashboard/services/wifi_command_service.dart';
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
