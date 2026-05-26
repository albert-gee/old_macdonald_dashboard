import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';

class AppResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;

  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 220,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final preferredColumns = width >= 1000
            ? 4
            : width >= 720
            ? 3
            : width >= 460
            ? 2
            : 1;
        final maxColumnsForTileWidth = (width / minTileWidth).floor().clamp(
          1,
          4,
        );
        final columns = preferredColumns.clamp(1, maxColumnsForTileWidth);
        final tileWidth =
            (width - (AppDimensions.gridGap * (columns - 1))) / columns;
        return Wrap(
          spacing: AppDimensions.gridGap,
          runSpacing: AppDimensions.gridGap,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }
}

class AppTwoColumnLayout extends StatelessWidget {
  final Widget primary;
  final Widget secondary;

  const AppTwoColumnLayout({
    super.key,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              primary,
              const SizedBox(height: AppDimensions.spacingL),
              secondary,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: primary),
            const SizedBox(width: AppDimensions.spacingL),
            Expanded(child: secondary),
          ],
        );
      },
    );
  }
}
