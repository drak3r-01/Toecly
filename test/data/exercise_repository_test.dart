import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/mock_exam_blueprint.dart';
import 'package:toecly/data/exercises/models.dart';

import '../support/fixtures.dart';

int questionTotal(Iterable<Exercise> exercises) =>
    exercises.fold(0, (sum, e) => sum + e.questions.length);

void main() {
  ExerciseRepository repositoryOf(List<Exercise> stock) =>
      ExerciseRepository(() async => stock, random: Random(1));

  test('counts the questions of a part', () async {
    final repository = repositoryOf(fakeFullStock());
    expect(await repository.countQuestions(ToeicPart.part5), 40);
    expect(await repository.countQuestions(ToeicPart.part6), 24);
  });

  test('shuffles the choices of drawn questions and keeps the right answer', () async {
    final stock = fakeFullStock();
    final originals = {for (final e in stock) for (final q in e.questions) q.id: q};
    final drawn = await repositoryOf(stock).drawMockExam();
    var moved = 0;
    for (final question in drawn.expand((e) => e.questions)) {
      final original = originals[question.id]!;
      expect([...question.choices]..sort(), [...original.choices]..sort());
      expect(question.choices[question.answerIndex], original.choices[original.answerIndex]);
      if (question.answerIndex != original.answerIndex) moved++;
    }
    expect(moved, greaterThan(0));
  });

  test('the stock is loaded only once', () async {
    var loads = 0;
    final repository = ExerciseRepository(() async {
      loads++;
      return fakeFullStock();
    });
    await repository.countQuestions(ToeicPart.part5);
    await repository.drawByQuestionCount(parts: {ToeicPart.part5}, questionCount: 5);
    expect(loads, 1);
  });

  group('drawByQuestionCount', () {
    test('Part 5 gives exactly the requested number, without duplicates', () async {
      final drawn = await repositoryOf(fakeFullStock())
          .drawByQuestionCount(parts: {ToeicPart.part5}, questionCount: 20);
      expect(drawn, hasLength(20));
      expect(drawn.map((e) => e.id).toSet(), hasLength(20));
    });

    test('Parts 6 and 7 are drawn as whole exercises and never exceed the count', () async {
      final drawn = await repositoryOf(fakeFullStock())
          .drawByQuestionCount(parts: {ToeicPart.part6, ToeicPart.part7}, questionCount: 18);
      expect(questionTotal(drawn), lessThanOrEqualTo(18));
      expect(questionTotal(drawn), greaterThan(18 - 5));
      expect(drawn.every((e) => e.part != ToeicPart.part5), isTrue);
    });

    test('returns everything available when the stock is too small', () async {
      final drawn = await repositoryOf([fakeExercise(ToeicPart.part5, 'only')])
          .drawByQuestionCount(parts: {ToeicPart.part5}, questionCount: 50);
      expect(drawn, hasLength(1));
    });
  });

  group('drawMockExam', () {
    test('follows the official format', () async {
      final exam = await repositoryOf(fakeFullStock()).drawMockExam();
      int count(bool Function(Exercise) test) => exam.where(test).length;

      expect(count((e) => e.part == ToeicPart.part5), 30);
      expect(count((e) => e.part == ToeicPart.part6), 4);
      expect(count((e) => e.part == ToeicPart.part7 && e.documents.length == 1), 10);
      expect(count((e) => e.part == ToeicPart.part7 && e.documents.length == 2), 2);
      expect(count((e) => e.part == ToeicPart.part7 && e.documents.length == 3), 3);
      expect(exam.map((e) => e.id).toSet(), hasLength(exam.length));
    });

    test('a shortage gives a shorter exam instead of an error', () async {
      final exam = await repositoryOf([fakeExercise(ToeicPart.part5, 'a')]).drawMockExam();
      expect(exam, hasLength(1));
    });

    test('the blueprint is 100 questions in 75 minutes', () {
      expect(MockExamBlueprint.officialQuestionCount, 100);
      expect(MockExamBlueprint.official.duration, const Duration(minutes: 75));
    });
  });

  test('findByQuestionIds returns each owning exercise once and ignores unknown ids', () async {
    final repository = repositoryOf(fakeFullStock());
    final found = await repository.findByQuestionIds(['p6-0#1', 'p6-0#3', 'p5-2', 'ghost']);
    expect(found.map((e) => e.id), unorderedEquals(['p6-0', 'p5-2']));
  });

  group('drawForReview', () {
    test('only brings exercises that hold a missed question, without duplicates', () async {
      final repository = repositoryOf(fakeFullStock());
      final drawn = await repository.drawForReview(['p5-1', 'p5-2', 'p6-0#2', 'ghost'], 10);
      expect(drawn.map((e) => e.id), unorderedEquals(['p5-1', 'p5-2', 'p6-0']));
    });

    test('stays within the budget but never comes back empty', () async {
      final repository = repositoryOf(fakeFullStock());
      final ids = ['p5-1', 'p5-2', 'p5-3', 'p5-4', 'p5-5'];
      expect(await repository.drawForReview(ids, 3), hasLength(3));
      // A Part 6 exercise has 4 questions: bigger than the budget, still returned.
      expect(await repository.drawForReview(['p6-0#1'], 2), hasLength(1));
      expect(await repository.drawForReview(const [], 5), isEmpty);
    });
  });
}
