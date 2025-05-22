import 'package:flutter/material.dart';

class MatterPage extends StatelessWidget {

  const MatterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }
}
