import 'package:dashboard/widget/content/page_header.dart';
import 'package:flutter/material.dart';

class ThreadPage extends StatelessWidget {
  final String title;

  const ThreadPage({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header with title
          PageHeaderWidget(title: title),
          const SizedBox(height: 20.0),


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
      ),
    );
  }
}
