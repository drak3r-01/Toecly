import 'local_store.dart';

/// Ids of the questions to review, most recent first. Beyond
/// [maxMissedQuestions], the oldest are dropped.
class MissedQuestionsRepository {
  MissedQuestionsRepository(this._store);

  final LocalStore _store;

  static const _key = 'missed_question_ids';
  static const maxMissedQuestions = 500;

  List<String> loadIds() {
    final data = _store.readJson(_key);
    return data is List ? [for (final id in data) if (id is String) id] : const [];
  }

  Future<void> markMissed(String questionId) => markMissedAll([questionId]);

  /// Same as calling [markMissed] for each id in order, with a single write.
  Future<void> markMissedAll(Iterable<String> questionIds) {
    var ids = loadIds();
    for (final id in questionIds) {
      ids = [id, ...ids.where((other) => other != id)];
    }
    return _store.writeJson(_key, ids.take(maxMissedQuestions).toList());
  }

  /// Drops the ids that no longer exist in the question bank (ids are replaced when
  /// questions are regenerated). Returns the ids kept.
  Future<List<String>> retainOnly(Set<String> existingIds) async {
    final all = loadIds();
    final kept = all.where(existingIds.contains).toList();
    if (kept.length != all.length) await _store.writeJson(_key, kept);
    return kept;
  }

  /// Call when the user finally gets the question right in review.
  Future<void> markMastered(String questionId) =>
      _store.writeJson(_key, loadIds().where((id) => id != questionId).toList());

  Future<void> clear() => _store.writeJson(_key, <String>[]);
}
