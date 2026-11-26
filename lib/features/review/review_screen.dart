import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../data/quiz/quiz_request.dart';
import '../../data/storage/session_record.dart';
import '../practice/question_count_picker.dart';
import '../quiz/quiz_screen.dart';

/// Review: replay the questions previously missed. A question leaves the list
/// as soon as it is answered right during a review.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  static const sessionPath = '/review/session';

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _count = QuizRequest.defaultQuestionCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Read again after each session: the list shrinks as questions are mastered.
    final missed = ref.read(missedQuestionsProvider).loadIds().length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(missed == 0 ? Icons.task_alt : Icons.replay,
                  size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l10n.navReview, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                missed == 0 ? l10n.reviewNothing : l10n.reviewMissedCount(missed),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              if (missed > 0) ...[
                const SizedBox(height: 24),
                Text(l10n.practiceCountLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                QuestionCountPicker(value: _count, onChanged: (count) => _count = count),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.practiceStart),
                  onPressed: () async {
                    await context.push('${ReviewScreen.sessionPath}?count=$_count');
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// A review session on the missed questions.
class ReviewSessionScreen extends ConsumerWidget {
  const ReviewSessionScreen({super.key, required this.questionCount});

  final int questionCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) => QuizSessionScreen(
        draw: ref.watch(reviewDrawProvider(questionCount)),
        mode: SessionMode.review,
        leaveTo: AppDestination.review,
        leaveLabel: AppLocalizations.of(context).quizBackToReview,
      );
}
