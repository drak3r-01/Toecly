import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/splash/splash_overlay.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/data/storage/local_store.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())],
      child: const ToeclyApp(showSplash: true),
    ),
  );

  testWidgets('the splash plays over the app, then disappears', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.byType(SplashOverlay), findsOneWidget);
    expect(find.text('T'), findsOneWidget); // wordmark letters

    await tester.pump(SplashOverlay.duration);
    await tester.pumpAndSettle();
    expect(find.text('T'), findsNothing);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('a tap skips the splash', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('T'), findsNothing);
  });
}
