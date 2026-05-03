import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_report.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_active_dataset.dart';

sealed class OrchestratorMessage {
  const OrchestratorMessage();
}

final class ThreadStackStatusReceived extends OrchestratorMessage {
  final bool running;
  const ThreadStackStatusReceived(this.running);
}

final class ThreadInterfaceStatusReceived extends OrchestratorMessage {
  final bool interfaceUp;
  const ThreadInterfaceStatusReceived(this.interfaceUp);
}

final class ThreadAttachmentStatusReceived extends OrchestratorMessage {
  final bool attached;
  const ThreadAttachmentStatusReceived(this.attached);
}

final class ThreadRoleReceived extends OrchestratorMessage {
  final String role;
  const ThreadRoleReceived(this.role);
}

final class ThreadActiveDatasetReceived extends OrchestratorMessage {
  final ThreadActiveDataset dataset;
  const ThreadActiveDatasetReceived(this.dataset);
}

final class ThreadUnicastAddressesReceived extends OrchestratorMessage {
  final List<String> addresses;
  const ThreadUnicastAddressesReceived(this.addresses);
}

final class ThreadMulticastAddressesReceived extends OrchestratorMessage {
  final List<String> addresses;
  const ThreadMulticastAddressesReceived(this.addresses);
}

final class ThreadMeshcopServiceStatusReceived extends OrchestratorMessage {
  final bool published;
  const ThreadMeshcopServiceStatusReceived(this.published);
}

final class WifiStaStatusReceived extends OrchestratorMessage {
  final String status;
  const WifiStaStatusReceived(this.status);
}

final class MatterCommissioningCompleteReceived extends OrchestratorMessage {
  final int nodeId;
  final int fabricIndex;
  const MatterCommissioningCompleteReceived({
    required this.nodeId,
    required this.fabricIndex,
  });
}

final class MatterAttributeReportReceived extends OrchestratorMessage {
  final MatterAttributeReport report;
  const MatterAttributeReportReceived(this.report);
}

final class MatterSubscribeDoneReceived extends OrchestratorMessage {
  final int nodeId;
  final int subscriptionId;
  const MatterSubscribeDoneReceived({
    required this.nodeId,
    required this.subscriptionId,
  });
}

final class UnknownOrchestratorMessageReceived extends OrchestratorMessage {
  final String type;
  final String? action;
  final Map<String, Object?> payload;

  const UnknownOrchestratorMessageReceived({
    required this.type,
    required this.action,
    required this.payload,
  });
}
