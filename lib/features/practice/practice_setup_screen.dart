import 'package:material_ui/material_ui.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Entraînement personnalisé : choix des parties (5-7), nombre de questions
/// (10/20/50/100), puis session avec correction immédiate.
class PracticeSetupScreen extends StatelessWidget {
  const PracticeSetupScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
        icon: Icons.fitness_center,
        title: 'Entraînement',
        description: 'Choisis tes parties et le nombre de questions.',
      );
}
