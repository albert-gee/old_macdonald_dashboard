final class OrchestratorSnapshot {
  final WifiRuntimeSnapshot wifi;
  final ThreadRuntimeSnapshot thread;
  final MatterRuntimeSnapshot matter;
  final WebSocketRuntimeSnapshot websocket;

  const OrchestratorSnapshot({
    required this.wifi,
    required this.thread,
    required this.matter,
    required this.websocket,
  });

  factory OrchestratorSnapshot.empty() {
    return const OrchestratorSnapshot(
      wifi: WifiRuntimeSnapshot(),
      thread: ThreadRuntimeSnapshot(),
      matter: MatterRuntimeSnapshot(),
      websocket: WebSocketRuntimeSnapshot(),
    );
  }

  factory OrchestratorSnapshot.fromPayload(Map<String, Object?> payload) {
    return OrchestratorSnapshot(
      wifi: WifiRuntimeSnapshot.fromJson(_map(payload['wifi'])),
      thread: ThreadRuntimeSnapshot.fromJson(_map(payload['thread'])),
      matter: MatterRuntimeSnapshot.fromJson(_map(payload['matter'])),
      websocket: WebSocketRuntimeSnapshot.fromJson(_map(payload['websocket'])),
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) return const <String, Object?>{};
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
}

final class WifiRuntimeSnapshot {
  final String mode;
  final bool apRunning;
  final bool staConfigured;
  final bool staConnected;
  final String? staIp;
  final int? rssi;

  const WifiRuntimeSnapshot({
    this.mode = 'unknown',
    this.apRunning = false,
    this.staConfigured = false,
    this.staConnected = false,
    this.staIp,
    this.rssi,
  });

  factory WifiRuntimeSnapshot.fromJson(Map<String, Object?> json) {
    return WifiRuntimeSnapshot(
      mode: _string(json['mode'], 'unknown'),
      apRunning: _bool(json['ap_running']),
      staConfigured: _bool(json['sta_configured']),
      staConnected: _bool(json['sta_connected']),
      staIp: json['sta_ip']?.toString(),
      rssi: _nullableInt(json['rssi']),
    );
  }
}

final class ThreadRuntimeSnapshot {
  final bool enabled;
  final bool attached;
  final String role;
  final bool datasetPresent;

  const ThreadRuntimeSnapshot({
    this.enabled = false,
    this.attached = false,
    this.role = 'unknown',
    this.datasetPresent = false,
  });

  factory ThreadRuntimeSnapshot.fromJson(Map<String, Object?> json) {
    return ThreadRuntimeSnapshot(
      enabled: _bool(json['enabled']),
      attached: _bool(json['attached']),
      role: _string(json['role'], 'unknown'),
      datasetPresent: _bool(json['dataset_present']),
    );
  }
}

final class MatterRuntimeSnapshot {
  final bool controllerInitialized;
  final List<CommissionedMatterNodeSnapshot> commissionedNodes;

  const MatterRuntimeSnapshot({
    this.controllerInitialized = false,
    this.commissionedNodes = const [],
  });

  factory MatterRuntimeSnapshot.fromJson(Map<String, Object?> json) {
    final rawNodes = json['commissioned_nodes'];
    return MatterRuntimeSnapshot(
      controllerInitialized: _bool(json['controller_initialized']),
      commissionedNodes: rawNodes is List
          ? rawNodes
                .whereType<Map>()
                .map(
                  (node) => CommissionedMatterNodeSnapshot.fromJson(
                    node.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

final class CommissionedMatterNodeSnapshot {
  final String nodeId;
  final String? label;
  final bool? reachable;

  const CommissionedMatterNodeSnapshot({
    required this.nodeId,
    this.label,
    this.reachable,
  });

  factory CommissionedMatterNodeSnapshot.fromJson(Map<String, Object?> json) {
    return CommissionedMatterNodeSnapshot(
      nodeId: _string(json['node_id'], ''),
      label: json['label']?.toString(),
      reachable: json['reachable'] is bool ? json['reachable'] as bool : null,
    );
  }
}

final class WebSocketRuntimeSnapshot {
  final int clients;

  const WebSocketRuntimeSnapshot({this.clients = 0});

  factory WebSocketRuntimeSnapshot.fromJson(Map<String, Object?> json) {
    return WebSocketRuntimeSnapshot(clients: _int(json['clients']));
  }
}

bool _bool(Object? value) => value is bool ? value : false;

int _int(Object? value) => _nullableInt(value) ?? 0;

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String _string(Object? value, String fallback) =>
    value == null ? fallback : value.toString();
