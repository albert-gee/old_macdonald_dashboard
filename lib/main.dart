import 'package:flutter/material.dart';
import 'dashboard_app.dart';
import 'service_locator.dart';

final String title = 'Old MacDonald';
final String subTitle =
    'Controlled Environment Agriculture System';
final String wsUri = 'ws://192.168.4.1:80/ws';
final String token = 'secret_token_123';

Future<void> main() async {

  // Setup dependency injection
  await setupServiceLocator(title, subTitle, wsUri, token);

  // Run the app
  runApp(DashboardApp());
}