import 'package:flutter/material.dart';

enum DashboardDestinationKey {
  orchestrator,
  chamber,
  devices,
  wifi,
  thread,
  matter,
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
