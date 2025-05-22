import 'package:flutter/material.dart';

class ThreadPage extends StatelessWidget {
  const ThreadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two-column layout for Thread widgets
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   flex: 1,
            //   child: ThreadDatasetInitFormWidget(),
            // ),
            // const SizedBox(width: 20.0),
            // Expanded(
            //   flex: 1,
            //   child: ThreadDatasetActiveWidget(),
            // ),
          ],
        ),
        const SizedBox(height: 50.0),
      ],
    );
  }
}
