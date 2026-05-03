final class WifiStaConnectState {
  final bool submitting;
  final String? message;
  final bool success;

  const WifiStaConnectState({
    this.submitting = false,
    this.message,
    this.success = false,
  });

  WifiStaConnectState copyWith({
    bool? submitting,
    String? message,
    bool? success,
    bool clearMessage = false,
  }) {
    return WifiStaConnectState(
      submitting: submitting ?? this.submitting,
      message: clearMessage ? null : message ?? this.message,
      success: success ?? this.success,
    );
  }
}
