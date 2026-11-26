import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../data/exercises/models.dart';
import '../../data/quiz/quiz_request.dart';
import '../../data/quiz/quiz_session.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_page.dart';

/// Draws the exercises for [request], then runs the session with immediate correction.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.request});

  final QuizRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draw = ref.watch(quizDrawProvider(request));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.quizClose,
          onPressed: () => _leave(context),
        ),
      ),
      body: SafeArea(
        child: draw.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(l10n.quizLoadError)),
          data: (exercises) => exercises.isEmpty
              ? Center(child: Text(l10n.quizEmpty))
              : QuizView(exercises: exercises, onLeave: () => _leave(context)),
        ),
      ),
    );
  }

  static void _leave(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(AppDestination.practice.path);
}

/// The running session. Owns a [QuizSession] and rebuilds on each step.
class QuizView extends StatefulWidget {
  const QuizView({super.key, required this.exercises, required this.onLeave});

  final List<Exercise> exercises;
  final VoidCallback onLeave;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late final QuizSession _session = QuizSession(widget.exercises);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = _session;
    if (session.isFinished) return _Summary(session: session, onLeave: widget.onLeave);

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
          onSelect: (index) => setState(() => session.select(index)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: session.isCurrentAnswered ? () => setState(session.advance) : null,
            child: Text(session.isLastQuestion ? l10n.quizFinish : l10n.quizNext),
          ),
        ),
      ),
    ]);
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.session, required this.onLeave});

  final QuizSession session;
  final VoidCallback onLeave;

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
            Text(l10n.quizSummaryScore(session.correctCount, total),
                style: theme.textTheme.displaySmall),
            const SizedBox(height: 16),
            AnimatedProgressBar(value: session.correctCount / total),
            const SizedBox(height: 32),
            FilledButton(onPressed: onLeave, child: Text(l10n.quizBackToPractice)),
          ]),
        ),
      ),
    );
  }
}
