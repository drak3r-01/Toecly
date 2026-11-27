import 'local_store.dart';

/// Ids of the questions already answered, most recent first, so new draws can favour
/// questions never seen. Beyond [maxSeenQuestions] the oldest are forgotten.
class SeenQuestionsRepository {
  SeenQuestionsRepository(this._store);

  final LocalStore _store;

  static const _key = 'seen_question_ids';
  static const maxSeenQuestions = 1000;

  Set<String> loadIds() {
    final data = _store.readJson(_key);
    return data is List
        ? {
            for (final id in data)
              if (id is String) id,
          }
        : {};
  }

  /// Marks [questionIds] as seen (the last one becomes the most recent), with a single write.
  Future<void> markSeen(Iterable<String> questionIds) {
    var ids = _ordered();
    for (final id in questionIds) {
      ids = [id, ...ids.where((other) => other != id)];
    }
    return _store.writeJson(_key, ids.take(maxSeenQuestions).toList());
  }

  List<String> _ordered() {
    final data = _store.readJson(_key);
    return data is List
        ? [
            for (final id in data)
              if (id is String) id,
          ]
        : [];
  }

  Future<void> clear() => _store.writeJson(_key, <String>[]);
}
