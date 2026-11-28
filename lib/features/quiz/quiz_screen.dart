import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../core/widgets/brand_hero_card.dart';
import '../../core/widgets/confetti_burst.dart';
import '../../core/widgets/score_gauge.dart';
import '../../data/exercises/models.dart';
import '../../data/quiz/quiz_request.dart';
import '../../data/storage/session_record.dart';
import '../../data/quiz/quiz_session.dart';
import '../../data/quiz/quiz_snapshot.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_page.dart';

/// Draws the exercises for [request], then runs a practice session.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.request, this.resume = false});

  final QuizRequest request;
  final bool resume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = resumeOrDraw(ref, resume, () => ref.watch(quizDrawProvider(request)));
    return QuizSessionScreen(
      draw: source.draw,
      initial: source.initial,
      location: request.location,
      mode: SessionMode.practice,
      leaveTo: AppDestination.practice,
      leaveLabel: AppLocalizations.of(context).quizBackToPractice,
    );
  }
}

/// The saved session when [resume] is set and it can still be rebuilt, otherwise [fresh].
({AsyncValue<List<Exercise>> draw, QuizSession? initial}) resumeOrDraw(
  WidgetRef ref,
  bool resume,
  AsyncValue<List<Exercise>> Function() fresh,
) {
  if (!resume) return (draw: fresh(), initial: null);
  final resumed = ref.watch(resumedQuizProvider);
  if (resumed.isLoading) return (draw: const AsyncLoading(), initial: null);
  final value = resumed.value;
  if (value == null) return (draw: fresh(), initial: null);
  return (draw: AsyncData(value.exercises), initial: value.session);
}

/// Runs a session with immediate correction on drawn exercises, recording
/// answers and the session summary. In review mode a right answer also
/// removes the question from the missed list.
class QuizSessionScreen extends ConsumerWidget {
  const QuizSessionScreen({
    super.key,
    required this.draw,
    this.initial,
    required this.location,
    required this.mode,
    required this.leaveTo,
    required this.leaveLabel,
  });

  final AsyncValue<List<Exercise>> draw;

  /// Route that reopens this session (saved with the progress).
  final String location;

  /// A session picked up where it stopped, or null for a fresh one.
  final QuizSession? initial;
  final SessionMode mode;

  /// Where "close" goes when there is nothing to pop back to.
  final AppDestination leaveTo;

  /// Label of the button that ends the session summary.
  final String leaveLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    void leave() {
      ref.read(dataRevisionProvider.notifier).bump(); // the home screen shows the saved session
      context.canPop() ? context.pop() : context.go(leaveTo.path);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.quizClose,
          // maybePop goes through the same "leave?" question as the system back.
          onPressed: () => Navigator.of(context).maybePop(),
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
                  initial: initial,
                  onLeave: leave,
                  onDiscard: () => ref.read(quizProgressProvider).clear(),
                  onProgress: (session) => ref
                      .read(quizProgressProvider)
                      .save(QuizSnapshot.capture(session, location: location)),
                  leaveLabel: leaveLabel,
                  onAnswered: (exercise, question, isCorrect) => ref
                      .read(answerRecorderProvider)
                      .recordAnswer(
                        exercise,
                        question,
                        isCorrect: isCorrect,
                        masterOnCorrect: mode == SessionMode.review,
                      ),
                  onFinished: (session, duration) => ref
                      .read(answerRecorderProvider)
                      .recordSession(
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
    this.initial,
    this.onProgress,
    this.onDiscard,
    this.leaveLabel,
    this.onAnswered,
    this.onFinished,
  });

  final List<Exercise> exercises;
  final VoidCallback onLeave;

  /// A session picked up where it stopped, or null for a fresh one.
  final QuizSession? initial;

  /// Called after every answer and every step, to save the position.
  final void Function(QuizSession session)? onProgress;

  /// Called when the user quits for good, so the saved position is dropped.
  final VoidCallback? onDiscard;

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
  late final QuizSession _session = widget.initial ?? QuizSession(widget.exercises);
  final Stopwatch _stopwatch = Stopwatch()..start();

  void _select(int index) {
    final session = _session;
    if (session.isCurrentAnswered) return;
    final question = session.question;
    setState(() => session.select(index));
    widget.onAnswered?.call(session.exercise, question, index == question.answerIndex);
    widget.onProgress?.call(session);
  }

  void _advance() {
    setState(_session.advance);
    if (_session.isFinished) {
      _stopwatch.stop();
      widget.onFinished?.call(_session, _stopwatch.elapsed);
    } else {
      widget.onProgress?.call(_session);
    }
  }

  // The system back button / gesture asks before leaving a session in progress.
  Future<void> _askLeave() async {
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quizLeaveTitle),
        content: Text(l10n.quizLeaveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.discard),
            child: Text(l10n.quizLeaveDiscard),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.save),
            child: Text(l10n.quizLeaveSave),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _LeaveChoice.stay),
            child: Text(l10n.quizLeaveStay),
          ),
        ],
      ),
    );
    if (choice == _LeaveChoice.discard) widget.onDiscard?.call();
    if (choice == _LeaveChoice.discard || choice == _LeaveChoice.save) widget.onLeave();
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
    return PopScope(
      canPop: session.answeredCount == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _askLeave();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.quizQuestionCounter(session.answeredCount + 1, total)),
                const SizedBox(height: 6),
                AnimatedProgressBar(value: session.answeredCount / total, height: 8),
              ],
            ),
          ),
          Expanded(
            child: ExercisePage(
              exercise: session.exercise,
              questionIndex: session.questionIndex,
              answers: {
                for (final q in session.exercise.questions)
                  if (session.answerFor(q) != null) q.id: session.answerFor(q)!,
              },
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
        ],
      ),
    );
  }
}

enum _LeaveChoice { stay, save, discard }

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
    final rate = session.correctCount / total;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.quizSummaryTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              BrandHeroCard(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (rate >= 0.7) const Positioned.fill(child: ConfettiBurst(spread: 150)),
                    Column(
                      children: [
                        ScoreGauge(
                          value: session.correctCount / total,
                          size: 140,
                          child: Text(
                            '${(session.correctCount * 100 / total).round()}%',
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.quizSummaryScore(session.correctCount, total),
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          switch (rate) {
                            >= 0.9 => l10n.summaryGreat,
                            >= 0.7 => l10n.summaryGood,
                            >= 0.5 => l10n.summaryOk,
                            _ => l10n.summaryKeep,
                          },
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(onPressed: onLeave, child: Text(leaveLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
