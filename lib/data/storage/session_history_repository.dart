import 'local_store.dart';
import 'session_record.dart';

/// Session history, newest first. Beyond [maxSessions] the oldest are dropped.
class SessionHistoryRepository {
  SessionHistoryRepository(this._store);

  final LocalStore _store;

  static const _key = 'session_history';
  static const maxSessions = 200;

  List<SessionRecord> loadAll() {
    final data = _store.readJson(_key);
    if (data is! List) return const [];
    return [for (final item in data) SessionRecord.fromJson(item as Map<String, dynamic>)];
  }

  Future<void> add(SessionRecord record) {
    final updated = [record, ...loadAll()].take(maxSessions);
    return _store.writeJson(_key, [for (final r in updated) r.toJson()]);
  }

  Future<void> clear() => _store.writeJson(_key, <Object>[]);
}
