import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

enum AppStatusTone { neutral, info, success, warning, critical, pending }

extension AppStatusToneColor on AppStatusTone {
  Color get color {
    return switch (this) {
      AppStatusTone.neutral => AppColors.neutral,
      AppStatusTone.info => AppColors.info,
      AppStatusTone.success => AppColors.success,
      AppStatusTone.warning => AppColors.warning,
      AppStatusTone.critical => AppColors.critical,
      AppStatusTone.pending => AppColors.accent,
    };
  }
}

class AppStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final bool active;
  final AppStatusTone? tone;

  const AppStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.active,
    this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor =
        tone?.color ?? (active ? AppColors.success : AppColors.neutral);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: valueColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
