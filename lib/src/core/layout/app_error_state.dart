import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String explanation;
  final String? details;
  final Widget? retryAction;

  const AppErrorState({
    super.key,
    required this.title,
    required this.explanation,
    this.details,
    this.retryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppDimensions.spacingS),
          Text(explanation, style: AppTextStyles.mutedBody),
          if (details != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Technical details'),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(details!, style: AppTextStyles.mutedBody),
                ),
              ],
            ),
          ],
          if (retryAction != null) ...[
            const SizedBox(height: AppDimensions.spacingL),
            retryAction!,
          ],
        ],
      ),
    );
  }
}
