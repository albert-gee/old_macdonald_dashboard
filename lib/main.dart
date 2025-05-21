import 'dart:async';

import 'package:flutter/material.dart';

import 'dashboard_app.dart';
import 'service_locator.dart';

const String _appTitle = 'Old MacDonald';
const String _appSubTitle = 'Controlled Environment';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator before app starts
  await setupServiceLocator();

  // Start the app within a guarded zone to catch unhandled errors
  runZonedGuarded(
    () => runApp(
      DashboardApp(
        title: _appTitle,
        subTitle: _appSubTitle,
      ),
    ),
    (error, stackTrace) {
      // TODO: Replace with proper error reporting
      debugPrint('Unhandled error: $error');
    },
  );
}
