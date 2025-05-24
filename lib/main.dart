import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'dashboard_app.dart';
import 'service_locator.dart';

const String _appTitle = 'Old MacDonald';
const String _appSubTitle = 'Controlled Environment';

final Logger _logger = Logger();

/// Application entry point.
void main() {
  // Guarded zone catches unhandled async errors globally
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set up dependency injection
    await setupServiceLocator();

    // Launch the main application
    runApp(DashboardApp(
      title: _appTitle,
      subTitle: _appSubTitle,
    ));
  }, (error, stackTrace) {
    _logger.e('Unhandled error in main()', error: error, stackTrace: stackTrace);
  });
}
