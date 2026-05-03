import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_report.dart';
import 'package:dashboard/src/features/orchestrator/data/dtos/inbound_orchestrator_message_dto.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_active_dataset.dart';

final class InboundOrchestratorMessageMapper {
  const InboundOrchestratorMessageMapper();

  OrchestratorMessage map(InboundOrchestratorMessageDto dto) {
    final payload = dto.payload;
    if (dto.type == 'info') {
      switch (dto.action) {
        case 'thread.stack_status':
          return ThreadStackStatusReceived(_bool(payload['running']));
        case 'thread.interface_status':
          return ThreadInterfaceStatusReceived(_bool(payload['interface_up']));
        case 'thread.attachment_status':
          return ThreadAttachmentStatusReceived(_bool(payload['attached']));
        case 'thread.role':
          return ThreadRoleReceived(_string(payload['role']));
        case 'thread.active_dataset':
          return ThreadActiveDatasetReceived(
            ThreadActiveDataset(
              activeTimestamp: _int(payload['active_timestamp']),
              networkName: _string(payload['network_name']),
              extendedPanId: _string(payload['extended_pan_id']),
              meshLocalPrefix: _string(payload['mesh_local_prefix']),
              panId: _int(payload['pan_id']),
              channel: _int(payload['channel']),
            ),
          );
        case 'ipv6.unicast_addresses':
          return ThreadUnicastAddressesReceived(
              _stringList(payload['unicast']));
        case 'ipv6.multicast_addresses':
          return ThreadMulticastAddressesReceived(
            _stringList(payload['multicast']),
          );
        case 'thread.meshcop_service':
          return ThreadMeshcopServiceStatusReceived(
              _bool(payload['published']));
        case 'wifi.sta_status':
          return WifiStaStatusReceived(_string(payload['status']));
        case 'matter.commissioning_complete':
          return MatterCommissioningCompleteReceived(
            nodeId: _int(payload['node_id']),
            fabricIndex: _int(payload['fabric_index']),
          );
        case 'matter.attribute_report':
          return MatterAttributeReportReceived(
            MatterAttributeReport(
              nodeId: _int(payload['node_id']),
              endpointId: _int(payload['endpoint_id']),
              clusterId: _int(payload['cluster_id']),
              attributeId: _int(payload['attribute_id']),
              value: _string(payload['value']),
            ),
          );
        case 'matter.subscribe_done':
          return MatterSubscribeDoneReceived(
            nodeId: _int(payload['node_id']),
            subscriptionId: _int(payload['subscription_id']),
          );
      }
    }

    return UnknownOrchestratorMessageReceived(
      type: dto.type,
      action: dto.action,
      payload: payload,
    );
  }

  bool _bool(Object? value) => value is bool ? value : false;
  int _int(Object? value) => value is int ? value : 0;
  String _string(Object? value) => value is String ? value : '';

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }
}
