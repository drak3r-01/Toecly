import 'dart:math';

import '../../core/toeic_part.dart';
import 'mock_exam_blueprint.dart';
import 'models.dart';

typedef ExerciseLoader = Future<List<Exercise>> Function();

/// Single access point to the exercises. Loads everything once (lazily), then
/// draws at random. Part 5 is drawn question by question, Parts 6 and 7 as whole
/// exercises, since their questions only make sense with their text.
class ExerciseRepository {
  ExerciseRepository(this._load, {Random? random}) : _random = random ?? Random();

  final ExerciseLoader _load;
  final Random _random;
  Future<List<Exercise>>? _cache;

  Future<List<Exercise>> _all() => _cache ??= _load();

  Future<int> countQuestions(ToeicPart part) async => (await _all())
      .where((e) => e.part == part)
      .fold<int>(0, (sum, e) => sum + e.questions.length);

  /// Draws exercises from [parts] until about [questionCount] questions are
  /// reached without exceeding it. Returns fewer if the stock is too small.
  Future<List<Exercise>> drawByQuestionCount({
    required Set<ToeicPart> parts,
    required int questionCount,
  }) async {
    final pool = (await _all()).where((e) => parts.contains(e.part)).toList()..shuffle(_random);
    final drawn = <Exercise>[];
    var total = 0;
    for (final exercise in pool) {
      if (total + exercise.questions.length <= questionCount) {
        drawn.add(exercise);
        total += exercise.questions.length;
      }
      if (total == questionCount) break;
    }
    return _shuffleChoices(drawn);
  }

  /// Draws a mock exam: Part 5, then Part 6, then Part 7 (single, double, triple).
  /// Stock shortages give a shorter exam rather than an error.
  Future<List<Exercise>> drawMockExam([
    MockExamBlueprint blueprint = MockExamBlueprint.official,
  ]) async {
    final all = await _all();
    List<Exercise> pick(bool Function(Exercise) test, int count) =>
        (all.where(test).toList()..shuffle(_random)).take(count).toList();
    bool part7WithDocs(Exercise e, int docs) =>
        e.part == ToeicPart.part7 && e.documents.length == docs;

    return _shuffleChoices([
      ...pick((e) => e.part == ToeicPart.part5, blueprint.part5Questions),
      ...pick((e) => e.part == ToeicPart.part6, blueprint.part6Exercises),
      ...pick((e) => part7WithDocs(e, 1), blueprint.part7SingleExercises),
      ...pick((e) => part7WithDocs(e, 2), blueprint.part7DoubleExercises),
      ...pick((e) => part7WithDocs(e, 3), blueprint.part7TripleExercises),
    ]);
  }

  /// Finds the exercises owning the given question ids (review mode).
  /// Unknown ids are ignored; each exercise appears once.
  Future<List<Exercise>> findByQuestionIds(Iterable<String> questionIds) async {
    final wanted = questionIds.toSet();
    return (await _all()).where((e) => e.questions.any((q) => wanted.contains(q.id))).toList();
  }

  /// Draws exercises holding the given missed questions, in random order, up to
  /// about [questionCount] questions. An exercise comes whole, so a Part 6/7
  /// exercise may bring along questions that were not missed. Always returns
  /// something when there is something to review, even if the first exercise
  /// alone exceeds [questionCount].
  Future<List<Exercise>> drawForReview(Iterable<String> questionIds, int questionCount) async {
    final pool = (await findByQuestionIds(questionIds))..shuffle(_random);
    final drawn = <Exercise>[];
    var total = 0;
    for (final exercise in pool) {
      if (drawn.isNotEmpty && total + exercise.questions.length > questionCount) continue;
      drawn.add(exercise);
      total += exercise.questions.length;
    }
    return _shuffleChoices(drawn);
  }

  /// Choices are shuffled at draw time so the data files and saved ids stay untouched.
  List<Exercise> _shuffleChoices(List<Exercise> exercises) =>
      [for (final e in exercises) e.shuffled(_random)];
}
