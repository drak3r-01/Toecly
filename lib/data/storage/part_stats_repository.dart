import '../../core/toeic_part.dart';
import '../exercises/models.dart';
import 'local_store.dart';

/// Answered / correct counters.
class AnswerCount {
  const AnswerCount(this.answered, this.correct);

  static const zero = AnswerCount(0, 0);

  final int answered;
  final int correct;

  /// Success rate from 0.0 to 1.0, or 0 when nothing was answered.
  double get rate => answered == 0 ? 0 : correct / answered;
}

/// Cumulative counters per part and per question category (never purged).
class PartStatsRepository {
  PartStatsRepository(this._store);

  final LocalStore _store;

  static const _key = 'answer_stats';

  static String _partKey(ToeicPart part) => 'part${part.number}';
  static String _categoryKey(ToeicPart part, QuestionCategory category) =>
      'part${part.number}.${category.jsonName}';

  Map<String, dynamic> _load() {
    final data = _store.readJson(_key);
    return data is Map<String, dynamic> ? data : {};
  }

  AnswerCount _count(Map<String, dynamic> all, String key) {
    final entry = all[key];
    return entry is List && entry.length == 2 && entry[0] is int && entry[1] is int
        ? AnswerCount(entry[0] as int, entry[1] as int)
        : AnswerCount.zero;
  }

  AnswerCount forPart(ToeicPart part) => _count(_load(), _partKey(part));

  AnswerCount forCategory(ToeicPart part, QuestionCategory category) =>
      _count(_load(), _categoryKey(part, category));

  Future<void> recordAnswer(
    ToeicPart part, {
    required bool isCorrect,
    QuestionCategory? category,
  }) =>
      recordAnswers([(part: part, isCorrect: isCorrect, category: category)]);

  /// Same as calling [recordAnswer] for each answer, with a single write.
  Future<void> recordAnswers(
    Iterable<({ToeicPart part, bool isCorrect, QuestionCategory? category})> answers,
  ) {
    final all = _load();
    for (final a in answers) {
      for (final key in [_partKey(a.part), if (a.category != null) _categoryKey(a.part, a.category!)]) {
        final previous = _count(all, key);
        all[key] = [previous.answered + 1, previous.correct + (a.isCorrect ? 1 : 0)];
      }
    }
    return _store.writeJson(_key, all);
  }

  Future<void> clear() => _store.writeJson(_key, <String, dynamic>{});
}
