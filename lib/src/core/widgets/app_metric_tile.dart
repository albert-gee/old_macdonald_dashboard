import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

enum AppMetricTone { neutral, info, good, warning, critical, pending }

extension AppMetricToneColor on AppMetricTone {
  Color get color {
    return switch (this) {
      AppMetricTone.neutral => AppColors.neutral,
      AppMetricTone.info => AppColors.info,
      AppMetricTone.good => AppColors.success,
      AppMetricTone.warning => AppColors.warning,
      AppMetricTone.critical => AppColors.critical,
      AppMetricTone.pending => AppColors.accent,
    };
  }
}

class AppMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final AppMetricTone tone;
  final IconData? icon;
  final String? detail;
  final String? tooltip;
  final bool compact;

  const AppMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.tone = AppMetricTone.neutral,
    this.icon,
    this.detail,
    this.tooltip,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        compact ? AppDimensions.spacingM : AppDimensions.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: tone.color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: tone.color, size: 18),
                const SizedBox(width: AppDimensions.spacingS),
              ],
              Expanded(child: Text(label, style: AppTextStyles.label)),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: AppTextStyles.metricValue.copyWith(color: tone.color),
          ),
          if (detail != null) ...[
            const SizedBox(height: AppDimensions.spacingXS),
            Text(detail!, style: AppTextStyles.mutedBody),
          ],
        ],
      ),
    );
    return tooltip == null ? tile : Tooltip(message: tooltip!, child: tile);
  }
}
