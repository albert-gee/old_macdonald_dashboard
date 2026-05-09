import 'package:flutter/material.dart';

import 'package:dashboard/src/core/widgets/app_card.dart';

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: title,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
