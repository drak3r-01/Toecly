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
import 'package:toecly/data/storage/part_stats_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';
import 'package:toecly/data/storage/session_record.dart';
import 'package:toecly/features/practice/practice_setup_screen.dart';
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

  testWidgets('Practice setup: pick parts and count, then start a session', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = InMemoryStore();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        exerciseRepositoryProvider.overrideWithValue(ExerciseRepository(() async => [_p5, _p6])),
      ],
      child: const ToeclyApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Part 6 · Text completion')); // unselect Part 6
    await tester.tap(find.text('Part 7 · Reading comprehension'));
    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 / 1'), findsOneWidget);
    expect(find.text('The meeting was ___ until Monday.'), findsOneWidget);

    await tester.tap(find.text('postpone')); // wrong answer
    await tester.pumpAndSettle();
    expect(MissedQuestionsRepository(store).loadIds(), ['p5-x']);
    expect(PartStatsRepository(store).forPart(ToeicPart.part5).answered, 1);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    final history = SessionHistoryRepository(store).loadAll();
    expect(history, hasLength(1));
    expect(history.single.mode, SessionMode.practice);
    expect(history.single.correctAnswers, 0);

    await tester.tap(find.text('Back to practice'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('at least one part stays selected', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(body: PracticeSetupScreen()),
    ));
    for (final label in ['Part 5', 'Part 6', 'Part 7']) {
      await tester.tap(find.textContaining(label));
      await tester.pump();
    }
    expect(find.byWidgetPredicate((w) => w is FilterChip && w.selected), findsOneWidget);
  });
}
