import 'package:dashboard/src/core/widgets/card_widget.dart';
import 'package:flutter/material.dart';

class MatterPage extends StatelessWidget {
  const MatterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardWidget(
          title: 'Matter Controls',
          child: Text(
            'Matter controls are not available in this stabilized build. They will be rebuilt in the Matter feature refactor.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
