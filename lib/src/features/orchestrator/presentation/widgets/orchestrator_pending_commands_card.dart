import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';

class OrchestratorPendingCommandsCard extends ConsumerWidget {
  final bool showContainer;

  const OrchestratorPendingCommandsCard({
    super.key,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref
        .watch(orchestratorRuntimeControllerProvider)
        .pendingCommands
        .values;
    final content = pending.isEmpty
        ? const Text('No pending commands.')
        : Column(
            children: [
              for (final command in pending)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(command.action),
                  subtitle: Text(command.requestId),
                  trailing: Text(
                    '${DateTime.now().difference(command.createdAt).inSeconds}s',
                  ),
                ),
            ],
          );
    if (!showContainer) return content;
    return AppPanel(
      title: 'Pending Commands',
      tone: AppPanelTone.neutral,
      child: content,
    );
  }
}
