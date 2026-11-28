import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/quiz/quiz_request.dart';
import 'package:toecly/data/storage/last_practice_repository.dart';
import 'package:toecly/data/storage/local_store.dart';

import '../support/fixtures.dart';

void main() {
  test('a category travels through the quiz location and the last practice', () async {
    final request = QuizRequest(
      parts: [ToeicPart.part5],
      questionCount: 10,
      category: QuestionCategory.vocabulary,
    );
    expect(request.location, '/quiz?parts=5&count=10&category=vocabulary');
    expect(QuizRequest.fromQuery(Uri.parse(request.location).queryParameters), request);

    final store = InMemoryStore();
    await LastPracticeRepository(store).save(request);
    expect(LastPracticeRepository(store).load(), request);
  });

  test('drawing with a category only brings exercises holding that category', () async {
    final repository = ExerciseRepository(
      () async => [
        Exercise(
          id: 'g1',
          part: ToeicPart.part5,
          questions: [fakeQuestion('g1', category: QuestionCategory.grammar)],
        ),
        Exercise(
          id: 'v1',
          part: ToeicPart.part5,
          questions: [fakeQuestion('v1', category: QuestionCategory.vocabulary)],
        ),
      ],
    );
    final drawn = await repository.drawByQuestionCount(
      parts: {ToeicPart.part5},
      questionCount: 10,
      category: QuestionCategory.vocabulary,
    );
    expect([for (final e in drawn) e.id], ['v1']);
  });
}
