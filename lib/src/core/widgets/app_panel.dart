import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

enum AppPanelTone { neutral, info, success, warning, critical }

extension AppPanelToneColor on AppPanelTone {
  Color get color {
    return switch (this) {
      AppPanelTone.neutral => AppColors.neutral,
      AppPanelTone.info => AppColors.info,
      AppPanelTone.success => AppColors.success,
      AppPanelTone.warning => AppColors.warning,
      AppPanelTone.critical => AppColors.critical,
    };
  }
}

class AppPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final AppPanelTone tone;
  final Widget child;
  final Widget? footer;
  final bool fullWidth;
  final bool dense;

  const AppPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.tone = AppPanelTone.neutral,
    required this.child,
    this.footer,
    this.fullWidth = true,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = dense ? AppDimensions.spacingL : AppDimensions.cardPadding;
    final panel = Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: tone.color, size: 22),
                  child: leading!,
                ),
                const SizedBox(width: AppDimensions.spacingM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(subtitle!, style: AppTextStyles.mutedBody),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppDimensions.spacingM),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          child,
          if (footer != null) ...[
            const SizedBox(height: AppDimensions.spacingL),
            Divider(color: AppColors.border),
            const SizedBox(height: AppDimensions.spacingM),
            footer!,
          ],
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: panel) : panel;
  }
}
