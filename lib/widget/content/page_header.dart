import 'package:flutter/material.dart';
import 'package:dashboard/styles/app_dimensions.dart';

/// A standard top-level header widget with vertical spacing.
///
/// Displays a page title using the theme's [headlineLarge] style,
/// and includes top and bottom spacing for layout separation.
class PageHeaderWidget extends StatelessWidget {
  /// The text to display as the page title.
  final String title;

  const PageHeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingL,
      ),
      child: Text(
        title,
        style: textTheme.headlineLarge,
      ),
    );
  }
}
