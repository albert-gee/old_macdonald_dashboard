import 'dart:async';

import 'package:logger/logger.dart';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/orchestrator/data/dtos/outbound_orchestrator_command_dto.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/pending_orchestrator_command.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/services/orchestrator_request_id_generator.dart';

final class OrchestratorCommandClientImpl implements OrchestratorCommandClient {
  final OrchestratorConnectionRepository _connectionRepository;
  final OrchestratorRequestIdGenerator _requestIdGenerator;
  final Logger _logger;
  final StreamController<Map<String, PendingOrchestratorCommand>>
  _pendingController =
      StreamController<Map<String, PendingOrchestratorCommand>>.broadcast();
  final Map<String, PendingOrchestratorCommand> _pending = {};
  final Map<String, Completer<OrchestratorCommandResult>> _completers = {};
  late final StreamSubscription<OrchestratorMessage> _messageSubscription;
  late final StreamSubscription<WebSocketConnectionStatus> _statusSubscription;

  OrchestratorCommandClientImpl({
    required OrchestratorConnectionRepository connectionRepository,
    required OrchestratorMessageRepository messageRepository,
    required OrchestratorRequestIdGenerator requestIdGenerator,
    required Logger logger,
  }) : _connectionRepository = connectionRepository,
       _requestIdGenerator = requestIdGenerator,
       _logger = logger {
    _messageSubscription = messageRepository.watchMessages().listen(_onMessage);
    _statusSubscription = connectionRepository.status.listen((status) {
      if (status == WebSocketConnectionStatus.disconnected) {
        _failAllDisconnected();
      }
    });
  }

  @override
  Map<String, PendingOrchestratorCommand> get pendingCommands =>
      Map.unmodifiable(_pending);

  @override
  Stream<Map<String, PendingOrchestratorCommand>> get pendingCommandsStream =>
      _pendingController.stream;

  @override
  Future<Result<OrchestratorCommandResult>> sendCommand(
    String action, {
    Map<String, Object?> payload = const <String, Object?>{},
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final requestId = _requestIdGenerator.next();
    final pending = PendingOrchestratorCommand(
      requestId: requestId,
      action: action,
      createdAt: DateTime.now(),
    );
    final completer = Completer<OrchestratorCommandResult>();
    _pending[requestId] = pending;
    _completers[requestId] = completer;
    _emitPending();

    final dto = OutboundOrchestratorCommandDto(
      requestId: requestId,
      action: action,
      payload: payload,
    );
    final sendResult = await _connectionRepository.sendRaw(dto.toJsonString());
    if (sendResult case FailureResult(failure: final failure)) {
      _removePending(requestId);
      return FailureResult(failure);
    }

    try {
      final result = await completer.future.timeout(timeout);
      if (!result.ok) {
        return FailureResult(
          UnknownFailure(
            result.error?.message ?? 'Orchestrator command failed.',
          ),
        );
      }
      return Success(result);
    } on TimeoutException {
      _removePending(requestId);
      return const FailureResult(
        UnknownFailure('Timed out waiting for Orchestrator response.'),
      );
    }
  }

  Future<void> dispose() async {
    await _messageSubscription.cancel();
    await _statusSubscription.cancel();
    await _pendingController.close();
  }

  void _onMessage(OrchestratorMessage message) {
    if (message case CommandResultReceived(result: final result)) {
      final completer = _completers[result.requestId];
      if (completer == null) {
        _logger.w(
          'Ignoring command_result for unknown request_id '
          '${result.requestId}.',
        );
        return;
      }
      _removePending(result.requestId, complete: false);
      if (!completer.isCompleted) completer.complete(result);
    }
  }

  void _failAllDisconnected() {
    final completers = Map<String, Completer<OrchestratorCommandResult>>.from(
      _completers,
    );
    _pending.clear();
    _completers.clear();
    _emitPending();
    for (final completer in completers.values) {
      if (!completer.isCompleted) {
        completer.complete(
          const OrchestratorCommandResult(
            requestId: '',
            action: '',
            ok: false,
            payload: {},
            error: OrchestratorCommandError(
              code: 'DISCONNECTED',
              message: 'WebSocket disconnected before command completed.',
            ),
          ),
        );
      }
    }
  }

  void _removePending(String requestId, {bool complete = true}) {
    _pending.remove(requestId);
    final completer = _completers.remove(requestId);
    if (complete && completer != null && !completer.isCompleted) {
      completer.complete(
        OrchestratorCommandResult(
          requestId: requestId,
          action: '',
          ok: false,
          payload: const {},
          error: const OrchestratorCommandError(
            code: 'CANCELLED',
            message: 'Command was cancelled.',
          ),
        ),
      );
    }
    _emitPending();
  }

  void _emitPending() {
    if (!_pendingController.isClosed) {
      _pendingController.add(Map.unmodifiable(_pending));
    }
  }
}
