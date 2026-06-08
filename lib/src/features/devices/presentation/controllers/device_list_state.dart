import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';

final class DeviceListState {
  final bool loading;
  final List<DeviceRecord> devices;
  final Set<String> pendingDiscoveryDeviceIds;
  final String? message;

  const DeviceListState({
    this.loading = false,
    this.devices = const [],
    this.pendingDiscoveryDeviceIds = const {},
    this.message,
  });

  bool get discoveryPending => pendingDiscoveryDeviceIds.isNotEmpty;

  DeviceListState copyWith({
    bool? loading,
    List<DeviceRecord>? devices,
    Set<String>? pendingDiscoveryDeviceIds,
    String? message,
  }) {
    return DeviceListState(
      loading: loading ?? this.loading,
      devices: devices ?? this.devices,
      pendingDiscoveryDeviceIds:
          pendingDiscoveryDeviceIds ?? this.pendingDiscoveryDeviceIds,
      message: message,
    );
  }
}
