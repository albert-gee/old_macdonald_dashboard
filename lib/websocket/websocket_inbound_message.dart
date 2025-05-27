import 'package:logger/logger.dart';

abstract class WebSocketInboundMessage {
  final String type;
  final String? action;
  final dynamic payload;

  WebSocketInboundMessage({required this.type, this.action, required this.payload});

  factory WebSocketInboundMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final action = json['action'] as String?;
    final payload = json['payload'];

    final Logger logger = Logger();
    logger.d('Parsing WebSocket message: type=$type, action=$action, payload=$payload');

    if (type == 'info') {
      switch (action) {
        case 'thread.stack_status':
          return ThreadStackStatusMessage(payload['running'] == true);
        case 'thread.interface_status':
          return ThreadInterfaceStatusMessage(payload['interface_up'] == true);
        case 'thread.attachment_status':
          return ThreadAttachmentStatusMessage(payload['attached'] == true);
        case 'thread.role':
          return ThreadRoleMessage(payload['role']);
        case 'thread.active_dataset':
          return ThreadDatasetActiveMessage(Map<String, dynamic>.from(payload));
        case 'ipv6.unicast_addresses':
          return UnicastAddressListMessage(List<String>.from(payload['unicast']));
        case 'ipv6.multicast_addresses':
          return MulticastAddressListMessage(List<String>.from(payload['multicast']));
        case 'thread.meshcop_service':
          return MeshcopServiceStatusMessage(payload['published'] == true);
        case 'wifi.sta_status':
          return WifiStaStatusMessage(payload['status']);
        case 'matter.commissioning_complete':
          return MatterCommissioningCompleteMessage(
            nodeId: payload['node_id'],
            fabricIndex: payload['fabric_index'],
          );
        case 'matter.attribute_report':
          return MatterAttributeReportMessage(
            nodeId: payload['node_id'],
            endpointId: payload['endpoint_id'],
            clusterId: payload['cluster_id'],
            attributeId: payload['attribute_id'],
            value: payload['value'],
          );
        case 'matter.subscribe_done':
          return MatterSubscribeDoneMessage(
            nodeId: payload['node_id'],
            subscriptionId: payload['subscription_id'],
          );
      }
    }

    return GenericMessage(type: type, action: action, payload: payload);
  }
}

class ThreadStackStatusMessage extends WebSocketInboundMessage {
  final bool running;
  ThreadStackStatusMessage(this.running)
      : super(type: 'info', action: 'thread.stack_status', payload: {'running': running});
}

class ThreadInterfaceStatusMessage extends WebSocketInboundMessage {
  final bool interfaceUp;
  ThreadInterfaceStatusMessage(this.interfaceUp)
      : super(type: 'info', action: 'thread.interface_status', payload: {'interface_up': interfaceUp});
}

class ThreadAttachmentStatusMessage extends WebSocketInboundMessage {
  final bool attached;
  ThreadAttachmentStatusMessage(this.attached)
      : super(type: 'info', action: 'thread.attachment_status', payload: {'attached': attached});
}

class ThreadRoleMessage extends WebSocketInboundMessage {
  final String role;
  ThreadRoleMessage(this.role)
      : super(type: 'info', action: 'thread.role', payload: {'role': role});
}

class ThreadDatasetActiveMessage extends WebSocketInboundMessage {
  final Map<String, dynamic> dataset;
  ThreadDatasetActiveMessage(this.dataset)
      : super(type: 'info', action: 'thread.active_dataset', payload: dataset);
}

class UnicastAddressListMessage extends WebSocketInboundMessage {
  final List<String> addresses;
  UnicastAddressListMessage(this.addresses)
      : super(type: 'info', action: 'ipv6.unicast_addresses', payload: {'unicast': addresses});
}

class MulticastAddressListMessage extends WebSocketInboundMessage {
  final List<String> addresses;
  MulticastAddressListMessage(this.addresses)
      : super(type: 'info', action: 'ipv6.multicast_addresses', payload: {'multicast': addresses});
}

class MeshcopServiceStatusMessage extends WebSocketInboundMessage {
  final bool published;
  MeshcopServiceStatusMessage(this.published)
      : super(type: 'info', action: 'thread.meshcop_service', payload: {'published': published});
}

class WifiStaStatusMessage extends WebSocketInboundMessage {
  final String status;
  WifiStaStatusMessage(this.status)
      : super(type: 'info', action: 'wifi.sta_status', payload: {'status': status});
}

class MatterCommissioningCompleteMessage extends WebSocketInboundMessage {
  final int nodeId;
  final int fabricIndex;
  MatterCommissioningCompleteMessage({required this.nodeId, required this.fabricIndex})
      : super(type: 'info', action: 'matter.commissioning_complete', payload: {
    'node_id': nodeId,
    'fabric_index': fabricIndex,
  });
}

class MatterAttributeReportMessage extends WebSocketInboundMessage {
  final int nodeId;
  final int endpointId;
  final int clusterId;
  final int attributeId;
  final String value;

  MatterAttributeReportMessage({
    required this.nodeId,
    required this.endpointId,
    required this.clusterId,
    required this.attributeId,
    required this.value,
  }) : super(type: 'info', action: 'matter.attribute_report', payload: {
    'node_id': nodeId,
    'endpoint_id': endpointId,
    'cluster_id': clusterId,
    'attribute_id': attributeId,
    'value': value,
  });
}

class MatterSubscribeDoneMessage extends WebSocketInboundMessage {
  final int nodeId;
  final int subscriptionId;
  MatterSubscribeDoneMessage({
    required this.nodeId,
    required this.subscriptionId,
  }) : super(type: 'info', action: 'matter.subscribe_done', payload: {
    'node_id': nodeId,
    'subscription_id': subscriptionId,
  });
}

class GenericMessage extends WebSocketInboundMessage {
  GenericMessage({required super.type, super.action, required super.payload});
}
