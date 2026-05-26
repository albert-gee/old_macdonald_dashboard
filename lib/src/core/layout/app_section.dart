import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

class AppSection extends StatelessWidget {
  final String? title;
  final String? description;
  final List<Widget> children;

  const AppSection({
    super.key,
    this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTextStyles.sectionTitle),
          if (description != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(description!, style: AppTextStyles.pageSubtitle),
          ],
          const SizedBox(height: AppDimensions.spacingL),
        ],
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1)
            const SizedBox(height: AppDimensions.spacingL),
        ],
      ],
    );
  }
}
