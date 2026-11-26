import 'package:material_ui/material_ui.dart';

import '../../core/widgets/feature_placeholder.dart';
import '../../data/exercises/mock_exam_blueprint.dart';
import '../../l10n/app_localizations.dart';

/// Timed mock exam (Reading format) with the correction at the end.
/// SKELETON: to be built; the draw is `ExerciseRepository.drawMockExam`.
class MockExamScreen extends StatelessWidget {
  const MockExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FeaturePlaceholder(
      icon: Icons.timer,
      title: l10n.navMockExam,
      description: l10n.mockExamDescription(
        MockExamBlueprint.officialQuestionCount,
        MockExamBlueprint.official.duration.inMinutes,
      ),
    );
  }
}
