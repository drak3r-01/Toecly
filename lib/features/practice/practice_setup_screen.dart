import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/theme/brand_colors.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/toeic_part.dart';
import '../../data/quiz/quiz_request.dart';
import '../../l10n/app_localizations.dart';
import 'part_choice_card.dart';
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
    final counts = ref.watch(questionCountsProvider).value;
    final selectedTotal = counts == null
        ? null
        : _parts.fold<int>(0, (sum, part) => sum + (counts[part] ?? 0));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.navPractice, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(l10n.practiceDescription),
                    const SizedBox(height: 24),
                    Text(l10n.practicePartsLabel, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    for (final (i, part) in ToeicPart.readingParts.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FadeSlideIn(
                          delay: Duration(milliseconds: 80 * i),
                          child: PartChoiceCard(
                            part: part,
                            accent: BrandColors.partAccents[i % BrandColors.partAccents.length],
                            selected: _parts.contains(part),
                            available: counts?[part],
                            // At least one part stays selected.
                            onTap: () => setState(() {
                              if (!_parts.add(part) && _parts.length > 1) {
                                _parts.remove(part);
                              }
                            }),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(l10n.practiceCountLabel, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    QuestionCountPicker(value: _count, onChanged: (count) => _count = count),
                    if (selectedTotal != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.practiceSelectionAvailable(selectedTotal),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.practiceStart),
                  onPressed: () {
                    final request = QuizRequest(parts: _parts, questionCount: _count);
                    ref.read(lastPracticeProvider).save(request);
                    context.push(request.location);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
