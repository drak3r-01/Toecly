import 'package:material_ui/material_ui.dart';

import '../../core/toeic_part.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';

/// A selectable card for one part: number badge, name, short description and
/// how many questions are available. [available] is null while counting.
class PartChoiceCard extends StatelessWidget {
  const PartChoiceCard({
    super.key,
    required this.part,
    required this.accent,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final ToeicPart part;
  final Color accent;
  final bool selected;
  final int? available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.14) : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? accent : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : accent.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    '${part.number}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.partTitle(part), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(l10n.partDescription(part), style: theme.textTheme.bodySmall),
                      if (available != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.questionsAvailable(available!),
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    key: ValueKey(selected),
                    color: selected ? accent : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
