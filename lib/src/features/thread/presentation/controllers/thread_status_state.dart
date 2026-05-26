import 'package:dashboard/src/features/thread/domain/entities/thread_status.dart';

final class ThreadStatusState {
  final ThreadStatus status;
  final bool hasData;

  const ThreadStatusState({
    this.status = const ThreadStatus(),
    this.hasData = false,
  });
}
