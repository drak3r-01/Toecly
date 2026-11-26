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
    return data is List ? data.cast<String>() : const [];
  }

  Future<void> markMissed(String questionId) {
    final updated = [questionId, ...loadIds().where((id) => id != questionId)]
        .take(maxMissedQuestions)
        .toList();
    return _store.writeJson(_key, updated);
  }

  /// Call when the user finally gets the question right in review.
  Future<void> markMastered(String questionId) =>
      _store.writeJson(_key, loadIds().where((id) => id != questionId).toList());

  Future<void> clear() => _store.writeJson(_key, <String>[]);
}
