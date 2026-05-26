import 'package:flutter/material.dart';

import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_status.dart';

class ThreadStatusCard extends StatelessWidget {
  final ThreadStatus status;

  const ThreadStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final roleActive =
        status.role.isNotEmpty && status.role.toLowerCase() != 'unknown';
    return AppPanel(
      title: 'Thread status diagnostics',
      child: AppResponsiveGrid(
        children: [
          AppMetricTile(
            label: 'Stack',
            value: status.stackRunning ? 'Running' : 'Stopped',
            tone: status.stackRunning
                ? AppMetricTone.good
                : AppMetricTone.neutral,
          ),
          AppMetricTile(
            label: 'Interface',
            value: status.interfaceUp ? 'Up' : 'Down',
            tone: status.interfaceUp
                ? AppMetricTone.good
                : AppMetricTone.neutral,
          ),
          AppMetricTile(
            label: 'Attachment',
            value: status.attached ? 'Attached' : 'Detached',
            tone: status.attached ? AppMetricTone.good : AppMetricTone.warning,
          ),
          AppMetricTile(
            label: 'Role',
            value: roleActive ? status.role : 'Unknown',
            tone: roleActive ? AppMetricTone.info : AppMetricTone.neutral,
          ),
          AppMetricTile(
            label: 'Dataset service',
            value: status.meshcopPublished ? 'Published' : 'Not published',
            tone: status.meshcopPublished
                ? AppMetricTone.good
                : AppMetricTone.warning,
          ),
        ],
      ),
    );
  }
}
