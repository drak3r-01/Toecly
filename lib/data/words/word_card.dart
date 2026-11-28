import 'dart:convert';

enum PartOfSpeech { noun, verb, adjective, adverb, preposition, conjunction, phrase }

/// One flashcard: a word, its meaning and an example sentence.
class WordCard {
  const WordCard({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    this.fr,
  });

  final String id;
  final String word;
  final PartOfSpeech partOfSpeech;
  final String definition;
  final String example;

  /// French translation, when the lot provides one.
  final String? fr;
}

typedef WordLotResult = ({List<WordCard> cards, List<String> errors});

/// Parses one lot (a JSON list of cards). Invalid cards are reported in `errors` and
/// skipped; a lot that is not a list gives a single error.
WordLotResult parseWordLot(String source) {
  final cards = <WordCard>[];
  final errors = <String>[];
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (e) {
    return (cards: cards, errors: ['not valid JSON: ${e.message}']);
  }
  if (decoded is! List) return (cards: cards, errors: ['a lot must be a JSON list']);

  for (final (index, item) in decoded.indexed) {
    final label = item is Map && item['id'] is String ? item['id'] as String : '#$index';
    if (item is! Map) {
      errors.add('$label: a card must be an object');
      continue;
    }
    String? text(String key) {
      final value = item[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    final id = text('id');
    final word = text('word');
    final definition = text('definition');
    final example = text('example');
    final part = PartOfSpeech.values.asNameMap()[item['partOfSpeech']];
    final fr = item['fr'];
    final problems = [
      if (id == null || !RegExp(r'^w-\d{3,}$').hasMatch(id)) 'id must look like w-001',
      if (word == null) 'word is required',
      if (part == null)
        'partOfSpeech must be one of ${PartOfSpeech.values.map((p) => p.name).join(', ')}',
      if (definition == null) 'definition is required',
      if (example == null) 'example is required',
      if (fr != null && (fr is! String || fr.trim().isEmpty)) 'fr must be a non-empty string',
    ];
    if (problems.isNotEmpty) {
      errors.add('$label: ${problems.join('; ')}');
      continue;
    }
    cards.add(
      WordCard(
        id: id!,
        word: word!,
        partOfSpeech: part!,
        definition: definition!,
        example: example!,
        fr: fr is String ? fr.trim() : null,
      ),
    );
  }
  return (cards: cards, errors: errors);
}

/// Ids used more than once, and words used more than once (case-insensitive).
List<String> findDuplicateWords(Iterable<WordCard> cards) {
  final ids = <String>{};
  final words = <String>{};
  final duplicates = <String>[];
  for (final card in cards) {
    if (!ids.add(card.id)) duplicates.add('duplicate id: ${card.id}');
    if (!words.add(card.word.toLowerCase())) duplicates.add('duplicate word: ${card.word}');
  }
  return duplicates;
}
