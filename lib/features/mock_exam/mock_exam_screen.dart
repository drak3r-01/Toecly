import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/exercises/mock_exam_blueprint.dart';
import '../../l10n/app_localizations.dart';
import 'exam_screen.dart';

/// Entry of the mock exam: what it is, and a button to start it.
class MockExamScreen extends StatelessWidget {
  const MockExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.timer, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l10n.navMockExam, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                l10n.mockExamDescription(
                  MockExamBlueprint.officialQuestionCount,
                  MockExamBlueprint.official.duration.inMinutes,
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.examStart),
                onPressed: () => context.push(ExamScreen.path),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
