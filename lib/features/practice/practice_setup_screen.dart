import 'package:material_ui/material_ui.dart';

import '../../core/widgets/feature_placeholder.dart';
import '../../l10n/app_localizations.dart';

/// Custom practice: pick the parts and the number of questions, then a session
/// with immediate correction. SKELETON: to be built.
class PracticeSetupScreen extends StatelessWidget {
  const PracticeSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FeaturePlaceholder(
      icon: Icons.fitness_center,
      title: l10n.navPractice,
      description: l10n.practiceDescription,
    );
  }
}
