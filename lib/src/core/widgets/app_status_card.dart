import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';

class AppStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final bool active;

  const AppStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueColor = active ? colorScheme.primary : colorScheme.error;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: valueColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
