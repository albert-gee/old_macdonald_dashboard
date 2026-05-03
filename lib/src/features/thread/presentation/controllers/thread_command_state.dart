final class ThreadCommandState {
  final bool submitting;
  final String? message;
  final bool success;

  const ThreadCommandState({
    this.submitting = false,
    this.message,
    this.success = false,
  });
}
