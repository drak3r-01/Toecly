import 'package:material_ui/material_ui.dart';

import '../../core/toeic_part.dart';
import '../../data/exercises/models.dart';
import '../../l10n/app_localizations.dart';
import '../exercise/document_view.dart';
import 'question_card.dart';

/// One exercise on screen: the question alone (Part 5), or the document(s) with
/// the current question beside them (wide) or above them (narrow).
class ExercisePage extends StatelessWidget {
  const ExercisePage({
    super.key,
    required this.exercise,
    required this.questionIndex,
    required this.answers,
    required this.revealed,
    required this.onSelect,
  });

  final Exercise exercise;
  final int questionIndex;

  /// Choice already picked per question id.
  final Map<String, int> answers;
  final bool revealed;
  final ValueChanged<int> onSelect;

  /// Width from which documents and question are shown side by side.
  static const double wideMinWidth = 1000;

  Question get _question => exercise.questions[questionIndex];

  @override
  Widget build(BuildContext context) {
    final questionPane = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: SingleChildScrollView(
        key: ValueKey('${exercise.id}/$questionIndex'),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: QuestionCard(
              question: _question,
              prompt: _prompt(context),
              selectedIndex: answers[_question.id],
              revealed: revealed,
              onSelect: onSelect,
            ),
          ),
        ),
      ),
    );

    if (exercise.documents.isEmpty) return questionPane;

    final documents = Padding(
      padding: const EdgeInsets.all(12),
      child: DocumentsPane(
        key: ValueKey(exercise.id),
        documents: exercise.documents,
        spanBuilder: exercise.part == ToeicPart.part6 ? (base) => _blankedText(context, base) : null,
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= wideMinWidth) {
        return Row(children: [
          Expanded(flex: 3, child: documents),
          const VerticalDivider(width: 1),
          Expanded(flex: 2, child: questionPane),
        ]);
      }
      return Column(children: [
        Expanded(flex: 5, child: documents),
        const Divider(height: 1),
        Expanded(flex: 6, child: questionPane),
      ]);
    });
  }

  Widget _prompt(BuildContext context) => switch (exercise.part) {
        ToeicPart.part6 => Text(AppLocalizations.of(context).quizBlankLabel(questionIndex + 1)),
        _ => Text(_question.prompt),
      };

  /// Part 6 text with `[n]` replaced by the blank to fill: the current one is
  /// highlighted, answered ones show the right choice.
  TextSpan _blankedText(BuildContext context, TextStyle? base) {
    final scheme = Theme.of(context).colorScheme;
    final colors = FeedbackColors.of(context);
    final text = exercise.documents.single.text;
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in RegExp(r'\[(\d)\]').allMatches(text)) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
      cursor = match.end;
      final blank = int.parse(match.group(1)!) - 1;
      if (blank >= exercise.questions.length) {
        spans.add(TextSpan(text: match.group(0)));
        continue;
      }
      final question = exercise.questions[blank];
      final isCurrent = blank == questionIndex;
      final answered = answers.containsKey(question.id) && (!isCurrent || revealed);
      spans.add(TextSpan(
        text: answered ? ' ${question.choices[question.answerIndex]} ' : ' (${blank + 1}) ______ ',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: answered ? colors.correct : (isCurrent ? scheme.primary : null),
          backgroundColor: isCurrent ? scheme.primaryContainer : null,
        ),
      ));
    }
    spans.add(TextSpan(text: text.substring(cursor)));
    return TextSpan(style: base, children: spans);
  }
}
