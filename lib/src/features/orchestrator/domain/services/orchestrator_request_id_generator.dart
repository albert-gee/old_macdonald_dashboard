abstract interface class OrchestratorRequestIdGenerator {
  String next();
}

final class TimestampOrchestratorRequestIdGenerator
    implements OrchestratorRequestIdGenerator {
  int _counter = 0;

  @override
  String next() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _counter += 1;
    return 'req-$now-$_counter';
  }
}
