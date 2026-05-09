import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';
import 'package:dashboard/src/features/wifi/domain/repositories/wifi_command_repository.dart';
import 'wifi_sta_connect_state.dart';

final class WifiStaConnectController
    extends StateNotifier<WifiStaConnectState> {
  final WifiCommandRepository _repository;

  WifiStaConnectController({required WifiCommandRepository repository})
      : _repository = repository,
        super(const WifiStaConnectState());

  Future<void> connect(WifiStaCredentials credentials) async {
    state = state.copyWith(submitting: true, clearMessage: true);
    final result = await _repository.connectSta(credentials);
    state = switch (result) {
      Success() => state.copyWith(
          submitting: false,
          message: 'Wi-Fi STA connect command sent.',
          success: true,
        ),
      FailureResult(failure: final failure) => state.copyWith(
          submitting: false,
          message: failure.message,
          success: false,
        ),
    };
  }
}
