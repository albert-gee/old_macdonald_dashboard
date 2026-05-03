import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_report.dart';

sealed class MatterEvent {
  const MatterEvent();
}

final class MatterCommissioningCompleteEvent extends MatterEvent {
  final int nodeId;
  final int fabricIndex;

  const MatterCommissioningCompleteEvent({
    required this.nodeId,
    required this.fabricIndex,
  });
}

final class MatterAttributeReportEvent extends MatterEvent {
  final MatterAttributeReport report;

  const MatterAttributeReportEvent(this.report);
}

final class MatterSubscribeDoneEvent extends MatterEvent {
  final int nodeId;
  final int subscriptionId;

  const MatterSubscribeDoneEvent({
    required this.nodeId,
    required this.subscriptionId,
  });
}

final class MatterEventState {
  final List<MatterEvent> recentEvents;

  const MatterEventState({
    this.recentEvents = const [],
  });
}
