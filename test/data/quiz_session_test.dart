import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/quiz/quiz_request.dart';
import 'package:toecly/data/quiz/quiz_session.dart';

import '../support/fixtures.dart';

void main() {
  group('QuizSession', () {
    test('walks through every question of every exercise, then finishes', () {
      final session = QuizSession([
        fakeExercise(ToeicPart.part5, 'a'),
        fakeExercise(ToeicPart.part6, 'b', documents: 1, questions: 2),
      ]);
      expect(session.totalQuestions, 3);

      final seen = <String>[];
      while (!session.isFinished) {
        seen.add(session.question.id);
        session.select(0);
        session.advance();
      }
      expect(seen, ['a', 'b#1', 'b#2']);
      expect(session.answeredCount, 3);
      expect(session.correctCount, 3); // fake questions are all answered by choice 0
    });

    test('cannot advance before answering', () {
      final session = QuizSession([fakeExercise(ToeicPart.part5, 'a'), fakeExercise(ToeicPart.part5, 'b')]);
      session.advance();
      expect(session.question.id, 'a');
    });

    test('an answer is locked once given', () {
      final session = QuizSession([fakeExercise(ToeicPart.part5, 'a')]);
      session.select(2);
      session.select(0);
      expect(session.answerFor(session.question), 2);
      expect(session.correctCount, 0);
    });

    test('rejects a choice outside the question', () {
      final session = QuizSession([fakeExercise(ToeicPart.part5, 'a')]);
      expect(() => session.select(4), throwsRangeError);
    });

    test('isLastQuestion is true only on the very last question', () {
      final session = QuizSession([fakeExercise(ToeicPart.part7, 'a', documents: 1, questions: 2)]);
      expect(session.isLastQuestion, isFalse);
      session.select(0);
      session.advance();
      expect(session.isLastQuestion, isTrue);
    });

    test('an empty session is finished', () {
      final session = QuizSession([]);
      expect(session.isEmpty, isTrue);
      expect(session.isFinished, isTrue);
    });
  });

  group('random draw', () {
    test('never repeats a question, whatever the seed', () async {
      for (var seed = 0; seed < 50; seed++) {
        final repository = ExerciseRepository(() async => fakeFullStock(), random: Random(seed));
        final drawn = await repository.drawByQuestionCount(
          parts: ToeicPart.readingParts.toSet(),
          questionCount: 30,
        );
        final ids = [for (final e in drawn) ...e.questions.map((q) => q.id)];
        expect(ids.toSet().length, ids.length, reason: 'seed $seed');
        expect(ids.length, lessThanOrEqualTo(30));
      }
    });

    test('differs from one seed to another', () async {
      Future<List<String>> draw(int seed) async {
        final repository = ExerciseRepository(() async => fakeFullStock(), random: Random(seed));
        final drawn = await repository.drawByQuestionCount(parts: {ToeicPart.part5}, questionCount: 10);
        return drawn.map((e) => e.id).toList();
      }

      expect(await draw(1), isNot(await draw(2)));
    });

    test('Part 6 and 7 exercises come whole, Part 5 one question each', () async {
      final repository = ExerciseRepository(() async => fakeFullStock(), random: Random(3));
      final drawn = await repository.drawByQuestionCount(
        parts: ToeicPart.readingParts.toSet(),
        questionCount: 40,
      );
      for (final exercise in drawn) {
        expect(
          exercise.questions.length,
          switch (exercise.id.split('-').first) {
            'p5' => 1,
            'p6' => 4,
            'p7s' => 3,
            _ => 5,
          },
        );
      }
    });
  });

  group('QuizRequest', () {
    test('round-trips through its URL', () {
      final request = QuizRequest(parts: [ToeicPart.part7, ToeicPart.part5], questionCount: 20);
      expect(request.location, '/quiz?parts=5,7&count=20');
      final parsed = QuizRequest.fromQuery({'parts': '5,7', 'count': '20'});
      expect(parsed, request);
      expect(parsed.hashCode, request.hashCode);
    });

    test('invalid input falls back to all Reading parts and 10 questions', () {
      final request = QuizRequest.fromQuery({'parts': 'x,1,9', 'count': '-3'});
      expect(request.parts, ToeicPart.readingParts);
      expect(request.questionCount, 10);
    });
  });
}
