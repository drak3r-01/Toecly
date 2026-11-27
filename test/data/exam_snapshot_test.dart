import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/quiz/exam_session.dart';
import 'package:toecly/data/quiz/exam_snapshot.dart';
import 'package:toecly/data/storage/exam_progress_repository.dart';
import 'package:toecly/data/storage/local_store.dart';

import '../support/fixtures.dart';

void main() {
  final bank = [
    fakeExercise(ToeicPart.part5, 'p5-a'),
    fakeExercise(ToeicPart.part6, 'p6-a', documents: 1, questions: 4),
  ];

  // The displayed order differs from the bank: the right answer ('a') is shown last.
  List<Exercise> shuffledDraw() => [
        for (final e in bank)
          Exercise(
            id: e.id,
            part: e.part,
            documents: e.documents,
            questions: [
              for (final q in e.questions)
                Question(
                  id: q.id,
                  prompt: q.prompt,
                  choices: const ['d', 'c', 'b', 'a'],
                  answerIndex: 3,
                  explanation: q.explanation,
                ),
            ],
          ),
      ];

  ExamSnapshot capture() {
    final session = ExamSession(shuffledDraw())
      ..select(3)
      ..next()
      ..select(0);
    return ExamSnapshot.capture(
      session,
      endsAt: DateTime.utc(2026, 11, 27, 12),
      total: const Duration(minutes: 75),
    );
  }

  test('a snapshot survives JSON and rebuilds the exam as it was shown', () {
    final snapshot = ExamSnapshot.fromJson(
      jsonDecode(jsonEncode(capture().toJson())) as Map<String, dynamic>,
    );
    final exercises = snapshot.restore(bank)!;
    expect(exercises.map((e) => e.id), ['p5-a', 'p6-a']);
    final question = exercises.first.questions.single;
    expect(question.choices, ['d', 'c', 'b', 'a']);
    expect(question.choices[question.answerIndex], 'a');
    expect(snapshot.answers, {'p5-a': 3, 'p6-a#1': 0});
    expect(snapshot.currentIndex, 1);
    expect(snapshot.endsAt, DateTime.utc(2026, 11, 27, 12));
    expect(snapshot.totalSeconds, 4500);
  });

  test('restoring answers and position into a new session', () {
    final snapshot = capture();
    final session = ExamSession(snapshot.restore(bank)!)
      ..restore(
        answers: {...snapshot.answers, 'ghost': 1, 'p5-a#x': 9},
        currentIndex: 1,
      );
    expect(session.answeredCount, 2);
    expect(session.currentIndex, 1);
    expect(session.isCorrect(session.entries.first), isTrue);
  });

  test('a bank that changed cannot reproduce the exam', () {
    final snapshot = capture();
    expect(snapshot.restore([bank.first]), isNull); // an exercise is gone
    final edited = [
      Exercise(
        id: 'p5-a',
        part: ToeicPart.part5,
        questions: [
          Question(
            id: 'p5-a',
            prompt: 'p',
            choices: const ['x', 'y', 'z', 'w'],
            answerIndex: 0,
            explanation: 'e',
          ),
        ],
      ),
      bank.last,
    ];
    expect(snapshot.restore(edited), isNull); // the choices differ
  });

  group('ExamProgressRepository', () {
    test('saves, loads and clears', () async {
      final repository = ExamProgressRepository(InMemoryStore());
      expect(repository.load(), isNull);
      await repository.save(capture());
      expect(repository.load()!.exerciseIds, ['p5-a', 'p6-a']);
      await repository.clear();
      expect(repository.load(), isNull);
    });

    test('unreadable data reads as no saved exam', () {
      final store = InMemoryStore()..writeJson('exam_in_progress', {'exerciseIds': 'oops'});
      expect(ExamProgressRepository(store).load(), isNull);
    });
  });
}
