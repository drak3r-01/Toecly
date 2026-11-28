import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';
import 'package:toecly/data/storage/part_stats_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';
import 'package:toecly/data/storage/session_record.dart';

Future<InMemoryStore> _seededSettings(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1500);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [const Locale('en')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final store = InMemoryStore();
  await PartStatsRepository(store).recordAnswer(ToeicPart.part5, isCorrect: false);
  await MissedQuestionsRepository(store).markMissed('q1');
  await SessionHistoryRepository(store).add(
    SessionRecord(
      mode: SessionMode.practice,
      finishedAt: DateTime.utc(2026),
      parts: {ToeicPart.part5},
      totalQuestions: 1,
      correctAnswers: 0,
      durationSeconds: 5,
    ),
  );
  await store.write('theme_mode', 'dark');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: const ToeclyApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('reset progress asks first, and cancelling keeps everything', (tester) async {
    final store = await _seededSettings(tester);
    await tester.tap(find.text('Reset progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(PartStatsRepository(store).forPart(ToeicPart.part5).answered, 1);
    expect(MissedQuestionsRepository(store).loadIds(), ['q1']);
  });

  testWidgets('reset progress erases statistics but keeps the theme', (tester) async {
    final store = await _seededSettings(tester);
    await tester.tap(find.text('Reset progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(PartStatsRepository(store).forPart(ToeicPart.part5).answered, 0);
    expect(MissedQuestionsRepository(store).loadIds(), isEmpty);
    expect(SessionHistoryRepository(store).loadAll(), isEmpty);
    expect(store.read('theme_mode'), 'dark');

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Questions answered: 0'), findsOneWidget);
  });

  testWidgets('vibrations can be switched off and the choice is stored', (tester) async {
    final store = await _seededSettings(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(store.read('haptics'), 'off');
  });

  testWidgets('text size is stored and every tab still lays out in dark with huge text', (
    tester,
  ) async {
    final store = await _seededSettings(tester);
    await tester.tap(find.text('Huge'));
    await tester.pumpAndSettle();
    expect(store.read('text_size'), 'huge');
    for (final tab in ['Home', 'Practice', 'Mock exam', 'Review', 'Settings']) {
      await tester.tap(find.text(tab).last);
      // The review tab loads the real bank and may spin: a fixed pump is enough here.
      await tester.pump(const Duration(seconds: 2));
    }
    expect(tester.takeException(), isNull);
  });
}
