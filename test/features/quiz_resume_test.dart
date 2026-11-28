import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/quiz/quiz_session.dart';
import 'package:toecly/data/quiz/quiz_snapshot.dart';
import 'package:toecly/data/storage/local_store.dart';

const _p6 = Exercise(
  id: 'p6-x',
  part: ToeicPart.part6,
  documents: [
    ExerciseDocument(type: DocumentType.email, text: 'Thank you for [1] us. See you [2] week.'),
  ],
  questions: [
    Question(
      id: 'p6-x#1',
      prompt: '[1]',
      choices: ['visit', 'visiting', 'visited', 'visits'],
      answerIndex: 1,
      explanation: 'Gerund after a preposition.',
    ),
    Question(
      id: 'p6-x#2',
      prompt: '[2]',
      choices: ['last', 'next', 'ago', 'since'],
      answerIndex: 1,
      explanation: 'Future meaning.',
    ),
  ],
);

void main() {
  test('a snapshot restores the session where it stopped, and refuses a changed bank', () {
    final session = QuizSession([_p6])..select(1);
    final snapshot = QuizSnapshot.fromJson(
      QuizSnapshot.capture(session, location: '/quiz?parts=6&count=10').toJson(),
    );
    final restored = snapshot.restore([_p6])!;
    expect(restored.session.answeredCount, 1);
    expect(restored.session.question.id, 'p6-x#1');
    expect(restored.session.isCurrentAnswered, isTrue);

    final changed = Exercise(
      id: 'p6-x',
      part: ToeicPart.part6,
      documents: _p6.documents,
      questions: [
        for (final q in _p6.questions)
          Question(
            id: q.id,
            prompt: q.prompt,
            choices: const ['a', 'b', 'c', 'd'],
            answerIndex: 0,
            explanation: q.explanation,
          ),
      ],
    );
    expect(snapshot.restore([changed]), isNull);
    expect(snapshot.restore(const []), isNull);
  });

  testWidgets('leaving a session in progress asks first, and it can be resumed from home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = InMemoryStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          exerciseRepositoryProvider.overrideWithValue(ExerciseRepository(() async => [_p6])),
        ],
        child: const ToeclyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Part 5 · Incomplete sentences'));
    await tester.tap(find.text('Part 7 · Reading comprehension'));
    await tester.pump();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('visit'));
    await tester.pumpAndSettle();
    expect(store.read('quiz_in_progress'), isNotNull);

    // The system back goes through the same question as the close button.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Leave this session?'), findsOneWidget);
    await tester.tap(find.text('Keep going'));
    await tester.pumpAndSettle();
    expect(find.text('Blank 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave, resume later'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    final resume = find.text('Resume your session (1 / 2)', skipOffstage: false);
    await tester.ensureVisible(resume);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume your session (1 / 2)'));
    await tester.pumpAndSettle();
    expect(find.text('Gerund after a preposition.'), findsOneWidget); // answer still revealed
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Blank 2'), findsOneWidget);
  });

  testWidgets('quitting for good drops the saved session', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = InMemoryStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          exerciseRepositoryProvider.overrideWithValue(ExerciseRepository(() async => [_p6])),
        ],
        child: const ToeclyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('visit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit for good'));
    await tester.pumpAndSettle();
    expect(QuizProgressProbe(store).isEmpty, isTrue);
  });
}

class QuizProgressProbe {
  QuizProgressProbe(this._store);

  final LocalStore _store;

  bool get isEmpty =>
      _store.readJson('quiz_in_progress') is! Map ||
      (_store.readJson('quiz_in_progress') as Map).isEmpty;
}
