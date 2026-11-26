import 'package:material_ui/material_ui.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Révision : rejouer uniquement les questions précédemment ratées.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
        icon: Icons.replay,
        title: 'Révision des erreurs',
        description: 'Rejoue les questions que tu as ratées.',
      );
}
