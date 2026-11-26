import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../core/scoring/toeic_score_estimator.dart';
import '../../core/toeic_part.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../data/exercises/models.dart';
import '../../data/storage/part_stats_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';

/// Home: estimated Reading score, success rate per part and per question
/// category, and a button to resume the last practice.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataRevisionProvider); // re-read the statistics after each session
    final stats = ref.watch(partStatsProvider);
    final sessions = ref.watch(sessionHistoryProvider).loadAll().length;
    final last = ref.watch(lastPracticeProvider).load();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final readingParts = ToeicPart.readingParts;

    final totals = [for (final part in readingParts) stats.forPart(part)];
    final answered = totals.fold(0, (sum, c) => sum + c.answered);
    final correct = totals.fold(0, (sum, c) => sum + c.correct);
    final range = answered == 0
        ? null
        : ToeicScoreEstimator.estimateReadingRange(correct / answered);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        range == null
                            ? l10n.estimatedScoreEmpty
                            : l10n.estimatedScoreRange(range.min, range.max),
                        key: ValueKey(range),
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.estimatedScoreDisclaimer, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, children: [
                      Chip(
                        avatar: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(l10n.dashboardAnswered(answered)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.history, size: 18),
                        label: Text(l10n.dashboardSessions(sessions)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => last == null
                  ? context.go(AppDestination.practice.path)
                  : context.push(last.location),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.resumePractice),
            ),
            const SizedBox(height: 16),
            for (final part in readingParts)
              _PartCard(part: part, stats: stats),
          ],
        ),
      ),
    );
  }
}

/// Success rate of a part, then the rate of each category already answered.
class _PartCard extends StatelessWidget {
  const _PartCard({required this.part, required this.stats});

  final ToeicPart part;
  final PartStatsRepository stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final total = stats.forPart(part);
    final categories = [
      for (final category in QuestionCategory.allowedByPart[part] ?? const <QuestionCategory>{})
        if (stats.forCategory(part, category).answered > 0) category,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _RateRow(
            label: l10n.partTitle(part),
            count: total,
            style: theme.textTheme.titleMedium,
            height: 12,
          ),
          if (categories.isNotEmpty) const SizedBox(height: 8),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _RateRow(
                label: l10n.categoryName(category),
                count: stats.forCategory(part, category),
                style: theme.textTheme.bodyMedium,
                height: 6,
              ),
            ),
        ]),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.label,
    required this.count,
    required this.style,
    required this.height,
  });

  final String label;
  final AnswerCount count;
  final TextStyle? style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final percent = (count.rate * 100).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: style)),
        Text(AppLocalizations.of(context).successRatePercent(percent), style: style),
      ]),
      const SizedBox(height: 4),
      AnimatedProgressBar(value: count.rate, height: height),
    ]);
  }
}
