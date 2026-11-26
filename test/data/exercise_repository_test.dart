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
}
