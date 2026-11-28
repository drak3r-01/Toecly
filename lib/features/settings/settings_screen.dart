import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/settings/settings_providers.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../data/storage/daily_progress_repository.dart';
import '../../l10n/app_localizations.dart';

/// Settings: theme (light / dark / system) and language (system / English / French).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final haptics = ref.watch(hapticsProvider);
    final textSize = ref.watch(textSizeProvider);
    ref.watch(dataRevisionProvider); // the goal is stored outside a notifier
    final daily = ref.watch(dailyProgressProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.settingsTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        _SettingCard(
          label: l10n.themeLabel,
          child: SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l10n.themeAuto),
                icon: const Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l10n.themeLight),
                icon: const Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l10n.themeDark),
                icon: const Icon(Icons.dark_mode),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) =>
                ref.read(themeModeProvider.notifier).set(selection.first),
          ),
        ),
        const SizedBox(height: 16),
        _SettingCard(
          label: l10n.languageLabel,
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'system', label: Text(l10n.languageAuto)),
              ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ButtonSegment(value: 'fr', label: Text(l10n.languageFrench)),
            ],
            selected: {locale?.languageCode ?? 'system'},
            onSelectionChanged: (selection) => ref
                .read(localeProvider.notifier)
                .set(selection.first == 'system' ? null : Locale(selection.first)),
          ),
        ),
        const SizedBox(height: 16),
        _SettingCard(
          label: l10n.dailyGoalLabel,
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final goal in DailyProgressRepository.goalChoices)
                ButtonSegment(value: goal, label: Text('$goal')),
            ],
            selected: {daily.goal},
            onSelectionChanged: (selection) async {
              await daily.setGoal(selection.first);
              ref.read(dataRevisionProvider.notifier).bump();
            },
          ),
        ),
        const SizedBox(height: 16),
        _SettingCard(
          label: l10n.textSizeLabel,
          child: SegmentedButton<TextSize>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: TextSize.small, label: Text(l10n.textSizeSmall)),
              ButtonSegment(value: TextSize.normal, label: Text(l10n.textSizeNormal)),
              ButtonSegment(value: TextSize.large, label: Text(l10n.textSizeLarge)),
              ButtonSegment(value: TextSize.huge, label: Text(l10n.textSizeHuge)),
            ],
            selected: {textSize},
            onSelectionChanged: (selection) =>
                ref.read(textSizeProvider.notifier).set(selection.first),
          ),
        ),
        const SizedBox(height: 16),
        _SettingCard(
          label: l10n.hapticsLabel,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.hapticsHint),
            value: haptics,
            onChanged: ref.read(hapticsProvider.notifier).set,
          ),
        ),
        const SizedBox(height: 16),
        _SettingCard(
          label: l10n.resetProgressLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.resetProgressHint, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.resetProgressButton),
                onPressed: () => _confirmReset(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.resetProgressTitle),
          content: Text(l10n.resetProgressMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.resetProgressCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.resetProgressConfirm),
            ),
          ],
        ),
      ) ??
      false;
  if (!confirmed) return;
  await ref.read(partStatsProvider).clear();
  await ref.read(missedQuestionsProvider).clear();
  await ref.read(sessionHistoryProvider).clear();
  await ref.read(lastPracticeProvider).clear();
  await ref.read(seenQuestionsProvider).clear();
  await ref.read(examProgressProvider).clear();
  await ref.read(dailyProgressProvider).clear();
  ref.read(dataRevisionProvider.notifier).bump(); // theme and language are kept
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeSlideIn(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ),
  );
}
