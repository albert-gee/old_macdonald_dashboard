import 'package:dashboard/widget/content/card_widget.dart';
import 'package:flutter/material.dart';

class ThreadPage extends StatelessWidget {
  const ThreadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardWidget(
          title: 'Thread Controls',
          child: Text(
            'Thread controls are not available in this stabilized build. They will be rebuilt in the Thread feature refactor.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
