import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/quiz/quiz_request.dart';
import 'package:toecly/data/storage/last_practice_repository.dart';
import 'package:toecly/data/storage/local_store.dart';

Exercise _p5(int i) => Exercise(
      id: 'd$i',
      part: ToeicPart.part5,
      questions: [
        Question(
          id: 'd$i',
          prompt: 'Sentence $i ___.',
          choices: const ['right', 'wrong1', 'wrong2', 'wrong3'],
          answerIndex: 0,
          explanation: 'x',
          category: QuestionCategory.grammar,
        ),
      ],
    );

Future<InMemoryStore> _openApp(WidgetTester tester, {InMemoryStore? store}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [const Locale('en')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final usedStore = store ?? InMemoryStore();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      localStoreProvider.overrideWithValue(usedStore),
      exerciseRepositoryProvider
          .overrideWithValue(ExerciseRepository(() async => [for (var i = 0; i < 10; i++) _p5(i)])),
    ],
    child: const ToeclyApp(),
  ));
  await tester.pumpAndSettle();
  return usedStore;
}

void main() {
  test('last practice configuration round-trips, and bad data reads as absent', () async {
    final store = InMemoryStore();
    final repository = LastPracticeRepository(store);
    expect(repository.load(), isNull);

    final request = QuizRequest(parts: [ToeicPart.part7, ToeicPart.part5], questionCount: 25);
    await repository.save(request);
    expect(repository.load(), request);

    await store.write('last_practice', 'not json');
    expect(repository.load(), isNull);
  });

  testWidgets('resume without any previous practice opens the practice tab', (tester) async {
    await _openApp(tester);
    await tester.tap(find.text('Resume practice'));
    await tester.pumpAndSettle();
    expect(find.text('Number of questions'), findsOneWidget);
  });

  testWidgets('the dashboard follows a practice session and resumes its configuration',
      (tester) async {
    await _openApp(tester);
    expect(find.text('Questions answered: 0'), findsOneWidget);

    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('right'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('wrong1').first); // locked: ignored
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Questions answered: 1'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('5–60 / 495'), findsNothing); // 100%: top tier
    expect(find.text('480–495 / 495'), findsOneWidget);

    await tester.tap(find.text('Resume practice'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 / 10'), findsOneWidget);
  });
}
