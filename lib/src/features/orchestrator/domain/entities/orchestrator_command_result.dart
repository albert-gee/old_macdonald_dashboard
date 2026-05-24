final class OrchestratorCommandError {
  final String code;
  final String message;

  const OrchestratorCommandError({required this.code, required this.message});
}

final class OrchestratorCommandResult {
  final String requestId;
  final String action;
  final bool ok;
  final Map<String, Object?> payload;
  final OrchestratorCommandError? error;

  const OrchestratorCommandResult({
    required this.requestId,
    required this.action,
    required this.ok,
    required this.payload,
    this.error,
  });
}
