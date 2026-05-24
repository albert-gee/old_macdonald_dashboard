final class PendingOrchestratorCommand {
  final String requestId;
  final String action;
  final DateTime createdAt;

  const PendingOrchestratorCommand({
    required this.requestId,
    required this.action,
    required this.createdAt,
  });
}
