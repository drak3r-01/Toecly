import 'package:material_ui/material_ui.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Examen blanc chronométré (partie Reading) avec bilan final.
class MockExamScreen extends StatelessWidget {
  const MockExamScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
        icon: Icons.timer,
        title: 'Examen blanc',
        description: 'Simulation chronométrée de la partie Reading.',
      );
}
