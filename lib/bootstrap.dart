import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'src/app/dashboard_app.dart';
import 'src/core/config/app_dependencies.dart';
import 'src/core/config/app_config.dart';

final Logger _logger = Logger();

Future<void> bootstrap(AppConfig config) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dependencies = AppDependencies.create();

    runApp(
      DashboardApp(
        config: config,
        dependencies: dependencies,
      ),
    );
  }, (error, stackTrace) {
    _logger.e(
      'Unhandled error in bootstrap()',
      error: error,
      stackTrace: stackTrace,
    );
  });
}
