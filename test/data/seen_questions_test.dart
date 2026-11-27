import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/mock_exam_blueprint.dart';
import 'package:toecly/data/quiz/answer_recorder.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';
import 'package:toecly/data/storage/part_stats_repository.dart';
import 'package:toecly/data/storage/seen_questions_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';

import '../support/fixtures.dart';

void main() {
  test('seen ids: most recent first, no duplicates, capped', () async {
    final repository = SeenQuestionsRepository(InMemoryStore());
    await repository.markSeen(['a', 'b']);
    await repository.markSeen(['a']);
    expect(repository.loadIds().toList(), ['a', 'b']);
    await repository.markSeen([for (var i = 0; i < 1200; i++) 'q$i']);
    final ids = repository.loadIds();
    expect(ids, hasLength(SeenQuestionsRepository.maxSeenQuestions));
    expect(ids.contains('q1199'), isTrue);
    expect(ids.contains('a'), isFalse);
  });

  test('a draw takes unseen questions first, then seen ones when nothing new is left', () async {
    final stock = [
      for (var i = 0; i < 10; i++) fakeExercise(ToeicPart.part5, 'p5-$i'),
    ];
    final repository = ExerciseRepository(() async => stock, random: Random(3));
    final seen = {for (var i = 0; i < 6; i++) 'p5-$i'};

    final four = await repository.drawByQuestionCount(
      parts: {ToeicPart.part5},
      questionCount: 4,
      seen: seen,
    );
    expect(four.map((e) => e.id).toSet(), {'p5-6', 'p5-7', 'p5-8', 'p5-9'});

    final eight = await repository.drawByQuestionCount(
      parts: {ToeicPart.part5},
      questionCount: 8,
      seen: seen,
    );
    expect(
      eight.map((e) => e.id).toSet().containsAll([
        'p5-6',
        'p5-7',
        'p5-8',
        'p5-9',
      ]),
      isTrue,
    );
    expect(eight, hasLength(8));
  });

  test('a mock exam prefers questions never seen', () async {
    final stock = fakeFullStock();
    final repository = ExerciseRepository(() async => stock, random: Random(5));
    final p5 = stock.where((e) => e.part == ToeicPart.part5).toList();
    final seen = {
      for (final e in p5.take(10)) e.id,
    }; // 30 unseen Part 5 questions remain
    final exam = await repository.drawMockExam(
      MockExamBlueprint.official,
      seen,
    );
    final drawn = exam.where((e) => e.part == ToeicPart.part5);
    expect(drawn.any((e) => seen.contains(e.id)), isFalse);
  });

  test('the recorder marks answered and skipped questions as seen', () async {
    final store = InMemoryStore();
    final seen = SeenQuestionsRepository(store);
    final recorder = AnswerRecorder(
      stats: PartStatsRepository(store),
      missed: MissedQuestionsRepository(store),
      history: SessionHistoryRepository(store),
      seen: seen,
    );
    final a = fakeExercise(ToeicPart.part5, 'a');
    final b = fakeExercise(ToeicPart.part5, 'b');
    final c = fakeExercise(ToeicPart.part5, 'c');
    await recorder.recordAnswer(a, a.questions.single, isCorrect: true);
    await recorder.recordSkipped(b.questions.single);
    expect(seen.loadIds(), {'a', 'b'});
    await recorder.recordExam(
      entries: [(exercise: c, question: c.questions.single)],
      answers: const {},
      correctAnswers: 0,
      duration: Duration.zero,
    );
    expect(seen.loadIds(), {'a', 'b', 'c'});
  });
}
