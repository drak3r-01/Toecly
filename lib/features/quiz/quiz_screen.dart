import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../core/widgets/brand_hero_card.dart';
import '../../core/widgets/score_gauge.dart';
import '../../data/exercises/models.dart';
import '../../data/quiz/quiz_request.dart';
import '../../data/storage/session_record.dart';
import '../../data/quiz/quiz_session.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_page.dart';

/// Draws the exercises for [request], then runs a practice session.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.request});

  final QuizRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) => QuizSessionScreen(
        draw: ref.watch(quizDrawProvider(request)),
        mode: SessionMode.practice,
        leaveTo: AppDestination.practice,
        leaveLabel: AppLocalizations.of(context).quizBackToPractice,
      );
}

/// Runs a session with immediate correction on drawn exercises, recording
/// answers and the session summary. In review mode a right answer also
/// removes the question from the missed list.
class QuizSessionScreen extends ConsumerWidget {
  const QuizSessionScreen({
    super.key,
    required this.draw,
    required this.mode,
    required this.leaveTo,
    required this.leaveLabel,
  });

  final AsyncValue<List<Exercise>> draw;
  final SessionMode mode;

  /// Where "close" goes when there is nothing to pop back to.
  final AppDestination leaveTo;

  /// Label of the button that ends the session summary.
  final String leaveLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    void leave() => context.canPop() ? context.pop() : context.go(leaveTo.path);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.quizClose,
          onPressed: leave,
        ),
      ),
      body: SafeArea(
        child: draw.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(l10n.quizLoadError)),
          data: (exercises) => exercises.isEmpty
              ? Center(child: Text(l10n.quizEmpty))
              : QuizView(
                  exercises: exercises,
                  onLeave: leave,
                  leaveLabel: leaveLabel,
                  onAnswered: (exercise, question, isCorrect) =>
                      ref.read(answerRecorderProvider).recordAnswer(
                            exercise,
                            question,
                            isCorrect: isCorrect,
                            masterOnCorrect: mode == SessionMode.review,
                          ),
                  onFinished: (session, duration) =>
                      ref.read(answerRecorderProvider).recordSession(
                            mode: mode,
                            exercises: session.exercises,
                            totalQuestions: session.totalQuestions,
                            correctAnswers: session.correctCount,
                            duration: duration,
                          ),
                ),
        ),
      ),
    );
  }
}

/// The running session. Owns a [QuizSession] and rebuilds on each step.
class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
    required this.exercises,
    required this.onLeave,
    this.leaveLabel,
    this.onAnswered,
    this.onFinished,
  });

  final List<Exercise> exercises;
  final VoidCallback onLeave;

  /// Label of the summary's button; defaults to "Back to practice".
  final String? leaveLabel;

  /// Called right after each answer, so nothing is lost if the user quits midway.
  final void Function(Exercise exercise, Question question, bool isCorrect)? onAnswered;

  /// Called once, when the last question has been answered and left.
  final void Function(QuizSession session, Duration elapsed)? onFinished;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late final QuizSession _session = QuizSession(widget.exercises);
  final Stopwatch _stopwatch = Stopwatch()..start();

  void _select(int index) {
    final session = _session;
    if (session.isCurrentAnswered) return;
    final question = session.question;
    setState(() => session.select(index));
    widget.onAnswered?.call(session.exercise, question, index == question.answerIndex);
  }

  void _advance() {
    setState(_session.advance);
    if (_session.isFinished) {
      _stopwatch.stop();
      widget.onFinished?.call(_session, _stopwatch.elapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = _session;
    if (session.isFinished) {
      return _Summary(
        session: session,
        onLeave: widget.onLeave,
        leaveLabel: widget.leaveLabel ?? l10n.quizBackToPractice,
      );
    }

    final total = session.totalQuestions;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.quizQuestionCounter(session.answeredCount + 1, total)),
          const SizedBox(height: 6),
          AnimatedProgressBar(value: session.answeredCount / total, height: 8),
        ]),
      ),
      Expanded(
        child: ExercisePage(
          exercise: session.exercise,
          questionIndex: session.questionIndex,
          answers: {for (final q in session.exercise.questions) if (session.answerFor(q) != null) q.id: session.answerFor(q)!},
          revealed: session.isCurrentAnswered,
          onSelect: _select,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: session.isCurrentAnswered ? _advance : null,
            child: Text(session.isLastQuestion ? l10n.quizFinish : l10n.quizNext),
          ),
        ),
      ),
    ]);
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.session, required this.onLeave, required this.leaveLabel});

  final QuizSession session;
  final VoidCallback onLeave;
  final String leaveLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final total = session.totalQuestions;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.quizSummaryTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            BrandHeroCard(
              child: Column(children: [
                ScoreGauge(
                  value: session.correctCount / total,
                  size: 140,
                  child: Text(
                    '${(session.correctCount * 100 / total).round()}%',
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.quizSummaryScore(session.correctCount, total),
                  style: theme.textTheme.displaySmall?.copyWith(color: Colors.white),
                ),
              ]),
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: onLeave, child: Text(leaveLabel)),
          ]),
        ),
      ),
    );
  }
}
