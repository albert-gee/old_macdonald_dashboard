import 'package:get_it/get_it.dart';

import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_message_parser.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:dashboard/services/thread_command_service.dart';

final GetIt getIt = GetIt.instance;

/// Configures and registers all app-wide dependencies
Future<void> setupServiceLocator() async {
  // Core WebSocket services
  getIt.registerLazySingleton<WebSocketClient>(() => WebSocketClient());
  getIt.registerLazySingleton<WebSocketMessageParser>(() => WebSocketMessageParser());

  // Domain services
  getIt.registerLazySingleton<IThreadCommandService>(
        () => ThreadCommandService(websocket: getIt<WebSocketClient>()),
  );
}
