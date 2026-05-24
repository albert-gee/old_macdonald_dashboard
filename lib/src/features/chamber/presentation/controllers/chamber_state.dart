import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';

final class ChamberState {
  final bool loading;
  final ChamberStatus? status;
  final double? lastTemperatureCelsius;
  final double? lastPressureKpa;
  final String? message;
  final bool success;

  const ChamberState({
    this.loading = false,
    this.status,
    this.lastTemperatureCelsius,
    this.lastPressureKpa,
    this.message,
    this.success = false,
  });

  ChamberState copyWith({
    bool? loading,
    ChamberStatus? status,
    double? lastTemperatureCelsius,
    double? lastPressureKpa,
    String? message,
    bool? success,
  }) {
    return ChamberState(
      loading: loading ?? this.loading,
      status: status ?? this.status,
      lastTemperatureCelsius:
          lastTemperatureCelsius ?? this.lastTemperatureCelsius,
      lastPressureKpa: lastPressureKpa ?? this.lastPressureKpa,
      message: message,
      success: success ?? this.success,
    );
  }
}
