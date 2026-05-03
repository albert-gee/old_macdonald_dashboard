import 'package:dashboard/src/features/thread/presentation/blocs/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_active_dataset/thread_active_dataset_state.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_address/thread_address_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_command/thread_command_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_command/thread_command_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_command/thread_command_state.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_dataset_form/thread_dataset_form_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_dataset_form/thread_dataset_form_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_dataset_form/thread_dataset_form_state.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_interface_status/thread_interface_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_role/thread_role_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_role/thread_role_state.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_stack_status/thread_stack_status_bloc.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/card_widget.dart';
import 'package:dashboard/src/core/widgets/labeled_text_field.dart';
import 'package:dashboard/src/core/widgets/status_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key});

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  final GlobalKey<FormState> _datasetFormKey = GlobalKey<FormState>();
  final TextEditingController _channelController = TextEditingController();
  final TextEditingController _panIdController = TextEditingController();
  final TextEditingController _networkNameController = TextEditingController();
  final TextEditingController _extendedPanIdController =
      TextEditingController();
  final TextEditingController _meshLocalPrefixController =
      TextEditingController();
  final TextEditingController _networkKeyController = TextEditingController();
  final TextEditingController _pskcController = TextEditingController();

  @override
  void dispose() {
    _channelController.dispose();
    _panIdController.dispose();
    _networkNameController.dispose();
    _extendedPanIdController.dispose();
    _meshLocalPrefixController.dispose();
    _networkKeyController.dispose();
    _pskcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThreadCommandBloc, ThreadCommandState>(
      listener: (context, state) {
        if (state is ThreadCommandSuccess) {
          _showSnackBar(context, state.message);
        } else if (state is ThreadCommandFailure) {
          _showSnackBar(context, state.message);
        }
      },
      builder: (context, commandState) {
        final commandsDisabled = commandState is ThreadCommandInProgress;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context),
              const SizedBox(height: AppDimensions.spacingL),
              _buildActiveDatasetCard(context),
              const SizedBox(height: AppDimensions.spacingL),
              _buildAddressCard(context),
              const SizedBox(height: AppDimensions.spacingL),
              _buildCommandsCard(context, commandsDisabled),
              const SizedBox(height: AppDimensions.spacingL),
              _buildDatasetInitCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final stack = context.watch<ThreadStackStatusBloc>().state;
    final interface = context.watch<ThreadInterfaceStatusBloc>().state;
    final attachment = context.watch<ThreadAttachmentStatusBloc>().state;
    final role = context.watch<ThreadRoleBloc>().state;
    final meshcop = context.watch<ThreadMeshcopServiceStatusBloc>().state;

    return CardWidget(
      title: 'Thread Status',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          _statusTile(
            context,
            title: 'Stack',
            value: stack.isRunning ? 'Running' : 'Stopped',
            active: stack.isRunning,
          ),
          _statusTile(
            context,
            title: 'Interface',
            value: interface.isInterfaceUp ? 'Up' : 'Down',
            active: interface.isInterfaceUp,
          ),
          _statusTile(
            context,
            title: 'Attachment',
            value: attachment.isAttached ? 'Attached' : 'Detached',
            active: attachment.isAttached,
          ),
          _statusTile(
            context,
            title: 'Role',
            value: _displayRole(role),
            active:
                role.role.isNotEmpty && role.role.toLowerCase() != 'unknown',
          ),
          _statusTile(
            context,
            title: 'MeshCoP service',
            value: meshcop.isPublished ? 'Published' : 'Not published',
            active: meshcop.isPublished,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDatasetCard(BuildContext context) {
    final dataset = context.watch<ThreadActiveDatasetBloc>().state;
    final hasDataset = _hasDataset(dataset);

    return CardWidget(
      title: 'Active Dataset',
      child: hasDataset
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Active timestamp', '${dataset.activeTimestamp}'),
                _detailRow('Network name', dataset.networkName),
                _detailRow('Extended PAN ID', dataset.extendedPanId),
                _detailRow('Mesh-local prefix', dataset.meshLocalPrefix),
                _detailRow('PAN ID', '${dataset.panId}'),
                _detailRow('Channel', '${dataset.threadChannel}'),
              ],
            )
          : Text(
              'No active dataset received yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final addresses = context.watch<ThreadAddressBloc>().state;
    final hasAddresses = addresses.unicastAddresses.isNotEmpty ||
        addresses.multicastAddresses.isNotEmpty;

    return CardWidget(
      title: 'IP Addresses',
      child: hasAddresses
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _addressList('Unicast addresses', addresses.unicastAddresses),
                const SizedBox(height: AppDimensions.spacingM),
                _addressList(
                  'Multicast addresses',
                  addresses.multicastAddresses,
                ),
              ],
            )
          : Text(
              'No addresses received yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
    );
  }

  Widget _buildCommandsCard(BuildContext context, bool disabled) {
    final bloc = context.read<ThreadCommandBloc>();

    return CardWidget(
      title: 'Thread Commands',
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          _commandButton(
            label: 'Enable Thread',
            disabled: disabled,
            onPressed: () => bloc.add(const ThreadEnableRequested()),
          ),
          _commandButton(
            label: 'Disable Thread',
            disabled: disabled,
            onPressed: () => bloc.add(const ThreadDisableRequested()),
          ),
          _commandButton(
            label: 'Refresh Status',
            disabled: disabled,
            onPressed: () => bloc.add(const ThreadStatusRefreshRequested()),
          ),
          _commandButton(
            label: 'Refresh Attachment',
            disabled: disabled,
            onPressed: () => bloc.add(const ThreadAttachmentRefreshRequested()),
          ),
          _commandButton(
            label: 'Refresh Role',
            disabled: disabled,
            onPressed: () => bloc.add(const ThreadRoleRefreshRequested()),
          ),
          _commandButton(
            label: 'Refresh Active Dataset',
            disabled: disabled,
            onPressed: () =>
                bloc.add(const ThreadActiveDatasetRefreshRequested()),
          ),
          _commandButton(
            label: 'Refresh Unicast Addresses',
            disabled: disabled,
            onPressed: () =>
                bloc.add(const ThreadUnicastAddressesRefreshRequested()),
          ),
          _commandButton(
            label: 'Refresh Multicast Addresses',
            disabled: disabled,
            onPressed: () =>
                bloc.add(const ThreadMulticastAddressesRefreshRequested()),
          ),
          _commandButton(
            label: 'Init Border Router',
            disabled: disabled,
            onPressed: () => bloc.add(const ThreadBorderRouterInitRequested()),
          ),
          _commandButton(
            label: 'Deinit Border Router',
            disabled: disabled,
            onPressed: () =>
                bloc.add(const ThreadBorderRouterDeinitRequested()),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetInitCard(BuildContext context) {
    return BlocConsumer<ThreadDatasetInitFormBloc, ThreadDatasetInitFormState>(
      listener: (context, state) {
        if (state is ThreadDatasetInitFormSuccess) {
          _showSnackBar(context, 'Thread dataset init command sent.');
        } else if (state is ThreadDatasetInitFormFailure) {
          _showSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        final submitting = state is ThreadDatasetInitFormSubmitting;

        return CardWidget(
          title: 'Thread Dataset',
          child: Form(
            key: _datasetFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimensions.spacingM,
                  runSpacing: AppDimensions.spacingM,
                  children: [
                    _field(
                      controller: _channelController,
                      label: 'Channel',
                      keyboardType: TextInputType.number,
                      validator: _requiredIntValidator('Channel'),
                    ),
                    _field(
                      controller: _panIdController,
                      label: 'PAN ID',
                      keyboardType: TextInputType.number,
                      validator: _requiredIntValidator('PAN ID'),
                    ),
                    _field(
                      controller: _networkNameController,
                      label: 'Network name',
                      validator: _requiredValidator('Network name'),
                    ),
                    _field(
                      controller: _extendedPanIdController,
                      label: 'Extended PAN ID',
                      validator: _requiredValidator('Extended PAN ID'),
                    ),
                    _field(
                      controller: _meshLocalPrefixController,
                      label: 'Mesh-local prefix',
                      validator: _requiredValidator('Mesh-local prefix'),
                    ),
                    _field(
                      controller: _networkKeyController,
                      label: 'Network key',
                      validator: _requiredValidator('Network key'),
                    ),
                    _field(
                      controller: _pskcController,
                      label: 'PSKc',
                      validator: _requiredValidator('PSKc'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                ElevatedButton.icon(
                  onPressed: submitting ? null : () => _submitDataset(context),
                  icon: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(submitting ? 'Submitting...' : 'Initialize'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusTile(
    BuildContext context, {
    required String title,
    required String value,
    required bool active,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 160,
      child: StatusCardWidget(
        title: title,
        value: value,
        titleColor: colorScheme.onSurface,
        valueColor: active ? colorScheme.primary : colorScheme.error,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Text('$label: ${value.isEmpty ? '-' : value}'),
    );
  }

  Widget _addressList(String label, List<String> addresses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spacingS),
        if (addresses.isEmpty)
          Text('No $label received yet.')
        else
          ...addresses.map((address) => Text(address)),
      ],
    );
  }

  Widget _commandButton({
    required String label,
    required bool disabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      child: Text(label),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: 260,
      child: LabeledTextField(
        controller: controller,
        label: label,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  void _submitDataset(BuildContext context) {
    if (_datasetFormKey.currentState?.validate() != true) return;

    context.read<ThreadDatasetInitFormBloc>().add(
          ThreadDatasetInitSubmitted(
            channel: int.parse(_channelController.text.trim()),
            panId: int.parse(_panIdController.text.trim()),
            networkName: _networkNameController.text.trim(),
            extendedPanId: _extendedPanIdController.text.trim(),
            meshLocalPrefix: _meshLocalPrefixController.text.trim(),
            networkKey: _networkKeyController.text.trim(),
            pskc: _pskcController.text.trim(),
          ),
        );
  }

  String? Function(String?) _requiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required.';
      }
      return null;
    };
  }

  String? Function(String?) _requiredIntValidator(String label) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return '$label is required.';
      if (int.tryParse(trimmed) == null) return '$label must be an integer.';
      return null;
    };
  }

  String _displayRole(ThreadRoleState state) {
    if (state.role.isEmpty || state.role.toLowerCase() == 'unknown') {
      return 'Unknown';
    }
    return state.role;
  }

  bool _hasDataset(ThreadActiveDatasetState state) {
    return state.activeTimestamp != 0 ||
        state.networkName.isNotEmpty ||
        state.extendedPanId.isNotEmpty ||
        state.meshLocalPrefix.isNotEmpty ||
        state.panId != 0 ||
        state.threadChannel != 0;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
