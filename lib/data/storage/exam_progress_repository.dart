import '../quiz/exam_snapshot.dart';
import 'local_store.dart';

/// The mock exam in progress, saved so it can be resumed if Android kills the app.
class ExamProgressRepository {
  ExamProgressRepository(this._store);

  final LocalStore _store;

  static const _key = 'exam_in_progress';

  /// The saved exam, or null when there is none or it cannot be read.
  ExamSnapshot? load() {
    final data = _store.readJson(_key);
    if (data is! Map<String, dynamic>) return null;
    try {
      return ExamSnapshot.fromJson(data);
    } on Object {
      return null;
    }
  }

  Future<void> save(ExamSnapshot snapshot) => _store.writeJson(_key, snapshot.toJson());

  Future<void> clear() => _store.writeJson(_key, <String, dynamic>{});
}
