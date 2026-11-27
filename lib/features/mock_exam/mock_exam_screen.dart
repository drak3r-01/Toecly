import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme/brand_colors.dart';
import '../../core/toeic_part.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../data/exercises/mock_exam_blueprint.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';
import 'exam_screen.dart';

/// Entry of the mock exam: what it is, a button to start it, and how many
/// questions are available per part.
class MockExamScreen extends ConsumerWidget {
  const MockExamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final counts = ref.watch(questionCountsProvider).value;
    final largest = counts == null || counts.isEmpty
        ? 0
        : counts.values.reduce((a, b) => a > b ? a : b);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FadeSlideIn(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.timer, size: 36, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.navMockExam, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        l10n.mockExamDescription(
                          MockExamBlueprint.officialQuestionCount,
                          MockExamBlueprint.official.duration.inMinutes,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.examStart),
                        onPressed: () => context.push(ExamScreen.path),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (counts != null) ...[
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.questionBankTitle, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        for (final (i, part) in ToeicPart.readingParts.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(l10n.partTitle(part))),
                                    Text(
                                      l10n.questionsAvailable(counts[part] ?? 0),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                AnimatedProgressBar(
                                  value: largest == 0 ? 0 : (counts[part] ?? 0) / largest,
                                  height: 8,
                                  color:
                                      BrandColors.partAccents[i % BrandColors.partAccents.length],
                                ),
                              ],
                            ),
                          ),
                        Text(l10n.questionBankHint, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
