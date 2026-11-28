import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/haptics.dart';
import '../../core/widgets/confetti_burst.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../data/exercises/models.dart';
import '../../l10n/app_localizations.dart';

/// Green/red feedback colors, readable in light and dark themes.
class FeedbackColors {
  const FeedbackColors._(this.correct, this.incorrect);

  final Color correct;
  final Color incorrect;

  static FeedbackColors of(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const FeedbackColors._(Color(0xFF3DDC8B), Color(0xFFFF6B5A))
      : const FeedbackColors._(Color(0xFF0B7A46), Color(0xFFD13A24));
}

/// One question: its prompt, four choices and, once [revealed], the animated
/// green/red feedback and the unfolding explanation. Used for every part.
/// In exam mode (later) the same card is used with [revealed] kept false.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.prompt,
    required this.selectedIndex,
    required this.revealed,
    required this.onSelect,
  });

  final Question question;

  /// Part 5: the sentence. Part 6: "Blank 2". Part 7: the question.
  final Widget prompt;
  final int? selectedIndex;
  final bool revealed;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = FeedbackColors.of(context);
    final isCorrect = selectedIndex == question.answerIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle.merge(style: theme.textTheme.titleMedium, child: prompt),
        const SizedBox(height: 16),
        for (var i = 0; i < question.choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FadeSlideIn(
              delay: Duration(milliseconds: 60 * i),
              child: _ChoiceTile(
                letter: String.fromCharCode(65 + i),
                text: question.choices[i],
                state: _stateOf(i),
                celebrate: selectedIndex == question.answerIndex,
                onTap: revealed
                    ? null
                    : () {
                        Haptics.tap();
                        onSelect(i);
                      },
              ),
            ),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !revealed
              ? const SizedBox(width: double.infinity)
              : Card(
                  margin: const EdgeInsets.only(top: 6),
                  color: (isCorrect ? colors.correct : colors.incorrect).withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? colors.correct : colors.incorrect,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect ? l10n.quizCorrect : l10n.quizIncorrect,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.quizExplanation, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 4),
                        // Explanations are in English whatever the UI language.
                        Text(question.explanation, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  _ChoiceState _stateOf(int index) {
    if (!revealed) return index == selectedIndex ? _ChoiceState.selected : _ChoiceState.idle;
    if (index == question.answerIndex) return _ChoiceState.correct;
    if (index == selectedIndex) return _ChoiceState.wrong;
    return _ChoiceState.dimmed;
  }
}

enum _ChoiceState { idle, selected, correct, wrong, dimmed }

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.celebrate,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _ChoiceState state;

  /// The user picked this (right) answer: confetti on top of the pop.
  final bool celebrate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = FeedbackColors.of(context);
    final accent = switch (state) {
      _ChoiceState.correct => colors.correct,
      _ChoiceState.wrong => colors.incorrect,
      _ChoiceState.selected => scheme.primary,
      _ => scheme.outlineVariant,
    };
    final filled = state == _ChoiceState.correct || state == _ChoiceState.wrong;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: state == _ChoiceState.dimmed ? 0.55 : 1,
      child: _Reaction(
        state: state,
        celebrate: celebrate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: filled ? accent.withValues(alpha: 0.15) : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accent,
              width: filled || state == _ChoiceState.selected ? 2 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.16),
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(fontWeight: FontWeight.w800, color: accent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(text)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: switch (state) {
                        _ChoiceState.correct => Icon(
                          Icons.check_circle,
                          key: const ValueKey('ok'),
                          color: accent,
                        ),
                        _ChoiceState.wrong => Icon(
                          Icons.cancel,
                          key: const ValueKey('ko'),
                          color: accent,
                        ),
                        _ => const SizedBox(key: ValueKey('none'), width: 24),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reaction when a choice is revealed: the right answer pops (with confetti if
/// the user picked it), the wrong pick shakes. Only plays on the change itself.
class _Reaction extends StatefulWidget {
  const _Reaction({required this.state, required this.celebrate, required this.child});

  final _ChoiceState state;
  final bool celebrate;
  final Widget child;

  @override
  State<_Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<_Reaction> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  bool _confetti = false;

  @override
  void didUpdateWidget(_Reaction old) {
    super.didUpdateWidget(old);
    if (old.state == widget.state) return;
    if (widget.state == _ChoiceState.correct) {
      if (widget.celebrate) Haptics.success();
      _confetti = widget.celebrate;
      _controller.forward(from: 0);
    } else if (widget.state == _ChoiceState.wrong) {
      Haptics.error();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            final t = _controller.value;
            return switch (state) {
              _ChoiceState.correct => Transform.scale(
                scale: 1 + 0.04 * math.sin(t * math.pi),
                child: child,
              ),
              _ChoiceState.wrong => Transform.translate(
                offset: Offset(math.sin(t * math.pi * 4) * 8 * (1 - t), 0),
                child: child,
              ),
              _ => child!,
            };
          },
        ),
        if (_confetti && state == _ChoiceState.correct)
          const Positioned.fill(child: ConfettiBurst(particles: 16, spread: 60)),
      ],
    );
  }
}
