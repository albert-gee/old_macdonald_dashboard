import 'dart:async';

import 'package:flutter/material.dart';
import 'dashboard_app.dart';
import 'service_locator.dart';

const String title = 'Old MacDonald';
const String subTitle = 'Controlled Environment';

Future<void> main() async {
  // Setup dependency injection for services
  await setupServiceLocator();

  // Run the app
  runZonedGuarded(() {
    runApp(DashboardApp(title: title, subTitle: subTitle));
  }, (error, stackTrace) {
    // Log to analytics or file
    print('Error: $error');
  });
}
