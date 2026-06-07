import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/features/chamber/presentation/screens/chamber_screen.dart';
import 'package:dashboard/src/features/developer/presentation/screens/developer_screen.dart';
import 'package:dashboard/src/features/devices/presentation/screens/devices_screen.dart';
import 'package:dashboard/src/features/diagnostics/presentation/screens/diagnostics_screen.dart';
import 'package:dashboard/src/features/overview/domain/operator_runtime.dart';
import 'package:dashboard/src/features/overview/presentation/screens/overview_screen.dart';
import 'package:dashboard/src/features/setup/presentation/screens/setup_screen.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static final List<DashboardDestination> destinations = [
    DashboardDestination(
      key: DashboardDestinationKey.overview,
      title: 'Overview',
      icon: Icons.dashboard_outlined,
      builder: (_) => const OverviewScreen(),
    ),
    DashboardDestination(
      key: DashboardDestinationKey.setup,
      title: 'Setup',
      icon: Icons.route_outlined,
      builder: (_) => const SetupScreen(),
    ),
    DashboardDestination(
      key: DashboardDestinationKey.devices,
      title: 'Devices',
      icon: Icons.sensors,
      builder: (_) => const DevicesScreen(),
    ),
    DashboardDestination(
      key: DashboardDestinationKey.chamber,
      title: 'Chamber',
      icon: Icons.eco_outlined,
      builder: (_) => const ChamberScreen(),
    ),
    DashboardDestination(
      key: DashboardDestinationKey.diagnostics,
      title: 'Diagnostics',
      icon: Icons.troubleshoot_outlined,
      builder: (_) => const DiagnosticsScreen(),
    ),
    DashboardDestination(
      key: DashboardDestinationKey.developer,
      title: 'Developer Tools',
      icon: Icons.terminal,
      builder: (_) => const DeveloperScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDashboardDestinationProvider);
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final config = ref.watch(appConfigProvider);
    final runtime = ref.watch(operatorRuntimeProvider);
    final destination = destinations.firstWhere(
      (item) => item.key == selected,
      orElse: () => destinations.first,
    );

    Widget shellBody() {
      return Row(
        children: [
          _NavigationPane(
            title: config.appTitle,
            subtitle: config.appSubtitle,
            collapsed: collapsed,
            selected: selected,
            onToggle: () =>
                ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
            onSelect: (key) => selectDashboardDestination(ref, key),
          ),
          Expanded(
            child: Column(
              children: [
                _OperatorTopBar(runtime: runtime),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingPage),
                    child: destination.builder(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360 || constraints.maxHeight < 360) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: SizedBox(width: 900, height: 720, child: shellBody()),
              ),
            );
          }
          return shellBody();
        },
      ),
    );
  }
}

class _OperatorTopBar extends ConsumerWidget {
  final OperatorRuntime runtime;

  const _OperatorTopBar({required this.runtime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = runtime.connection;
    final connected = runtime.connected;
    final controller = ref.read(
      orchestratorConnectionControllerProvider.notifier,
    );
    final error = runtime.globalError;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final superCompact = constraints.maxWidth < 560;
        return Container(
          height: compact ? 72 : 84,
          padding: EdgeInsets.symmetric(
            horizontal: compact
                ? AppDimensions.spacingM
                : AppDimensions.spacingL,
            vertical: AppDimensions.spacingS,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: superCompact
                  ? const BoxConstraints()
                  : BoxConstraints.tightFor(width: constraints.maxWidth),
              child: Row(
                mainAxisSize: superCompact
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                children: [
                  const Icon(
                    Icons.agriculture_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  if (!superCompact) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 112 : 220,
                      ),
                      child: compact
                          ? const Text(
                              'Old Macdonald',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.sectionTitle,
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Old Macdonald',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle,
                                ),
                                SizedBox(height: AppDimensions.spacingXS),
                                Text(
                                  'Operator Dashboard',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mutedBody,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                  ],
                  if (compact)
                    Tooltip(
                      message: 'Connection: ${connection.status.name}',
                      child: Icon(
                        connected ? Icons.link : Icons.link_off,
                        color: connected
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    )
                  else
                    _StatusPill(
                      label: connection.status.name,
                      tone: connected ? AppColors.success : AppColors.warning,
                      icon: connected ? Icons.link : Icons.link_off,
                    ),
                  const SizedBox(width: AppDimensions.spacingM),
                  if (!compact)
                    Expanded(
                      child: Tooltip(
                        message: runtime.endpoint,
                        child: Text(
                          runtime.endpoint,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mutedBody,
                        ),
                      ),
                    )
                  else if (!superCompact)
                    const Spacer(),
                  if (!compact) ...[
                    _TinyStatus(
                      label: 'Snapshot',
                      value: ageLabel(runtime.lastSnapshotAt),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                  ],
                  if (error != null)
                    Tooltip(
                      message: error,
                      child: const Icon(
                        Icons.error_outline,
                        color: AppColors.warning,
                      ),
                    )
                  else
                    const Tooltip(
                      message: 'No global errors recorded.',
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                  const SizedBox(width: AppDimensions.spacingS),
                  IconButton(
                    tooltip: 'Edit Orchestrator URL',
                    onPressed: () => _editUrl(context, ref),
                    icon: const Icon(Icons.edit_location_alt_outlined),
                  ),
                  if (!connected && connection.trustedFingerprint == null)
                    compact
                        ? IconButton(
                            tooltip: connection.observedFingerprint == null
                                ? 'Trust certificate'
                                : 'Save trust',
                            onPressed: connection.loading
                                ? null
                                : connection.observedFingerprint == null
                                ? () => controller.pairAndCapture()
                                : controller.trustObservedFingerprint,
                            icon: const Icon(Icons.verified_user_outlined),
                          )
                        : OutlinedButton.icon(
                            onPressed: connection.loading
                                ? null
                                : connection.observedFingerprint == null
                                ? () => controller.pairAndCapture()
                                : controller.trustObservedFingerprint,
                            icon: const Icon(Icons.verified_user_outlined),
                            label: Text(
                              connection.observedFingerprint == null
                                  ? 'Trust certificate'
                                  : 'Save trust',
                            ),
                          ),
                  const SizedBox(width: AppDimensions.spacingS),
                  FilledButton.icon(
                    onPressed: connection.loading
                        ? null
                        : connected
                        ? controller.disconnect
                        : controller.connect,
                    icon: Icon(
                      connected ? Icons.logout : Icons.power_settings_new,
                    ),
                    label: Text(connected ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editUrl(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: runtime.endpoint);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Orchestrator endpoint'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'WSS URL',
            hintText: 'wss://192.168.4.1/ws',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;
    ref
        .read(orchestratorConnectionControllerProvider.notifier)
        .updateUrl(result);
  }
}

class _NavigationPane extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool collapsed;
  final DashboardDestinationKey selected;
  final VoidCallback onToggle;
  final ValueChanged<DashboardDestinationKey> onSelect;

  const _NavigationPane({
    required this.title,
    required this.subtitle,
    required this.collapsed,
    required this.selected,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: collapsed
          ? AppDimensions.sidebarCollapsedWidth
          : AppDimensions.sidebarExpandedWidth,
      color: AppColors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight < 360) {
            return SingleChildScrollView(child: _NavigationContent(this));
          }
          return Column(
            children: [
              _NavigationHeader(
                title: title,
                subtitle: subtitle,
                collapsed: collapsed,
                onToggle: onToggle,
              ),
              const Divider(height: 1),
              Expanded(child: _DestinationList(parent: this)),
            ],
          );
        },
      ),
    );
  }
}

class _NavigationContent extends StatelessWidget {
  final _NavigationPane parent;

  const _NavigationContent(this.parent);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavigationHeader(
          title: parent.title,
          subtitle: parent.subtitle,
          collapsed: parent.collapsed,
          onToggle: parent.onToggle,
        ),
        const Divider(height: 1),
        _DestinationList(parent: parent, shrinkWrap: true),
      ],
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool collapsed;
  final VoidCallback onToggle;

  const _NavigationHeader({
    required this.title,
    required this.subtitle,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingL,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
      ),
      child: Row(
        children: [
          if (!collapsed)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sidebarTitle,
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sidebarSubtitle,
                  ),
                ],
              ),
            ),
          IconButton(
            tooltip: collapsed ? 'Expand navigation' : 'Collapse navigation',
            onPressed: onToggle,
            icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left),
          ),
        ],
      ),
    );
  }
}

class _DestinationList extends StatelessWidget {
  final _NavigationPane parent;
  final bool shrinkWrap;

  const _DestinationList({required this.parent, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      children: [
        for (final destination in DashboardShell.destinations)
          _DestinationTile(
            destination: destination,
            collapsed: parent.collapsed,
            selected: destination.key == parent.selected,
            onTap: () => parent.onSelect(destination.key),
          ),
      ],
    );
  }
}

class _DestinationTile extends StatelessWidget {
  final DashboardDestination destination;
  final bool collapsed;
  final bool selected;
  final VoidCallback onTap;

  const _DestinationTile({
    required this.destination,
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textPrimary;
    return ListTile(
      selected: selected,
      leading: Icon(destination.icon, color: color),
      title: collapsed
          ? null
          : Text(destination.title, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color tone;
  final IconData icon;

  const _StatusPill({
    required this.label,
    required this.tone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: AppDimensions.spacingS),
          Text(label, style: AppTextStyles.label.copyWith(color: tone)),
        ],
      ),
    );
  }
}

class _TinyStatus extends StatelessWidget {
  final String label;
  final String value;

  const _TinyStatus({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(value, style: AppTextStyles.mutedBody),
      ],
    );
  }
}
