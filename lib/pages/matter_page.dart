import 'package:dashboard/widget/content/page_header.dart';
import 'package:flutter/material.dart';

class MatterPage extends StatelessWidget {
  final String title;

  const MatterPage({
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

          // PairBleThreadWidget
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded(
              //   flex: 1,
              //   child: PairBleThreadWidget(),
              // ),
              // const SizedBox(width: 20.0),
              // Expanded(
              //   flex: 1,
              //   child: ClusterCommandWidget(),
              // ),
            ],
          ),
          const SizedBox(height: 20.0),

          // ReadAttributeCommandWidget
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Expanded(
          //       flex: 1,
          //       child: ReadAttributeCommandWidget(),
          //     ),
          //     const SizedBox(width: 20.0),
          //     Expanded(
          //       flex: 1,
          //       child: SubscribeAttributeCommandWidget(),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
