import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/toeic_part.dart';
import '../../data/quiz/quiz_request.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';

/// Practice entry. For now only a quick start (10 random questions, per part
/// or mixed); the custom setup (parts, number of questions) comes next.
class PracticeSetupScreen extends StatelessWidget {
  const PracticeSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget start(String title, Iterable<ToeicPart> parts, IconData icon) => Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => context
                .push(QuizRequest(parts: parts, questionCount: QuizRequest.defaultQuestionCount).location),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.quickStartTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(l10n.quickStartHint),
        const SizedBox(height: 16),
        start(l10n.quickStartAllParts, ToeicPart.readingParts, Icons.shuffle),
        for (final part in ToeicPart.readingParts)
          start(l10n.partTitle(part), [part], Icons.edit_note),
      ],
    );
  }
}
