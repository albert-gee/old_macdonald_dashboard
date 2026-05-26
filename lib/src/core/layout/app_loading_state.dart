import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

class AppLoadingState extends StatelessWidget {
  final String message;

  const AppLoadingState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Flexible(child: Text(message, style: AppTextStyles.mutedBody)),
      ],
    );
  }
}
