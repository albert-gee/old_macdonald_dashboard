final class MatterCommandState {
  final bool submitting;
  final String? message;
  final bool success;

  const MatterCommandState({
    this.submitting = false,
    this.message,
    this.success = false,
  });
}
