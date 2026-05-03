final class ThreadDatasetInitState {
  final bool submitting;
  final String? message;
  final bool success;

  const ThreadDatasetInitState({
    this.submitting = false,
    this.message,
    this.success = false,
  });
}
