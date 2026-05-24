final class DeviceRecord {
  final String deviceId;
  final String nodeId;
  final int endpointId;
  final String deviceTypeId;
  final String label;
  final bool reachable;
  final int? vendorId;
  final int? productId;
  final String? productName;
  final String? location;

  const DeviceRecord({
    required this.deviceId,
    required this.nodeId,
    required this.endpointId,
    required this.deviceTypeId,
    required this.label,
    required this.reachable,
    this.vendorId,
    this.productId,
    this.productName,
    this.location,
  });

  factory DeviceRecord.fromJson(Map<String, Object?> json) {
    final deviceId = json['device_id']?.toString() ?? '';
    return DeviceRecord(
      deviceId: deviceId,
      nodeId: json['node_id']?.toString() ?? '',
      endpointId: _int(json['endpoint_id']),
      deviceTypeId: _deviceType(json['device_type_id']),
      label: (json['label']?.toString().trim().isNotEmpty ?? false)
          ? json['label'].toString()
          : deviceId,
      reachable: json['reachable'] is bool ? json['reachable'] as bool : false,
      vendorId: _nullableInt(json['vendor_id']),
      productId: _nullableInt(json['product_id']),
      productName: json['product_name']?.toString(),
      location: json['location']?.toString(),
    );
  }
}

String _deviceType(Object? value) {
  if (value is int) return '0x${value.toRadixString(16).padLeft(4, '0')}';
  if (value is String && value.isNotEmpty) {
    final parsed = int.tryParse(value);
    if (parsed != null) return '0x${parsed.toRadixString(16).padLeft(4, '0')}';
    return value;
  }
  return 'unknown';
}

int _int(Object? value) => _nullableInt(value) ?? 0;

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
