import 'package:get_it/get_it.dart';

import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_message_parser.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:dashboard/services/thread_command_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<WebSocketClient>(
          () => WebSocketClient());

  getIt.registerLazySingleton<WebSocketMessageParser>(
      () => WebSocketMessageParser());

  getIt.registerLazySingleton<IThreadCommandService>(
    () => ThreadCommandService(websocket: getIt<WebSocketClient>()),
  );
}
