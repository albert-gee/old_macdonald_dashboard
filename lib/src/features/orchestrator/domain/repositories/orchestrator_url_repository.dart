import 'package:dashboard/src/core/errors/result.dart';

abstract interface class OrchestratorUrlRepository {
  Future<Result<String?>> readUrl();

  Future<Result<void>> saveUrl(String url);

  Future<Result<void>> clearUrl();
}
