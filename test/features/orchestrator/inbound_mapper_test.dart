import 'package:dashboard/src/features/orchestrator/data/dtos/inbound_orchestrator_message_dto.dart';
import 'package:dashboard/src/features/orchestrator/data/mappers/inbound_orchestrator_message_mapper.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = InboundOrchestratorMessageMapper();

  OrchestratorMessage map(String action, Map<String, Object?> payload) {
    return mapper.map(
      InboundOrchestratorMessageDto(
        type: 'info',
        action: action,
        payload: payload,
      ),
    );
  }

  test('maps known inbound actions', () {
    expect(map('thread.stack_status', {'running': true}),
        isA<ThreadStackStatusReceived>());
    expect(map('thread.interface_status', {'interface_up': true}),
        isA<ThreadInterfaceStatusReceived>());
    expect(map('thread.attachment_status', {'attached': true}),
        isA<ThreadAttachmentStatusReceived>());
    expect(map('thread.role', {'role': 'leader'}), isA<ThreadRoleReceived>());
    expect(map('thread.active_dataset', {'network_name': 'mesh'}),
        isA<ThreadActiveDatasetReceived>());
    expect(
        map('ipv6.unicast_addresses', {
          'unicast': ['fd00::1']
        }),
        isA<ThreadUnicastAddressesReceived>());
    expect(
        map('ipv6.multicast_addresses', {
          'multicast': ['ff03::1']
        }),
        isA<ThreadMulticastAddressesReceived>());
    expect(map('thread.meshcop_service', {'published': true}),
        isA<ThreadMeshcopServiceStatusReceived>());
    expect(map('wifi.sta_status', {'status': 'connected'}),
        isA<WifiStaStatusReceived>());
    expect(
      map('matter.commissioning_complete', {'node_id': 1, 'fabric_index': 2}),
      isA<MatterCommissioningCompleteReceived>(),
    );
    expect(map('matter.attribute_report', {'value': '42'}),
        isA<MatterAttributeReportReceived>());
    expect(map('matter.subscribe_done', {'node_id': 1, 'subscription_id': 7}),
        isA<MatterSubscribeDoneReceived>());
  });

  test('malformed payload does not crash', () {
    expect(map('thread.stack_status', {'running': 'yes'}),
        isA<ThreadStackStatusReceived>());
  });

  test('unknown action returns unknown message', () {
    expect(map('other.action', {}), isA<UnknownOrchestratorMessageReceived>());
  });
}
