import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Temporary screen for features that are not built yet.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(description, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Chip(label: Text(AppLocalizations.of(context).comingSoon)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
