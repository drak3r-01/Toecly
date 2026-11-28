import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/word_progress_repository.dart';
import 'package:toecly/data/words/word_card.dart';

void main() {
  const valid =
      '{"id":"w-001","word":"allocate","partOfSpeech":"verb","definition":"to give","example":"We allocate funds.","fr":"allouer"}';

  test('parses a valid card, with the optional French translation', () {
    final result = parseWordLot('[$valid]');
    expect(result.errors, isEmpty);
    expect(result.cards.single.word, 'allocate');
    expect(result.cards.single.partOfSpeech, PartOfSpeech.verb);
    expect(result.cards.single.fr, 'allouer');
  });

  test('reports invalid cards and keeps the valid ones', () {
    final result = parseWordLot(
      '[$valid, {"id":"bad","word":"x","partOfSpeech":"verbish","definition":"","example":"e"}]',
    );
    expect(result.cards, hasLength(1));
    expect(result.errors.single, allOf(contains('bad'), contains('partOfSpeech')));
    expect(parseWordLot('{}').errors, isNotEmpty);
    expect(parseWordLot('nope').errors, isNotEmpty);
  });

  test('detects repeated ids and words', () {
    final cards = parseWordLot('[$valid, $valid]').cards;
    expect(findDuplicateWords(cards), hasLength(2));
  });

  test('the bundled lots are valid, with unique ids and words', () {
    final cards = <WordCard>[];
    for (final file in Directory('assets/words').listSync().whereType<File>()) {
      if (!file.path.endsWith('.json')) continue;
      final result = parseWordLot(file.readAsStringSync());
      expect(result.errors, isEmpty, reason: file.path);
      cards.addAll(result.cards);
    }
    expect(cards.length, greaterThanOrEqualTo(50));
    expect(findDuplicateWords(cards), isEmpty);
  });

  test('known words are remembered and can be cleared', () async {
    final repository = WordProgressRepository(InMemoryStore());
    await repository.markKnown('w-001');
    await repository.markKnown('w-001');
    await repository.markKnown('w-002');
    expect(repository.loadKnown(), {'w-001', 'w-002'});
    await repository.clear();
    expect(repository.loadKnown(), isEmpty);
  });
}
