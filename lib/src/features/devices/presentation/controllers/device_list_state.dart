import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';

final class DeviceListState {
  final bool loading;
  final List<DeviceRecord> devices;
  final String? message;

  const DeviceListState({
    this.loading = false,
    this.devices = const [],
    this.message,
  });

  DeviceListState copyWith({
    bool? loading,
    List<DeviceRecord>? devices,
    String? message,
  }) {
    return DeviceListState(
      loading: loading ?? this.loading,
      devices: devices ?? this.devices,
      message: message,
    );
  }
}
