import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'src/app/dashboard_app.dart';
import 'src/app/providers.dart';
import 'src/core/config/app_config.dart';

final Logger _logger = Logger();

Future<void> bootstrap(AppConfig config) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    runApp(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
        ],
        child: const DashboardApp(),
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
