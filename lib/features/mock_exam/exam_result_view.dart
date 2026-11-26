import 'package:material_ui/material_ui.dart';

import '../../core/scoring/toeic_score_estimator.dart';
import '../../core/toeic_part.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../data/exercises/models.dart';
import '../../data/quiz/exam_session.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';
import '../quiz/exercise_page.dart';
import '../quiz/question_card.dart';

/// Result of a submitted exam: score, per-part rates, and the correction of
/// every question (tap one to see it in its context, with the explanation).
class ExamResultView extends StatefulWidget {
  const ExamResultView({
    super.key,
    required this.session,
    required this.used,
    required this.onLeave,
    this.timeUp = false,
  });

  final ExamSession session;
  final Duration used;
  final VoidCallback onLeave;
  final bool timeUp;

  @override
  State<ExamResultView> createState() => _ExamResultViewState();
}

class _ExamResultViewState extends State<ExamResultView> {
  bool _mistakesOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = widget.session;
    final range = ToeicScoreEstimator.estimateReadingRange(session.successRate);
    final entries = [
      for (final e in session.entries)
        if (!_mistakesOnly || !session.isCorrect(e)) e,
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.timeUp)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.examTimeUp, style: TextStyle(color: theme.colorScheme.error)),
              ),
            Text(l10n.quizSummaryScore(session.correctCount, session.totalQuestions),
                style: theme.textTheme.displaySmall),
            const SizedBox(height: 4),
            Text('${l10n.estimatedScoreTitle}: ${l10n.estimatedScoreRange(range.min, range.max)}',
                style: theme.textTheme.titleMedium),
            Text('${l10n.estimatedTotalTitle}: ${l10n.estimatedTotalRange(range.doubled.min, range.doubled.max)}',
                style: theme.textTheme.titleMedium),
            Text(l10n.estimatedScoreDisclaimer, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(l10n.examTimeUsed(widget.used.inMinutes)),
            const SizedBox(height: 16),
            AnimatedProgressBar(value: session.successRate),
            const SizedBox(height: 16),
            Text(l10n.examByPart, style: theme.textTheme.titleMedium),
            for (final part in ToeicPart.readingParts)
              if (session.totalFor(part) > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(l10n.partTitle(part))),
                    Expanded(
                        flex: 2,
                        child: AnimatedProgressBar(
                            value: session.correctFor(part) / session.totalFor(part), height: 8)),
                    SizedBox(
                      width: 72,
                      child: Text('${session.correctFor(part)} / ${session.totalFor(part)}',
                          textAlign: TextAlign.end),
                    ),
                  ]),
                ),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              ChoiceChip(
                label: Text(l10n.examFilterAll),
                selected: !_mistakesOnly,
                onSelected: (_) => setState(() => _mistakesOnly = false),
              ),
              ChoiceChip(
                label: Text(l10n.examFilterMistakes),
                selected: _mistakesOnly,
                onSelected: (_) => setState(() => _mistakesOnly = true),
              ),
            ]),
            const SizedBox(height: 8),
            for (final entry in entries) _ResultTile(session: session, entry: entry),
            const SizedBox(height: 16),
            FilledButton(onPressed: widget.onLeave, child: Text(l10n.examBackToExam)),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.session, required this.entry});

  final ExamSession session;
  final ExamEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = FeedbackColors.of(context);
    final question = entry.question;
    final answer = session.answerFor(question);
    final correct = session.isCorrect(entry);
    final number = session.entries.indexOf(entry) + 1;

    final prompt = entry.exercise.part == ToeicPart.part6
        ? l10n.quizBlankLabel(entry.questionIndex + 1)
        : question.prompt;

    return Card(
      child: ListTile(
        leading: Icon(
          answer == null ? Icons.remove_circle_outline : (correct ? Icons.check_circle : Icons.cancel),
          color: answer == null ? null : (correct ? colors.correct : colors.incorrect),
        ),
        title: Text('$number. $prompt', maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(answer == null
            ? l10n.examNotAnswered
            : correct
                ? question.choices[answer]
                : '${question.choices[answer]}  →  ${question.choices[question.answerIndex]}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ExerciseReviewScreen(
            exercise: entry.exercise,
            initialQuestion: entry.questionIndex,
            answers: session.answers,
          ),
        )),
      ),
    );
  }
}

/// An exercise with the correction of each of its questions, read-only.
class ExerciseReviewScreen extends StatefulWidget {
  const ExerciseReviewScreen({
    super.key,
    required this.exercise,
    required this.answers,
    this.initialQuestion = 0,
  });

  final Exercise exercise;
  final Map<String, int> answers;
  final int initialQuestion;

  @override
  State<ExerciseReviewScreen> createState() => _ExerciseReviewScreenState();
}

class _ExerciseReviewScreenState extends State<ExerciseReviewScreen> {
  late int _index = widget.initialQuestion;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Scaffold(
      appBar: AppBar(
        title: exercise.questions.length < 2
            ? null
            : SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  for (var i = 0; i < exercise.questions.length; i++)
                    ButtonSegment(value: i, label: Text('${i + 1}')),
                ],
                selected: {_index},
                onSelectionChanged: (s) => setState(() => _index = s.single),
              ),
      ),
      body: SafeArea(
        child: ExercisePage(
          exercise: exercise,
          questionIndex: _index,
          answers: widget.answers,
          revealed: true,
          onSelect: (_) {},
        ),
      ),
    );
  }
}
