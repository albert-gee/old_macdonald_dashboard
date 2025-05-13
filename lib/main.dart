import 'package:flutter/material.dart';
import 'dashboard_app.dart';
import 'service_locator.dart';

const String title = 'Old MacDonald';
const String subTitle = 'Controlled Environment';
const String wsUri = 'ws://192.168.4.1:80/ws';

Future<void> main() async {
  // Setup dependency injection for services
  await setupServiceLocator(wsUri);

  // Run the app
  runApp(DashboardApp(
    title: title,
    subTitle: subTitle,
  ));
}
