import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/haptics.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../core/widgets/brand_hero_card.dart';
import '../../data/words/word_card.dart';
import '../../l10n/app_localizations.dart';

/// Flashcards on the bundled words: tap to flip, then "Again" (back of the queue) or
/// "I know it" (saved, never shown again until a restart).
class WordCardsScreen extends ConsumerWidget {
  const WordCardsScreen({super.key});

  static const path = '/words';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cards = ref.watch(wordCardsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wordsTitle)),
      body: SafeArea(
        child: cards.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.quizLoadError)),
          data: (cards) =>
              cards.isEmpty ? Center(child: Text(l10n.wordsEmpty)) : _Deck(cards: cards),
        ),
      ),
    );
  }
}

class _Deck extends ConsumerStatefulWidget {
  const _Deck({required this.cards});

  final List<WordCard> cards;

  @override
  ConsumerState<_Deck> createState() => _DeckState();
}

class _DeckState extends ConsumerState<_Deck> {
  late Set<String> _known = ref.read(wordProgressProvider).loadKnown();
  late List<WordCard> _queue = _unknownShuffled();
  bool _flipped = false;

  List<WordCard> _unknownShuffled() => [
    for (final c in widget.cards)
      if (!_known.contains(c.id)) c,
  ]..shuffle();

  void _next({required bool knows}) {
    Haptics.tap();
    final card = _queue.first;
    setState(() {
      _queue = [..._queue.skip(1), if (!knows) card];
      if (knows) _known = {..._known, card.id};
      _flipped = false;
    });
    if (knows) ref.read(wordProgressProvider).markKnown(card.id);
  }

  Future<void> _restart() async {
    await ref.read(wordProgressProvider).clear();
    setState(() {
      _known = {};
      _queue = _unknownShuffled();
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final total = widget.cards.length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.wordsProgress(_known.length, total)),
              const SizedBox(height: 6),
              AnimatedProgressBar(value: _known.length / total, height: 8),
              const SizedBox(height: 16),
              if (_queue.isEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.wordsDone,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: _restart, child: Text(l10n.wordsRestart)),
                    ],
                  ),
                )
              else ...[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _flipped = !_flipped),
                    child: _FlipCard(
                      flipped: _flipped,
                      front: _Front(card: _queue.first, hint: l10n.wordsTapToFlip),
                      back: _Back(card: _queue.first),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _flipped ? () => _next(knows: false) : null,
                        child: Text(l10n.wordsAgain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _flipped ? () => _next(knows: true) : null,
                        child: Text(l10n.wordsKnown),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Turns around its vertical axis between [front] and [back].
class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.flipped, required this.front, required this.back});

  final bool flipped;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: flipped ? math.pi : 0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      builder: (context, angle, _) {
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi), // the back must not be mirrored
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

class _Front extends StatelessWidget {
  const _Front({required this.card, required this.hint});

  final WordCard card;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BrandHeroCard(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(label: Text(card.partOfSpeech.name)),
            const SizedBox(height: 16),
            Text(card.word, textAlign: TextAlign.center, style: theme.textTheme.displaySmall),
            const SizedBox(height: 24),
            Text(hint, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.card});

  final WordCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BrandHeroCard(
      child: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.word, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(card.definition, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text(l10n.wordsExample, style: theme.textTheme.labelLarge),
              Text(card.example, style: theme.textTheme.bodyLarge),
              if (card.fr != null) ...[
                const SizedBox(height: 16),
                Text(l10n.wordsFrench, style: theme.textTheme.labelLarge),
                Text(card.fr!, style: theme.textTheme.bodyLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
