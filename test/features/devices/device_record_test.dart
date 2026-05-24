import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses int and string IDs safely', () {
    final intNode = DeviceRecord.fromJson({
      'device_id': 'temp-1',
      'node_id': 123,
      'endpoint_id': 1,
      'device_type_id': 770,
      'reachable': true,
    });
    final stringNode = DeviceRecord.fromJson({
      'device_id': 'temp-2',
      'node_id': '456',
      'endpoint_id': '2',
      'device_type_id': '0x0302',
    });

    expect(intNode.nodeId, '123');
    expect(intNode.deviceTypeId, '0x0302');
    expect(intNode.label, 'temp-1');
    expect(stringNode.nodeId, '456');
    expect(stringNode.endpointId, 2);
  });
}
