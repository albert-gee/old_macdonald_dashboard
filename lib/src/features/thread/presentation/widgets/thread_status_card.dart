import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/core/widgets/app_status_card.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_status.dart';

class ThreadStatusCard extends StatelessWidget {
  final ThreadStatus status;

  const ThreadStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final roleActive =
        status.role.isNotEmpty && status.role.toLowerCase() != 'unknown';
    return AppCard(
      title: 'Thread Status',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          AppStatusCard(
            title: 'Stack',
            value: status.stackRunning ? 'Running' : 'Stopped',
            active: status.stackRunning,
          ),
          AppStatusCard(
            title: 'Interface',
            value: status.interfaceUp ? 'Up' : 'Down',
            active: status.interfaceUp,
          ),
          AppStatusCard(
            title: 'Attachment',
            value: status.attached ? 'Attached' : 'Detached',
            active: status.attached,
          ),
          AppStatusCard(
            title: 'Role',
            value: roleActive ? status.role : 'Unknown',
            active: roleActive,
          ),
          AppStatusCard(
            title: 'MeshCoP service',
            value: status.meshcopPublished ? 'Published' : 'Not published',
            active: status.meshcopPublished,
          ),
        ],
      ),
    );
  }
}
