import 'dart:convert';

import '../../core/toeic_part.dart';
import 'models.dart';

const int choiceCount = 4;
const String part5BlankMarker = '___';

/// Longest text (sentence, passage or document) accepted, to keep every text readable.
const int maxTextLength = 4000;

/// Result of parsing one lot file: valid exercises plus one message per problem.
class BatchParseResult {
  const BatchParseResult(this.exercises, this.errors);

  final List<Exercise> exercises;
  final List<String> errors;
}

/// Parses a lot (a JSON list of exercises) of the given [part].
/// Pure Dart: also used by `tool/validate_questions.dart`.
BatchParseResult parseBatch(ToeicPart part, String jsonText) {
  final Object? root;
  try {
    root = jsonDecode(jsonText);
  } on FormatException catch (error) {
    return BatchParseResult(const [], ['invalid JSON: ${error.message}']);
  }
  if (root is! List) {
    return const BatchParseResult([], [
      'a lot must be a JSON list of exercises',
    ]);
  }

  final exercises = <Exercise>[];
  final errors = <String>[];
  for (var i = 0; i < root.length; i++) {
    final item = root[i];
    final label = item is Map && item['id'] is String ? item['id'] as String : '#$i';
    try {
      if (item is! Map<String, dynamic>) throw const FormatException('must be an object');
      exercises.add(_parseExercise(part, item));
    } on FormatException catch (error) {
      errors.add('$label: ${error.message}');
    }
  }
  return BatchParseResult(exercises, errors);
}

Exercise _parseExercise(ToeicPart part, Map<String, dynamic> json) {
  final id = _string(json, 'id');
  final audio = _optionalString(json, 'audio');
  switch (part) {
    case ToeicPart.part5:
      return _parsePart5(id, audio, json);
    case ToeicPart.part6:
      return _parsePart6(id, audio, json);
    case ToeicPart.part7:
      return _parsePart7(id, audio, json);
    default:
      throw FormatException('part ${part.number} is not supported yet');
  }
}

Exercise _parsePart5(String id, String? audio, Map<String, dynamic> json) {
  final sentence = _string(json, 'sentence');
  if (part5BlankMarker.allMatches(sentence).length != 1) {
    throw const FormatException(
      '"sentence" must contain the blank marker "$part5BlankMarker" exactly once',
    );
  }
  return Exercise(
    id: id,
    part: ToeicPart.part5,
    audioAsset: audio,
    questions: [
      _parseQuestion(
        questionId: id,
        prompt: sentence,
        json: json,
        part: ToeicPart.part5,
      ),
    ],
  );
}

Exercise _parsePart6(String id, String? audio, Map<String, dynamic> json) {
  final text = _text(json, 'text');
  final type = _documentType(_string(json, 'documentType'));
  final questions = _list(json, 'questions');
  if (questions.length != 4) {
    throw FormatException(
      'needs exactly 4 questions, found ${questions.length}',
    );
  }
  for (var blank = 1; blank <= 4; blank++) {
    if ('[$blank]'.allMatches(text).length != 1) {
      throw FormatException(
        '"text" must contain the marker [$blank] exactly once',
      );
    }
  }
  return Exercise(
    id: id,
    part: ToeicPart.part6,
    audioAsset: audio,
    documents: [ExerciseDocument(type: type, text: text)],
    questions: [
      for (var i = 0; i < questions.length; i++)
        () {
          final q = _asMap(questions[i], 'questions[$i]');
          if (q['blank'] != i + 1) {
            throw FormatException('questions[$i].blank must be ${i + 1}');
          }
          return _parseQuestion(
            questionId: '$id#${i + 1}',
            prompt: '[${i + 1}]',
            json: q,
            part: ToeicPart.part6,
          );
        }(),
    ],
  );
}

Exercise _parsePart7(String id, String? audio, Map<String, dynamic> json) {
  final documents = _list(json, 'documents');
  if (documents.isEmpty || documents.length > 3) {
    throw FormatException('needs 1 to 3 documents, found ${documents.length}');
  }
  final questions = _list(json, 'questions');
  final isMulti = documents.length > 1;
  if (isMulti ? questions.length != 5 : questions.length < 2 || questions.length > 4) {
    throw FormatException(
      '${isMulti ? 'multiple-document' : 'single-document'} exercises need '
      '${isMulti ? 'exactly 5' : '2 to 4'} questions, found ${questions.length}',
    );
  }
  return Exercise(
    id: id,
    part: ToeicPart.part7,
    audioAsset: audio,
    documents: [
      for (var i = 0; i < documents.length; i++)
        () {
          final d = _asMap(documents[i], 'documents[$i]');
          return ExerciseDocument(
            type: _documentType(_string(d, 'type')),
            title: _optionalString(d, 'title'),
            text: _text(d, 'text'),
          );
        }(),
    ],
    questions: [
      for (var i = 0; i < questions.length; i++)
        () {
          final q = _asMap(questions[i], 'questions[$i]');
          return _parseQuestion(
            questionId: '$id#${i + 1}',
            prompt: _string(q, 'prompt'),
            json: q,
            part: ToeicPart.part7,
          );
        }(),
    ],
  );
}

Question _parseQuestion({
  required String questionId,
  required String prompt,
  required Map<String, dynamic> json,
  required ToeicPart part,
}) {
  final choices = _list(json, 'choices');
  if (choices.length != choiceCount || choices.any((c) => c is! String || c.trim().isEmpty)) {
    throw FormatException(
      '$questionId: "choices" must hold exactly $choiceCount non-empty strings',
    );
  }
  if (choices.map((c) => (c as String).trim().toLowerCase()).toSet().length != choiceCount) {
    throw FormatException('$questionId: "choices" must all be different');
  }
  final answerIndex = json['answerIndex'];
  if (answerIndex is! int || answerIndex < 0 || answerIndex >= choiceCount) {
    throw FormatException(
      '$questionId: "answerIndex" must be an integer from 0 to ${choiceCount - 1}',
    );
  }

  QuestionCategory? category;
  final rawCategory = _optionalString(json, 'category');
  if (rawCategory != null) {
    category = QuestionCategory.fromJsonName(rawCategory);
    if (category == null || !QuestionCategory.allowedByPart[part]!.contains(category)) {
      throw FormatException(
        '$questionId: category "$rawCategory" is not valid for part ${part.number}',
      );
    }
  }

  return Question(
    id: questionId,
    prompt: prompt,
    choices: choices.cast<String>(),
    answerIndex: answerIndex,
    explanation: _string(json, 'explanation'),
    category: category,
  );
}

DocumentType _documentType(String value) =>
    DocumentType.fromJsonName(value) ?? (throw FormatException('unknown document type "$value"'));

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('"$key" is missing or not a non-empty string');
  }
  return value;
}

String _text(Map<String, dynamic> json, String key) {
  final value = _string(json, key);
  if (value.length > maxTextLength) {
    throw FormatException(
      '"$key" is ${value.length} characters long (max $maxTextLength)',
    );
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('"$key" must be a non-empty string when present');
  }
  return value;
}

List<dynamic> _list(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('"$key" is missing or not a list');
  return value;
}

Map<String, dynamic> _asMap(Object? value, String where) {
  if (value is! Map<String, dynamic>) throw FormatException('$where must be an object');
  return value;
}

/// Reports ids used more than once across [exercises] (exercise and question ids).
List<String> findDuplicateIds(Iterable<Exercise> exercises) {
  final seen = <String>{};
  final duplicates = <String>{};
  for (final exercise in exercises) {
    // A set: a Part 5 question legitimately shares its exercise's id.
    for (final id in {exercise.id, ...exercise.questions.map((q) => q.id)}) {
      if (!seen.add(id)) duplicates.add(id);
    }
  }
  return duplicates.toList()..sort();
}

/// Share of questions (0..1) whose right answer is the one longest choice. About 0.25 is
/// expected when answers are not recognisable by length; a high value is a bias.
double longestAnswerShare(Iterable<Exercise> exercises) {
  var longest = 0;
  var total = 0;
  for (final question in exercises.expand((e) => e.questions)) {
    total++;
    final lengths = [for (final c in question.choices) c.length];
    final max = lengths.reduce((a, b) => a > b ? a : b);
    if (lengths[question.answerIndex] == max && lengths.where((l) => l == max).length == 1) {
      longest++;
    }
  }
  return total == 0 ? 0 : longest / total;
}
