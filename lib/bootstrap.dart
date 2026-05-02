import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'dashboard_app.dart';
import 'service_locator.dart';
import 'src/core/config/app_config.dart';

final Logger _logger = Logger();

Future<void> bootstrap(AppConfig config) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupServiceLocator();

    runApp(DashboardApp(config: config));
  }, (error, stackTrace) {
    _logger.e(
      'Unhandled error in bootstrap()',
      error: error,
      stackTrace: stackTrace,
    );
  });
}
