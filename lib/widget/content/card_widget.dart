import 'package:flutter/material.dart';
import 'package:dashboard/styles/app_colors.dart';
import 'package:dashboard/styles/app_dimensions.dart';
import 'package:dashboard/styles/app_shadows.dart';

/// A reusable container for displaying titled sections of content.
///
/// Used as a visual block in dashboard-style UIs.
/// Includes consistent padding, background, border radius, and shadow styling.
class CardWidget extends StatelessWidget {
  /// The title displayed at the top of the card.
  final String title;

  /// The child widget rendered below the title.
  final Widget child;

  const CardWidget({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // User-defined card content
          child,
        ],
      ),
    );
  }
}
