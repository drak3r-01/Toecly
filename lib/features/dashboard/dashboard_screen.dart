import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../core/scoring/toeic_score_estimator.dart';
import '../../core/toeic_part.dart';
import '../../app/theme/brand_colors.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../core/widgets/brand_hero_card.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/score_gauge.dart';
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
            FadeSlideIn(
              child: Text(l10n.estimatedScoreTitle, style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: _ScoreHero(range: range, answered: answered, sessions: sessions),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: FilledButton.icon(
                onPressed: () => last == null
                    ? context.go(AppDestination.practice.path)
                    : context.push(last.location),
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.resumePractice),
              ),
            ),
            const SizedBox(height: 16),
            for (final (i, part) in readingParts.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FadeSlideIn(
                  delay: Duration(milliseconds: 240 + 80 * i),
                  child: _PartCard(
                    part: part,
                    stats: stats,
                    accent: BrandColors.partAccents[i % 3],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Success rate of a part, then the rate of each category already answered.
class _PartCard extends StatelessWidget {
  const _PartCard({required this.part, required this.stats, required this.accent});

  final Color accent;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RateRow(
              label: l10n.partTitle(part),
              count: total,
              style: theme.textTheme.titleMedium,
              height: 12,
              color: accent,
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
                  color: accent,
                ),
              ),
          ],
        ),
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
    required this.color,
  });

  final Color color;

  final String label;
  final AnswerCount count;
  final TextStyle? style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final percent = (count.rate * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(AppLocalizations.of(context).successRatePercent(percent), style: style),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedProgressBar(value: count.rate, height: height, color: color),
      ],
    );
  }
}

/// Gradient hero card: estimated score range with an animated gauge.
class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.range, required this.answered, required this.sessions});

  final ScoreRange? range;
  final int answered;
  final int sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    TextStyle? white(TextStyle? style) => style?.copyWith(color: Colors.white);
    final middle = range == null ? 0.0 : (range!.min + range!.max) / 2 / 495;

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            range == null
                ? l10n.estimatedScoreEmpty
                : l10n.estimatedScoreRange(range!.min, range!.max),
            key: ValueKey(range),
            style: white(theme.textTheme.displaySmall),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.estimatedTotalTitle, style: white(theme.textTheme.labelLarge)),
        Text(
          range == null
              ? l10n.estimatedTotalEmpty
              : l10n.estimatedTotalRange(range!.doubled.min, range!.doubled.max),
          style: white(theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.estimatedScoreDisclaimer,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HeroChip(icon: Icons.check_circle_outline, label: l10n.dashboardAnswered(answered)),
            _HeroChip(icon: Icons.history, label: l10n.dashboardSessions(sessions)),
          ],
        ),
      ],
    );

    return BrandHeroCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gauge = ScoreGauge(value: middle, size: 96);
          if (constraints.maxWidth < 440) {
            return Column(
              children: [
                Center(child: gauge),
                const SizedBox(height: 16),
                texts,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: texts),
              const SizedBox(width: 24),
              gauge,
            ],
          );
        },
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
