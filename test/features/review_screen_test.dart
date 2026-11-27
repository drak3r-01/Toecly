import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';
import 'package:toecly/data/storage/session_record.dart';

Exercise _p5(String id) => Exercise(
      id: id,
      part: ToeicPart.part5,
      questions: [
        Question(
          id: id,
          prompt: 'Sentence $id ___.',
          choices: const ['right', 'wrong1', 'wrong2', 'wrong3'],
          answerIndex: 0,
          explanation: 'Because.',
        ),
      ],
    );

Future<InMemoryStore> _openReview(WidgetTester tester, List<String> missedIds) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [const Locale('en')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final store = InMemoryStore();
  for (final id in missedIds.reversed) {
    await MissedQuestionsRepository(store).markMissed(id);
  }
  await tester.pumpWidget(ProviderScope(
    overrides: [
      localStoreProvider.overrideWithValue(store),
      exerciseRepositoryProvider
          .overrideWithValue(ExerciseRepository(() async => [_p5('a'), _p5('b'), _p5('c')])),
    ],
    child: const ToeclyApp(),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Review').last);
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('nothing missed: encouraging empty state, no start button', (tester) async {
    await _openReview(tester, []);
    expect(find.text('No missed question to review. Well done!'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('replays the missed questions; a right answer removes them from the list', (tester) async {
    final store = await _openReview(tester, ['a', 'b']);
    expect(find.text('Questions to review: 2'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 / 2'), findsOneWidget);

    // First question: right. Second: wrong, so it must stay in the list.
    await tester.tap(find.text('right'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('wrong1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(MissedQuestionsRepository(store).loadIds(), hasLength(1));
    expect(SessionHistoryRepository(store).loadAll().single.mode, SessionMode.review);

    await tester.tap(find.text('Back to review'));
    await tester.pumpAndSettle();
    expect(find.text('Questions to review: 1'), findsOneWidget);
  });

  testWidgets('ids of questions that no longer exist are dropped and not counted', (tester) async {
    final store = await _openReview(tester, ['a', 'gone-1', 'b', 'gone-2']);
    expect(find.text('Questions to review: 2'), findsOneWidget);
    expect(MissedQuestionsRepository(store).loadIds(), ['a', 'b']);
  });

  testWidgets('only dead ids left: nothing to review', (tester) async {
    await _openReview(tester, ['gone-1']);
    expect(find.text('No missed question to review. Well done!'), findsOneWidget);
  });
}
