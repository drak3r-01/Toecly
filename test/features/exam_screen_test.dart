import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toecly/app/providers.dart';
import 'package:toecly/app/toecly_app.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_repository.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/quiz/exam_session.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';
import 'package:toecly/data/storage/part_stats_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';
import 'package:toecly/data/storage/session_record.dart';
import 'package:toecly/features/mock_exam/exam_screen.dart';
import 'package:toecly/l10n/app_localizations.dart';

Exercise _p5(String id, String sentence) => Exercise(
      id: id,
      part: ToeicPart.part5,
      questions: [
        Question(
          id: id,
          prompt: sentence,
          choices: const ['right', 'wrong1', 'wrong2', 'wrong3'],
          answerIndex: 0,
          explanation: 'Because of $id.',
        ),
      ],
    );

final _stock = [_p5('p5-a', 'First sentence ___.'), _p5('p5-b', 'Second sentence ___.')];

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _pumpExam(
  WidgetTester tester, {
  Duration? duration,
  void Function(ExamSession, Duration)? onSubmitted,
}) async {
  _phone(tester);
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: ExamView(exercises: _stock, duration: duration, onLeave: () {}, onSubmitted: onSubmitted),
  ));
  await tester.pump(const Duration(milliseconds: 400));
}

// pumpAndSettle never ends here (the countdown ticks), so advance by hand:
// one frame to start the animations, one to let them finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('shows a countdown, and no correction while the exam runs', (tester) async {
    await _pumpExam(tester);
    expect(find.text('1:15:00'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('1:14:57'), findsOneWidget);

    await tester.tap(find.text('wrong1'));
    await _settle(tester);
    expect(find.text('Explanation'), findsNothing);
    expect(find.text('Incorrect'), findsNothing);
  });

  testWidgets('navigation is free: previous, next and the question grid', (tester) async {
    await _pumpExam(tester);
    expect(find.text('First sentence ___.'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await _settle(tester);
    expect(find.text('Second sentence ___.'), findsOneWidget);
    await tester.tap(find.text('Previous'));
    await _settle(tester);
    expect(find.text('First sentence ___.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view));
    await _settle(tester);
    await tester.tap(find.text('2'));
    await _settle(tester);
    expect(find.text('Second sentence ___.'), findsOneWidget);
  });

  testWidgets('submitting asks for confirmation, then shows the correction', (tester) async {
    Duration? used;
    await _pumpExam(tester, onSubmitted: (_, d) => used = d);
    await tester.tap(find.text('right')); // question 1 right, question 2 left blank
    await _settle(tester);
    await tester.pump(const Duration(seconds: 5));

    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await _settle(tester);
    expect(find.text('Unanswered questions: 1'), findsOneWidget);
    await tester.tap(find.text('Keep working'));
    await _settle(tester);
    expect(find.text('Mock exam result'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit').last);
    await _settle(tester);

    expect(find.text('Mock exam result'), findsOneWidget);
    expect(find.text('1 / 2 correct'), findsOneWidget);
    expect(find.text('Not answered'), findsOneWidget);
    expect(used, isNotNull);
    expect(used!.inSeconds, greaterThanOrEqualTo(5));

    // Only the mistakes, then the question in context with its explanation.
    await tester.tap(find.text('Mistakes'));
    await _settle(tester);
    expect(find.textContaining('1. First sentence'), findsNothing);
    await tester.tap(find.textContaining('2. Second sentence'));
    await tester.pumpAndSettle();
    expect(find.text('Because of p5-b.'), findsOneWidget);
  });

  testWidgets('when time runs out the exam is submitted by itself', (tester) async {
    var submissions = 0;
    await _pumpExam(tester, duration: const Duration(seconds: 3), onSubmitted: (_, _) => submissions++);
    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);
    expect(find.text('Time is up: your exam was submitted.'), findsOneWidget);
    expect(submissions, 1);
    await tester.pump(const Duration(seconds: 5));
    expect(submissions, 1);
  });

  testWidgets('from the Mock exam tab: draw, answer, submit, results are recorded', (tester) async {
    _phone(tester);
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = InMemoryStore();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        exerciseRepositoryProvider.overrideWithValue(ExerciseRepository(() async => _stock)),
      ],
      child: const ToeclyApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mock exam').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start the exam'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('right'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit').last);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Mock exam result'), findsOneWidget);
    expect(PartStatsRepository(store).forPart(ToeicPart.part5).answered, 1);
    expect(PartStatsRepository(store).forPart(ToeicPart.part5).correct, 1);
    // The unanswered question is kept for review, not counted as answered.
    expect(MissedQuestionsRepository(store).loadIds().length, 1);
    final record = SessionHistoryRepository(store).loadAll().single;
    expect(record.mode, SessionMode.mockExam);
    expect(record.totalQuestions, 2);
    expect(record.correctAnswers, 1);
  });
}
