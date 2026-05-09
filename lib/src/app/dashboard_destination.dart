import 'package:flutter/material.dart';

final class DashboardDestination {
  final String title;
  final IconData icon;
  final WidgetBuilder builder;

  const DashboardDestination({
    required this.title,
    required this.icon,
    required this.builder,
  });
}
