import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses node_id as int and string with safe defaults', () {
    final intNode = DeviceRecord.fromJson({
      'device_id': 'temp-1',
      'node_id': 123,
      'reachable': true,
    });
    final stringNode = DeviceRecord.fromJson({
      'device_id': 'temp-2',
      'node_id': '456',
    });

    expect(intNode.nodeId, '123');
    expect(intNode.label, 'temp-1');
    expect(intNode.reachable, true);
    expect(intNode.capabilities, isEmpty);
    expect(stringNode.nodeId, '456');
  });

  test('parses temperature pressure relay and unknown capabilities', () {
    final record = DeviceRecord.fromJson({
      'device_id': 'bmp280-1',
      'node_id': '123456789',
      'label': 'BMP280 Sensor',
      'capabilities': [
        {
          'capability_id': 'bmp280-1-temperature',
          'semantic_type': 'temperature',
          'endpoint_id': 1,
          'cluster_id': 1026,
          'attribute_id': 0,
          'label': 'Temperature',
        },
        {
          'capability_id': 'bmp280-1-pressure',
          'semantic_type': 'pressure',
          'endpoint_id': 2,
          'cluster_id': 1027,
          'attribute_id': 0,
          'label': 'Pressure',
        },
        {
          'capability_id': 'relay-1-onoff',
          'semantic_type': 'relay',
          'endpoint_id': 1,
          'cluster_id': 6,
          'command_id': 1,
          'label': 'On/Off',
        },
        {
          'capability_id': 'custom',
          'semantic_type': 'vendor_custom',
          'endpoint_id': 3,
          'cluster_id': 999,
          'label': 'Custom',
        },
      ],
    });

    expect(
      record.capabilities[0].semanticType,
      DeviceCapabilitySemanticType.temperature,
    );
    expect(record.capabilities[0].attributeId, 0);
    expect(
      record.capabilities[1].semanticType,
      DeviceCapabilitySemanticType.pressure,
    );
    expect(
      record.capabilities[2].semanticType,
      DeviceCapabilitySemanticType.relay,
    );
    expect(record.capabilities[2].commandId, 1);
    expect(
      record.capabilities[3].semanticType,
      DeviceCapabilitySemanticType.unknown,
    );
  });
}
