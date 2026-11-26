import 'package:material_ui/material_ui.dart';

import '../../app/app_services.dart';
import '../../core/scoring/toeic_score_estimator.dart';
import '../../core/toeic_part.dart';
import '../../core/widgets/animated_progress_bar.dart';

/// Accueil : score estimé, taux de réussite par partie, reprise rapide.
/// SQUELETTE : branché sur les statistiques, mise en page à finaliser.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = AppScope.of(context).partStats;
    final readingParts = ToeicPart.readingParts;
    final theme = Theme.of(context);

    final answered = readingParts.fold(0, (sum, part) => sum + stats.answered(part));
    final correct = readingParts.fold(0, (sum, part) => sum + stats.correct(part));
    final readingRate = answered == 0 ? 0.0 : correct / answered;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Score estimé', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  answered == 0
                      ? '— / ${ToeicScoreEstimator.totalMax}'
                      : '${ToeicScoreEstimator.estimateTotalScore(readingRate)} / ${ToeicScoreEstimator.totalMax}',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                for (final part in readingParts) ...[
                  Text('Partie ${part.number} · ${part.label}'),
                  const SizedBox(height: 4),
                  AnimatedProgressBar(value: stats.successRate(part)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // TODO(dev): naviguer vers l'entraînement avec la dernière configuration.
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.play_arrow),
          label: const Text("Reprendre l'entraînement"),
        ),
      ],
    );
  }
}
