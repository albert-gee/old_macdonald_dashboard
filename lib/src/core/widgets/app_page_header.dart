import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';

class AppPageHeader extends StatelessWidget {
  final String title;

  const AppPageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
      child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}
