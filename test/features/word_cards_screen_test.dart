import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/words/word_card.dart';
import 'package:toecly/features/words/word_cards_screen.dart';
import 'package:toecly/l10n/app_localizations.dart';

const _card = WordCard(
  id: 'w-001',
  word: 'allocate',
  partOfSpeech: PartOfSpeech.verb,
  definition: 'to give out resources',
  example: 'We allocate funds.',
  fr: 'allouer',
);

void main() {
  testWidgets('flip the card, mark it known, finish the deck and start over', (tester) async {
    final store = InMemoryStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          wordCardsProvider.overrideWith((ref) async => [_card]),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: WordCardsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('allocate'), findsOneWidget);
    expect(find.text('0 / 1 words known'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'I know it')).onPressed,
      isNull,
    );

    await tester.tap(find.text('allocate'));
    await tester.pumpAndSettle();
    expect(find.text('to give out resources'), findsOneWidget);
    expect(find.text('allouer'), findsOneWidget);

    await tester.tap(find.text('Again')); // goes back to the queue
    await tester.pumpAndSettle();
    expect(find.text('allocate'), findsOneWidget);

    await tester.tap(find.text('allocate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I know it'));
    await tester.pumpAndSettle();
    expect(find.text('Deck complete! You know every word.'), findsOneWidget);
    expect(find.text('1 / 1 words known'), findsOneWidget);

    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();
    expect(find.text('allocate'), findsOneWidget);
    expect(find.text('0 / 1 words known'), findsOneWidget);
  });
}
