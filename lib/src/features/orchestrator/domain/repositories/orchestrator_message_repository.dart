import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';

abstract interface class OrchestratorMessageRepository {
  Stream<OrchestratorMessage> watchMessages();
}
