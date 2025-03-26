import 'package:flutter/material.dart';
import 'dashboard_app.dart';
import 'service_locator.dart';

Future<void> main() async {

  // Setup dependency injection
  await setupServiceLocator("ws://192.168.50.83:80/ws", 'secret_token_123');

  // Run the app
  runApp(DashboardApp());
}