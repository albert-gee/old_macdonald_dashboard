import 'package:dashboard/widget/content/card_widget.dart';
import 'package:flutter/material.dart';

class WifiApPage extends StatelessWidget {
  const WifiApPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardWidget(
          title: 'Wi-Fi AP Controls',
          child: Text(
            'Wi-Fi AP controls are not implemented yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
