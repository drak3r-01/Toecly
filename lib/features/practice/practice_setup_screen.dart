import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/toeic_part.dart';
import '../../data/quiz/quiz_request.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';
import 'question_count_picker.dart';

/// Custom practice: pick the parts and the number of questions, then start a
/// session with immediate correction.
class PracticeSetupScreen extends ConsumerStatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  ConsumerState<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends ConsumerState<PracticeSetupScreen> {
  // Starts from the last configuration used.
  late final QuizRequest? _last = ref.read(lastPracticeProvider).load();
  late final Set<ToeicPart> _parts = {...(_last?.parts ?? ToeicPart.readingParts)};
  late int _count = _last?.questionCount ?? QuizRequest.defaultQuestionCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.navPractice, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(l10n.practiceDescription),
            const SizedBox(height: 24),
            Text(l10n.practicePartsLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final part in ToeicPart.readingParts)
                FilterChip(
                  label: Text(l10n.partTitle(part)),
                  selected: _parts.contains(part),
                  // At least one part stays selected.
                  onSelected: (on) => setState(() {
                    if (on) {
                      _parts.add(part);
                    } else if (_parts.length > 1) {
                      _parts.remove(part);
                    }
                  }),
                ),
            ]),
            const SizedBox(height: 24),
            Text(l10n.practiceCountLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            QuestionCountPicker(value: _count, onChanged: (count) => _count = count),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.practiceStart),
              onPressed: () {
                final request = QuizRequest(parts: _parts, questionCount: _count);
                ref.read(lastPracticeProvider).save(request);
                context.push(request.location);
              },
            ),
          ],
        ),
      ),
    );
  }
}
