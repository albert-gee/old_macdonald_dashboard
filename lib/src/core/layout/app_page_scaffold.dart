import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';

class AppPageScaffold extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? banner;
  final List<Widget> children;

  const AppPageScaffold({
    super.key,
    this.title,
    this.description,
    this.banner,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.pageGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: AppTextStyles.pageTitle),
                  if (description != null) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(description!, style: AppTextStyles.pageSubtitle),
                  ],
                  const SizedBox(height: AppDimensions.sectionGap),
                ],
                if (banner != null) ...[
                  banner!,
                  const SizedBox(height: AppDimensions.spacingL),
                ],
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index != children.length - 1)
                    const SizedBox(height: AppDimensions.sectionGap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
