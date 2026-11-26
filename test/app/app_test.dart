import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/part_stats_repository.dart';

void main() {
  Future<InMemoryStore> pumpApp(
    WidgetTester tester, {
    Size size = const Size(400, 800),
    InMemoryStore? store,
    Locale locale = const Locale('en'),
  }) async {
    final usedStore = store ?? InMemoryStore();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(ProviderScope(
      key: UniqueKey(), // a fresh app, as after a restart
      overrides: [localStoreProvider.overrideWithValue(usedStore)],
      child: const ToeclyApp(),
    ));
    await tester.pumpAndSettle();
    return usedStore;
  }

  testWidgets('phone: bottom navigation bar', (tester) async {
    await pumpApp(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('PC: side navigation rail', (tester) async {
    await pumpApp(tester, size: const Size(1200, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('follows the system language (French)', (tester) async {
    await pumpApp(tester, locale: const Locale('fr'));
    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Score Reading estimé'), findsOneWidget);
  });

  testWidgets('unsupported system language falls back to English', (tester) async {
    await pumpApp(tester, locale: const Locale('de'));
    expect(find.text('Estimated Reading score'), findsOneWidget);
  });

  testWidgets('language can be changed in settings and is remembered', (tester) async {
    final store = await pumpApp(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(find.text('Réglages'), findsWidgets);
    expect(store.read('language'), 'fr');

    await pumpApp(tester, store: store, locale: const Locale('en'));
    expect(find.text('Score Reading estimé'), findsOneWidget);
  });

  testWidgets('theme can be changed in settings and is remembered', (tester) async {
    final store = await pumpApp(tester);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(store.read('theme_mode'), 'dark');
  });

  testWidgets('dashboard: no score before any answer', (tester) async {
    await pumpApp(tester);
    expect(find.text('— / 495'), findsOneWidget);
    expect(find.text('— / 990'), findsOneWidget);
  });

  testWidgets('dashboard: shows the score range and category rates once answers exist', (tester) async {
    final store = InMemoryStore();
    final stats = PartStatsRepository(store);
    for (var i = 0; i < 10; i++) {
      await stats.recordAnswer(ToeicPart.part5, isCorrect: i < 6);
    }
    await pumpApp(tester, store: store);
    expect(find.text('295–345 / 495'), findsOneWidget);
    expect(find.text('590–690 / 990'), findsOneWidget);
  });

  testWidgets('mock exam screen announces 100 questions in 75 minutes', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Mock exam').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('100 questions in 75 minutes'), findsOneWidget);
  });
}
