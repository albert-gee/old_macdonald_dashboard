import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String explanation;
  final String? recommendedAction;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.explanation,
    this.recommendedAction,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 28),
          const SizedBox(width: AppDimensions.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppDimensions.spacingS),
                Text(explanation, style: AppTextStyles.mutedBody),
                if (recommendedAction != null) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(recommendedAction!, style: AppTextStyles.bodyMedium),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppDimensions.spacingL),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
