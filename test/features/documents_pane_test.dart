import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/features/exercise/document_view.dart';
import 'package:toecly/l10n/app_localizations.dart';

const docs = [
  ExerciseDocument(type: DocumentType.jobAd, title: 'Sales Manager wanted', text: 'Ad body'),
  ExerciseDocument(type: DocumentType.email, text: 'Mail body'),
];

Future<void> pump(WidgetTester tester, List<ExerciseDocument> documents, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: DocumentsPane(documents: documents)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a single document is shown alone, without tabs', (tester) async {
    await pump(tester, [docs.first], const Size(400, 800));
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Ad body'), findsOneWidget);
    expect(find.text('Job ad'), findsOneWidget);
  });

  testWidgets('phone: several documents are tabs, one visible at a time', (tester) async {
    await pump(tester, docs, const Size(400, 800));
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Sales Manager wanted'), findsWidgets);
    expect(find.text('Document 2'), findsOneWidget); // untitled document gets a numbered tab
    expect(find.text('Ad body'), findsOneWidget);
    expect(find.text('Mail body'), findsNothing);

    await tester.tap(find.text('Document 2'));
    await tester.pumpAndSettle();
    expect(find.text('Mail body'), findsOneWidget);
  });

  testWidgets('PC: documents are side by side', (tester) async {
    await pump(tester, docs, const Size(1200, 800));
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Ad body'), findsOneWidget);
    expect(find.text('Mail body'), findsOneWidget);
  });

  testWidgets('every document type renders', (tester) async {
    for (final type in DocumentType.values) {
      await pump(tester, [ExerciseDocument(type: type, text: 'body of ${type.name}')], const Size(400, 800));
      expect(find.text('body of ${type.name}'), findsOneWidget, reason: type.name);
    }
  });
}
