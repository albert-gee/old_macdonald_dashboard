import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_connection_state.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';

enum OperatorNextActionTarget {
  connect,
  diagnostics,
  setup,
  devices,
  chamber,
  ready,
}

final class OperatorNextAction {
  final String title;
  final String detail;
  final OperatorNextActionTarget target;

  const OperatorNextAction({
    required this.title,
    required this.detail,
    required this.target,
  });
}

final class OperatorRuntime {
  final OrchestratorConnectionState connection;
  final OrchestratorRuntimeState runtime;
  final List<DeviceRecord> devices;
  final ChamberState chamber;

  const OperatorRuntime({
    required this.connection,
    required this.runtime,
    required this.devices,
    required this.chamber,
  });

  OrchestratorSnapshot? get snapshot => runtime.snapshot;

  bool get connected =>
      connection.status == WebSocketConnectionStatus.connected;

  String get endpoint => connection.url;

  DateTime? get lastMessageAt => runtime.lastMessageAt;

  DateTime? get lastSnapshotAt => runtime.lastSnapshotAt;

  int get websocketClients => snapshot?.websocket.clients ?? 0;

  bool get snapshotReceived => snapshot != null;

  bool get wifiApRunning => snapshot?.wifi.apRunning ?? false;

  bool get threadEnabled => snapshot?.thread.enabled ?? false;

  bool get threadDatasetPresent => snapshot?.thread.datasetPresent ?? false;

  bool get threadAttached => snapshot?.thread.attached ?? false;

  String get threadRole => snapshot?.thread.role ?? 'unknown';

  bool? get matterPlatformInitialized => snapshot?.matter.platformInitialized;

  String? get matterPlatformError => snapshot?.matter.platformError;

  bool get matterPlatformFailed => matterPlatformInitialized == false;

  bool get matterControllerInitialized =>
      snapshot?.matter.controllerInitialized ?? false;

  int get commissionedNodeCount =>
      snapshot?.matter.commissionedNodes.length ?? 0;

  int get deviceCount => devices.length;

  bool get chamberHasTemperatureAssignment =>
      chamber.selectedTemperature != null ||
      _refConfigured(_firstChamber['temperature_source']);

  bool get chamberHasActuatorAssignment =>
      chamber.selectedRelay != null ||
      _refConfigured(_firstChamber['fan_actuator']);

  bool get controlRuleConfigured {
    final control = _control;
    return control['configured'] == true ||
        _refConfigured(control['sensor']) ||
        _refConfigured(control['actuator']);
  }

  bool get controlEnabled => chamber.controlEnabled;

  String get controlState => chamber.controlState;

  String? get globalError =>
      runtime.lastError ?? connection.message ?? chamber.error;

  Map<String, Object?> get _firstChamber {
    final chambers = snapshot?.rawPayload['chambers'];
    if (chambers is List && chambers.isNotEmpty && chambers.first is Map) {
      return (chambers.first as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return const {};
  }

  Map<String, Object?> get _control {
    final control = _firstChamber['control'];
    if (control is Map) {
      return control.map((key, value) => MapEntry(key.toString(), value));
    }
    final rules = snapshot?.rawPayload['control_rules'];
    if (rules is List && rules.isNotEmpty && rules.first is Map) {
      return (rules.first as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return const {};
  }

  OperatorNextAction get nextAction {
    if (!connected) {
      return const OperatorNextAction(
        title: 'Connect to Orchestrator',
        detail:
            'Connect your host to the Orchestrator Wi-Fi AP, then connect WSS.',
        target: OperatorNextActionTarget.connect,
      );
    }
    if (!snapshotReceived) {
      return const OperatorNextAction(
        title: 'Waiting for Orchestrator snapshot',
        detail: 'The WSS session is open. Waiting for runtime state.',
        target: OperatorNextActionTarget.diagnostics,
      );
    }
    if (matterPlatformFailed) {
      return OperatorNextAction(
        title: 'Matter platform failed',
        detail:
            matterPlatformError ??
            'Controller initialization and commissioning are blocked.',
        target: OperatorNextActionTarget.diagnostics,
      );
    }
    if (!threadDatasetPresent) {
      return const OperatorNextAction(
        title: 'Create Thread dataset',
        detail: 'Thread cannot start safely until an active dataset exists.',
        target: OperatorNextActionTarget.setup,
      );
    }
    if (!threadEnabled) {
      return const OperatorNextAction(
        title: 'Enable Thread',
        detail: 'Start the Thread interface after confirming the dataset.',
        target: OperatorNextActionTarget.setup,
      );
    }
    if (!matterControllerInitialized) {
      return const OperatorNextAction(
        title: 'Initialize Matter controller',
        detail: 'Matter commissioning requires the controller to be ready.',
        target: OperatorNextActionTarget.setup,
      );
    }
    if (devices.isEmpty && commissionedNodeCount == 0) {
      return const OperatorNextAction(
        title: 'Commission a device',
        detail: 'Pair a relay or sensor, then refresh device discovery.',
        target: OperatorNextActionTarget.setup,
      );
    }
    if (!chamberHasTemperatureAssignment || !chamberHasActuatorAssignment) {
      return const OperatorNextAction(
        title: 'Assign chamber devices',
        detail: 'Select a temperature source and an On/Off actuator.',
        target: OperatorNextActionTarget.chamber,
      );
    }
    if (!controlRuleConfigured) {
      return const OperatorNextAction(
        title: 'Configure cooling rule',
        detail: 'Set min/max thresholds and save the cooling rule.',
        target: OperatorNextActionTarget.chamber,
      );
    }
    return const OperatorNextAction(
      title: 'System ready',
      detail: 'Monitor readings, actuator state, and automation activity.',
      target: OperatorNextActionTarget.ready,
    );
  }

  bool _refConfigured(Object? value) {
    if (value is! Map) return false;
    final deviceId = value['device_id']?.toString() ?? '';
    final capabilityId = value['capability_id']?.toString() ?? '';
    return deviceId.isNotEmpty && capabilityId.isNotEmpty;
  }
}

String ageLabel(DateTime? value) {
  if (value == null) return 'Never';
  final elapsed = DateTime.now().difference(value);
  if (elapsed.inSeconds < 5) return 'Just now';
  if (elapsed.inSeconds < 60) return '${elapsed.inSeconds}s ago';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  return '${elapsed.inHours}h ago';
}

String titleCase(String value) {
  if (value.isEmpty) return 'Unknown';
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
