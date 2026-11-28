import '../quiz/quiz_snapshot.dart';
import 'local_store.dart';

/// The practice or review session in progress, so it can be resumed.
class QuizProgressRepository {
  QuizProgressRepository(this._store);

  final LocalStore _store;

  static const _key = 'quiz_in_progress';

  /// The saved session, or null when there is none or it cannot be read.
  QuizSnapshot? load() {
    final data = _store.readJson(_key);
    if (data is! Map<String, dynamic>) return null;
    try {
      return QuizSnapshot.fromJson(data);
    } on Object {
      return null;
    }
  }

  Future<void> save(QuizSnapshot snapshot) => _store.writeJson(_key, snapshot.toJson());

  Future<void> clear() => _store.writeJson(_key, <String, dynamic>{});
}
