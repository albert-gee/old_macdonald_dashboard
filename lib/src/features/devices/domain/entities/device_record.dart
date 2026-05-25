final class DeviceRecord {
  final String deviceId;
  final String nodeId;
  final String label;
  final bool reachable;
  final int? vendorId;
  final int? productId;
  final String? productName;
  final String? location;
  final List<DeviceCapability> capabilities;

  const DeviceRecord({
    required this.deviceId,
    required this.nodeId,
    required this.label,
    required this.reachable,
    this.vendorId,
    this.productId,
    this.productName,
    this.location,
    this.capabilities = const [],
  });

  factory DeviceRecord.fromJson(Map<String, Object?> json) {
    final deviceId = json['device_id']?.toString() ?? '';
    return DeviceRecord(
      deviceId: deviceId,
      nodeId: json['node_id']?.toString() ?? '',
      label: (json['label']?.toString().trim().isNotEmpty ?? false)
          ? json['label'].toString()
          : deviceId,
      reachable: json['reachable'] is bool ? json['reachable'] as bool : false,
      vendorId: _nullableInt(json['vendor_id']),
      productId: _nullableInt(json['product_id']),
      productName: json['product_name']?.toString(),
      location: json['location']?.toString(),
      capabilities: _capabilities(json['capabilities']),
    );
  }
}

final class DeviceCapability {
  final String capabilityId;
  final DeviceCapabilitySemanticType semanticType;
  final int? endpointId;
  final int? clusterId;
  final int? attributeId;
  final int? commandId;
  final String label;
  final List<String> validationWarnings;

  const DeviceCapability({
    required this.capabilityId,
    required this.semanticType,
    this.endpointId,
    this.clusterId,
    this.attributeId,
    this.commandId,
    required this.label,
    this.validationWarnings = const [],
  });

  factory DeviceCapability.fromJson(Map<String, Object?> json) {
    final capabilityId = json['capability_id']?.toString() ?? '';
    final semanticType = DeviceCapabilitySemanticType.fromWireValue(
      json['semantic_type']?.toString(),
    );
    final endpointId = _nullableInt(json['endpoint_id']);
    final clusterId = _nullableInt(json['cluster_id']);
    final attributeId = _nullableInt(json['attribute_id']);
    final commandId = _nullableInt(json['command_id']);
    return DeviceCapability(
      capabilityId: capabilityId,
      semanticType: semanticType,
      endpointId: endpointId,
      clusterId: clusterId,
      attributeId: attributeId,
      commandId: commandId,
      label: (json['label']?.toString().trim().isNotEmpty ?? false)
          ? json['label'].toString()
          : capabilityId,
      validationWarnings: _validationWarnings(
        semanticType: semanticType,
        endpointId: endpointId,
        clusterId: clusterId,
        attributeId: attributeId,
        commandId: commandId,
      ),
    );
  }

  String get semanticLabel => semanticType.label;

  bool get isValid => validationWarnings.isEmpty;
}

enum DeviceCapabilitySemanticType {
  temperature,
  pressure,
  relay,
  rawAttribute,
  rawCommand,
  unknown;

  factory DeviceCapabilitySemanticType.fromWireValue(String? value) {
    return switch (value) {
      'temperature' => DeviceCapabilitySemanticType.temperature,
      'pressure' => DeviceCapabilitySemanticType.pressure,
      'relay' => DeviceCapabilitySemanticType.relay,
      'raw_attribute' => DeviceCapabilitySemanticType.rawAttribute,
      'raw_command' => DeviceCapabilitySemanticType.rawCommand,
      _ => DeviceCapabilitySemanticType.unknown,
    };
  }

  String get wireValue {
    return switch (this) {
      DeviceCapabilitySemanticType.temperature => 'temperature',
      DeviceCapabilitySemanticType.pressure => 'pressure',
      DeviceCapabilitySemanticType.relay => 'relay',
      DeviceCapabilitySemanticType.rawAttribute => 'raw_attribute',
      DeviceCapabilitySemanticType.rawCommand => 'raw_command',
      DeviceCapabilitySemanticType.unknown => 'unknown',
    };
  }

  String get label {
    return switch (this) {
      DeviceCapabilitySemanticType.temperature => 'Temperature',
      DeviceCapabilitySemanticType.pressure => 'Pressure',
      DeviceCapabilitySemanticType.relay => 'Relay',
      DeviceCapabilitySemanticType.rawAttribute => 'Raw attribute',
      DeviceCapabilitySemanticType.rawCommand => 'Raw command',
      DeviceCapabilitySemanticType.unknown => 'Unknown',
    };
  }
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<String> _validationWarnings({
  required DeviceCapabilitySemanticType semanticType,
  required int? endpointId,
  required int? clusterId,
  required int? attributeId,
  required int? commandId,
}) {
  final warnings = <String>[];
  switch (semanticType) {
    case DeviceCapabilitySemanticType.temperature:
    case DeviceCapabilitySemanticType.pressure:
    case DeviceCapabilitySemanticType.relay:
    case DeviceCapabilitySemanticType.rawAttribute:
    case DeviceCapabilitySemanticType.rawCommand:
      if (endpointId == null) warnings.add('Missing or invalid endpoint_id.');
      if (clusterId == null) warnings.add('Missing or invalid cluster_id.');
    case DeviceCapabilitySemanticType.unknown:
      break;
  }
  switch (semanticType) {
    case DeviceCapabilitySemanticType.temperature:
    case DeviceCapabilitySemanticType.pressure:
    case DeviceCapabilitySemanticType.rawAttribute:
      if (attributeId == null) warnings.add('Missing or invalid attribute_id.');
    case DeviceCapabilitySemanticType.relay:
    case DeviceCapabilitySemanticType.rawCommand:
      if (commandId == null) warnings.add('Missing or invalid command_id.');
    case DeviceCapabilitySemanticType.unknown:
      break;
  }
  return warnings;
}

List<DeviceCapability> _capabilities(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map(
        (item) => DeviceCapability.fromJson(
          item.map((key, value) => MapEntry(key.toString(), value)),
        ),
      )
      .toList();
}
