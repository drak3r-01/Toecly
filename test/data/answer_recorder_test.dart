import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/quiz/answer_recorder.dart';
import 'package:toecly/data/quiz/quiz_session.dart';
import 'package:toecly/data/storage/daily_progress_repository.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';
import 'package:toecly/data/storage/part_stats_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';
import 'package:toecly/data/storage/session_record.dart';

import '../support/fixtures.dart';

void main() {
  late InMemoryStore store;
  late AnswerRecorder recorder;

  setUp(() {
    store = InMemoryStore();
    recorder = AnswerRecorder(
      stats: PartStatsRepository(store),
      missed: MissedQuestionsRepository(store),
      history: SessionHistoryRepository(store),
      daily: DailyProgressRepository(store),
      now: () => DateTime.utc(2026, 11, 26),
    );
  });

  test('a wrong answer is counted and remembered as missed', () async {
    final exercise = fakeExercise(ToeicPart.part5, 'a');
    await recorder.recordAnswer(exercise, exercise.questions.single, isCorrect: false);

    expect(PartStatsRepository(store).forPart(ToeicPart.part5).answered, 1);
    expect(PartStatsRepository(store).forPart(ToeicPart.part5).correct, 0);
    expect(MissedQuestionsRepository(store).loadIds(), ['a']);
  });

  test('a right answer is counted but not marked missed', () async {
    final exercise = fakeExercise(ToeicPart.part5, 'a');
    await recorder.recordAnswer(exercise, exercise.questions.single, isCorrect: true);
    expect(PartStatsRepository(store).forPart(ToeicPart.part5).correct, 1);
    expect(MissedQuestionsRepository(store).loadIds(), isEmpty);
  });

  test('a right answer in review masters the question', () async {
    final exercise = fakeExercise(ToeicPart.part5, 'a');
    final question = exercise.questions.single;
    await recorder.recordAnswer(exercise, question, isCorrect: false);
    await recorder.recordAnswer(exercise, question, isCorrect: true, masterOnCorrect: true);
    expect(MissedQuestionsRepository(store).loadIds(), isEmpty);
  });

  test('the category feeds the per-category stats', () async {
    final exercise = Exercise(
      id: 'a',
      part: ToeicPart.part5,
      questions: [fakeQuestion('a', category: QuestionCategory.grammar)],
    );
    await recorder.recordAnswer(exercise, exercise.questions.single, isCorrect: true);
    expect(
      PartStatsRepository(store).forCategory(ToeicPart.part5, QuestionCategory.grammar).answered,
      1,
    );
  });

  test('a finished session is added to the history', () async {
    final session = QuizSession([
      fakeExercise(ToeicPart.part5, 'a'),
      fakeExercise(ToeicPart.part6, 'b', documents: 1),
    ]);
    session
      ..select(0)
      ..advance()
      ..select(1);
    await recorder.recordSession(
      mode: SessionMode.practice,
      exercises: session.exercises,
      totalQuestions: session.totalQuestions,
      correctAnswers: session.correctCount,
      duration: const Duration(seconds: 42),
    );

    final record = SessionHistoryRepository(store).loadAll().single;
    expect(record.parts, {ToeicPart.part5, ToeicPart.part6});
    expect(record.totalQuestions, 2);
    expect(record.correctAnswers, 1);
    expect(record.durationSeconds, 42);
    expect(record.finishedAt, DateTime.utc(2026, 11, 26));
  });

  test('an exam is recorded in one go: stats, missed (blank included) and history', () async {
    final a = fakeExercise(ToeicPart.part5, 'a');
    final b = fakeExercise(ToeicPart.part5, 'b');
    final c = fakeExercise(ToeicPart.part5, 'c');
    await recorder.recordExam(
      entries: [
        for (final e in [a, b, c]) (exercise: e, question: e.questions.single),
      ],
      answers: {'a': 0, 'b': 1}, // a right, b wrong, c left blank
      correctAnswers: 1,
      duration: const Duration(minutes: 3),
    );
    final stats = PartStatsRepository(store).forPart(ToeicPart.part5);
    expect((stats.answered, stats.correct), (2, 1));
    expect(MissedQuestionsRepository(store).loadIds(), unorderedEquals(['b', 'c']));
    final session = SessionHistoryRepository(store).loadAll().single;
    expect(session.mode, SessionMode.mockExam);
    expect((session.totalQuestions, session.correctAnswers, session.durationSeconds), (3, 1, 180));
  });

  test('each answer counts towards the daily goal', () async {
    final exercise = fakeExercise(ToeicPart.part5, 'a');
    await recorder.recordAnswer(exercise, exercise.questions.single, isCorrect: true);
    await recorder.recordAnswer(exercise, exercise.questions.single, isCorrect: false);
    expect(DailyProgressRepository(store).answeredOn(DateTime(2026, 11, 26)), 2);
  });
}
