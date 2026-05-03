import 'package:dashboard/src/core/websocket/websocket_client.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/data/dtos/inbound_orchestrator_message_dto.dart';
import 'package:dashboard/src/features/orchestrator/data/mappers/inbound_orchestrator_message_mapper.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';

final class OrchestratorMessageRepositoryImpl
    implements OrchestratorMessageRepository {
  final WebSocketClient _webSocketClient;
  final InboundOrchestratorMessageMapper _mapper;

  OrchestratorMessageRepositoryImpl({
    required WebSocketClient webSocketClient,
    InboundOrchestratorMessageMapper mapper =
        const InboundOrchestratorMessageMapper(),
  })  : _webSocketClient = webSocketClient,
        _mapper = mapper;

  @override
  Stream<OrchestratorMessage> watchMessages() {
    return _webSocketClient.messages.asyncExpand((message) async* {
      final dtoResult = InboundOrchestratorMessageDto.fromJsonString(message);
      switch (dtoResult) {
        case Success(value: final dto):
          yield _mapper.map(dto);
        case FailureResult():
          yield UnknownOrchestratorMessageReceived(
            type: '',
            action: null,
            payload: {'raw': message},
          );
      }
    });
  }
}
