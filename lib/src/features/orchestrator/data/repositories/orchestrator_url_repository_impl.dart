import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/storage/preferences_store.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_url_repository.dart';

final class OrchestratorUrlRepositoryImpl implements OrchestratorUrlRepository {
  static const _urlKey = 'orchestrator.websocket_url';

  final PreferencesStore _store;

  OrchestratorUrlRepositoryImpl({required PreferencesStore store})
      : _store = store;

  @override
  Future<Result<String?>> readUrl() => _store.readString(_urlKey);

  @override
  Future<Result<void>> saveUrl(String url) => _store.writeString(_urlKey, url);

  @override
  Future<Result<void>> clearUrl() => _store.remove(_urlKey);
}
