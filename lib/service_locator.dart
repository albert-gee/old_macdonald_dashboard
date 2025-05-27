import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_inbound_message_handler.dart';
import 'package:dashboard/services/i_matter_command_service.dart';
import 'package:dashboard/services/matter_command_service.dart';
import 'package:dashboard/services/i_wifi_command_service.dart';
import 'package:dashboard/services/wifi_command_service.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:dashboard/services/thread_command_service.dart';

import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Configures and registers all app-wide dependencies
Future<void> setupServiceLocator() async {
  // Core WebSocket services
  getIt.registerLazySingleton<WebSocketClient>(() => WebSocketClient());
  getIt.registerLazySingleton<WebSocketInboundMessageHandler>(() => WebSocketInboundMessageHandler());

  // Domain services
  getIt.registerLazySingleton<IThreadCommandService>(
        () => ThreadCommandService(websocket: getIt<WebSocketClient>()),
  );

  getIt.registerLazySingleton<IWifiCommandService>(
        () => WifiCommandService(websocket: getIt<WebSocketClient>()),
  );

  getIt.registerLazySingleton<IMatterCommandService>(
        () => MatterCommandService(websocket: getIt<WebSocketClient>()),
  );

}
