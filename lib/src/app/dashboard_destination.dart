import 'package:flutter/material.dart';

enum DashboardDestinationKey {
  overview,
  setup,
  chamber,
  devices,
  diagnostics,
  developer,
}

final class DashboardDestination {
  final DashboardDestinationKey key;
  final String title;
  final IconData icon;
  final WidgetBuilder builder;

  const DashboardDestination({
    required this.key,
    required this.title,
    required this.icon,
    required this.builder,
  });
}
