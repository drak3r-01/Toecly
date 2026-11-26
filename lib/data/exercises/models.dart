import '../../core/toeic_part.dart';

/// Kind of document shown in Parts 6 and 7. Drives how it is rendered.
enum DocumentType {
  email,
  letter,
  memo,
  notice,
  advertisement,
  article,
  textMessage('text_message'),
  onlineChat('online_chat'),
  form,
  invoice,
  schedule,
  jobAd('job_ad'),
  webPage('web_page'),
  review;

  const DocumentType([String? jsonName]) : _jsonName = jsonName;

  final String? _jsonName;

  /// Name used in the JSON files (snake_case).
  String get jsonName => _jsonName ?? name;

  static DocumentType? fromJsonName(String value) {
    for (final type in values) {
      if (type.jsonName == value) return type;
    }
    return null;
  }
}

/// What a question tests; used for per-category statistics.
enum QuestionCategory {
  grammar,
  vocabulary,
  connector,
  sentenceInsertion('sentence_insertion'),
  mainIdea('main_idea'),
  detail,
  inference,
  purpose,
  notTrue('not_true'),
  vocabularyInContext('vocabulary_in_context');

  const QuestionCategory([String? jsonName]) : _jsonName = jsonName;

  final String? _jsonName;

  String get jsonName => _jsonName ?? name;

  /// Categories accepted in each part.
  static const Map<ToeicPart, Set<QuestionCategory>> allowedByPart = {
    ToeicPart.part5: {grammar, vocabulary},
    ToeicPart.part6: {grammar, vocabulary, connector, sentenceInsertion},
    ToeicPart.part7: {
      mainIdea,
      detail,
      inference,
      purpose,
      notTrue,
      vocabularyInContext,
      sentenceInsertion,
    },
  };

  static QuestionCategory? fromJsonName(String value) {
    for (final category in values) {
      if (category.jsonName == value) return category;
    }
    return null;
  }
}

/// A text to read (Parts 6 and 7).
class ExerciseDocument {
  const ExerciseDocument({required this.type, required this.text, this.title});

  final DocumentType type;
  final String? title;
  final String text;
}

/// One multiple-choice question.
class Question {
  const Question({
    required this.id,
    required this.prompt,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
    this.category,
  });

  /// Stable and unique: the exercise id for Part 5, `<exerciseId>#<n>` otherwise.
  final String id;

  /// Part 5: the sentence with a blank. Part 6: the blank label (`[2]`). Part 7: the question.
  final String prompt;
  final List<String> choices;
  final int answerIndex;
  final String explanation;
  final QuestionCategory? category;
}

/// A self-contained block shown together on screen: a sentence, a text with
/// blanks, or one to three documents, with their questions.
class Exercise {
  const Exercise({
    required this.id,
    required this.part,
    required this.questions,
    this.documents = const [],
    this.audioAsset,
  });

  final String id;
  final ToeicPart part;
  final List<ExerciseDocument> documents;
  final List<Question> questions;

  /// Reserved for the future Listening parts.
  final String? audioAsset;

  /// Part 7 with several linked documents.
  bool get isMultiDocument => documents.length > 1;
}
