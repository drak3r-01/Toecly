import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'word_card.dart';

const wordsAssetFolder = 'assets/words/';

/// Reads every word lot bundled in the app. Invalid cards and repeated ids are dropped.
Future<List<WordCard>> loadBundledWords({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final paths =
      manifest
          .listAssets()
          .where((p) => p.startsWith(wordsAssetFolder) && p.endsWith('.json'))
          .toList()
        ..sort();
  final seen = <String>{};
  final cards = <WordCard>[];
  for (final path in paths) {
    final result = parseWordLot(await assets.loadString(path));
    if (result.errors.isNotEmpty) {
      debugPrint('Skipping invalid word cards in $path: ${result.errors.join('; ')}');
    }
    for (final card in result.cards) {
      if (seen.add(card.id)) cards.add(card);
    }
  }
  return cards;
}
