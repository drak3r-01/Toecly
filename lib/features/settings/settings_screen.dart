import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/settings/settings_providers.dart';
import '../../l10n/app_localizations.dart';

/// Settings: theme (light / dark / system) and language (system / English / French).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

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
                  icon: const Icon(Icons.brightness_auto)),
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode)),
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
          label: l10n.resetProgressLabel,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.resetProgressHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.resetProgressButton),
              onPressed: () => _confirmReset(context, ref),
            ),
          ]),
        ),
      ],
    );
  }
}

Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
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
  ref.read(dataRevisionProvider.notifier).bump(); // theme and language are kept
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(label), const SizedBox(height: 12), child],
          ),
        ),
      );
}
