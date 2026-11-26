import 'package:material_ui/material_ui.dart';

import '../../core/widgets/feature_placeholder.dart';
import '../../l10n/app_localizations.dart';

/// Review: replay only the questions previously missed. SKELETON: to be built.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FeaturePlaceholder(
      icon: Icons.replay,
      title: l10n.navReview,
      description: l10n.reviewDescription,
    );
  }
}
