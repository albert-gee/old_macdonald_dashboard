import 'package:get_it/get_it.dart';

import 'package:dashboard/network/websocket.dart';
import 'package:dashboard/models/websocket_message.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:dashboard/services/thread_command_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator(String wsUri) async {
  // Register WebSocket and message parser
  getIt.registerLazySingleton<Websocket>(() => Websocket(wsUri));
  getIt.registerSingleton<WebSocketMessageParser>(WebSocketMessageParser());

  // Register services
  getIt.registerLazySingleton<IThreadCommandService>(
        () => ThreadCommandService(websocket: getIt<Websocket>()),
  );
}
