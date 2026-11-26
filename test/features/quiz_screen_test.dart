import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/features/quiz/quiz_screen.dart';
import 'package:toecly/l10n/app_localizations.dart';

const _p5 = Exercise(
  id: 'p5-x',
  part: ToeicPart.part5,
  questions: [
    Question(
      id: 'p5-x',
      prompt: 'The meeting was ___ until Monday.',
      choices: ['postpone', 'postponed', 'postponing', 'postpones'],
      answerIndex: 1,
      explanation: 'Passive voice.',
    ),
  ],
);

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

const _p7 = Exercise(
  id: 'p7-x',
  part: ToeicPart.part7,
  documents: [
    ExerciseDocument(type: DocumentType.jobAd, title: 'Ad title', text: 'Ad body'),
    ExerciseDocument(type: DocumentType.email, title: 'Mail title', text: 'Mail body'),
  ],
  questions: [
    Question(
      id: 'p7-x#1',
      prompt: 'What is advertised?',
      choices: ['A job', 'A car', 'A house', 'A trip'],
      answerIndex: 0,
      explanation: 'It is a job ad.',
    ),
  ],
);

Future<void> pumpQuiz(WidgetTester tester, List<Exercise> exercises, {Size size = const Size(400, 900)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: QuizView(exercises: exercises, onLeave: () {})),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('wrong answer: red feedback, right answer in green, explanation unfolds', (tester) async {
    await pumpQuiz(tester, [_p5]);
    expect(find.text('Explanation'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Finish'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.text('postpone'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect'), findsOneWidget);
    expect(find.text('Explanation'), findsOneWidget);
    expect(find.text('Passive voice.'), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
  });

  testWidgets('the answer is locked after the first tap', (tester) async {
    await pumpQuiz(tester, [_p5]);
    await tester.tap(find.text('postponed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('postpone'));
    await tester.pumpAndSettle();
    expect(find.text('Correct!'), findsOneWidget);
  });

  testWidgets('Part 6: blanks are shown in the text and filled once answered', (tester) async {
    await pumpQuiz(tester, [_p6]);
    expect(find.textContaining('(1) ______', findRichText: true), findsOneWidget);
    expect(find.text('Blank 1'), findsOneWidget);

    await tester.tap(find.text('visit'));
    await tester.pumpAndSettle();
    expect(find.textContaining('visiting', findRichText: true), findsWidgets);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Blank 2'), findsOneWidget);
    expect(find.text('Question 2 / 2'), findsOneWidget);
  });

  testWidgets('Part 7 on a phone: documents in tabs above the question', (tester) async {
    await pumpQuiz(tester, [_p7]);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('What is advertised?'), findsOneWidget);
  });

  testWidgets('Part 7 on a PC: documents side by side with the question', (tester) async {
    await pumpQuiz(tester, [_p7], size: const Size(1400, 900));
    expect(find.byType(TabBar), findsNothing); // 3/5 of 1400 px still fits two documents
    expect(find.text('Ad body'), findsOneWidget);
    expect(find.text('Mail body'), findsOneWidget);
    expect(find.text('What is advertised?'), findsOneWidget);
  });

  testWidgets('a full session ends on the summary with the score', (tester) async {
    await pumpQuiz(tester, [_p5, _p7]);
    await tester.tap(find.text('postponed')); // right
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A car')); // wrong
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('1 / 2 correct'), findsOneWidget);
  });

  testWidgets('Practice quick start opens a session drawn from the stock', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(InMemoryStore()),
        exerciseRepositoryProvider.overrideWithValue(ExerciseRepository(() async => [_p5])),
      ],
      child: const ToeclyApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Part 5 · Incomplete sentences'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 / 1'), findsOneWidget);
    expect(find.text('The meeting was ___ until Monday.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Quick start'), findsOneWidget);
  });
}
