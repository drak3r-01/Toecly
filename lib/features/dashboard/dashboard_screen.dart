import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/scoring/toeic_score_estimator.dart';
import '../../core/toeic_part.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../data/exercises/models.dart';
import '../../data/storage/part_stats_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';

/// Home: estimated score range, success rate per part and per question category.
/// SKELETON: wired to the statistics, layout to be finalized.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(partStatsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final readingParts = ToeicPart.readingParts;

    final totals = [for (final part in readingParts) stats.forPart(part)];
    final answered = totals.fold(0, (sum, c) => sum + c.answered);
    final correct = totals.fold(0, (sum, c) => sum + c.correct);
    final range = answered == 0
        ? null
        : ToeicScoreEstimator.estimateReadingRange(correct / answered);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.estimatedScoreTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  range == null
                      ? l10n.estimatedScoreEmpty
                      : l10n.estimatedScoreRange(range.min, range.max),
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(l10n.estimatedScoreDisclaimer, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                for (final part in readingParts) ...[
                  Text(l10n.partTitle(part)),
                  const SizedBox(height: 4),
                  AnimatedProgressBar(value: stats.forPart(part).rate),
                  _CategoryRates(part: part, stats: stats),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // TODO(dev): navigate to practice with the last configuration.
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.resumePractice),
        ),
      ],
    );
  }
}

/// "Grammar 70 % · Vocabulary 45 %" for the categories already answered in [part].
class _CategoryRates extends StatelessWidget {
  const _CategoryRates({required this.part, required this.stats});

  final ToeicPart part;
  final PartStatsRepository stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <String>[];
    for (final category in QuestionCategory.allowedByPart[part] ?? const <QuestionCategory>{}) {
      final count = stats.forCategory(part, category);
      if (count.answered > 0) {
        entries.add('${l10n.categoryName(category)} '
            '${l10n.successRatePercent((count.rate * 100).round())}');
      }
    }
    if (entries.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(entries.join(' · '), style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
