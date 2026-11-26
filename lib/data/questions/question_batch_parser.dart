import 'dart:convert';

import '../../core/toeic_part.dart';
import 'models/question.dart';
import 'models/question_batch.dart';

/// Version du format JSON des lots de questions (voir docs/QUESTION_FORMAT.md).
const int supportedQuestionSchemaVersion = 1;

/// Lit tous les fichiers JSON d'un coup. Fonction de premier niveau pour
/// pouvoir être exécutée dans un isolate via `compute`.
///
/// [jsonTextByAssetPath] : chemin de l'asset -> contenu JSON.
List<QuestionBatch> parseQuestionBatches(Map<String, String> jsonTextByAssetPath) {
  return [
    for (final entry in jsonTextByAssetPath.entries)
      _parseOneBatch(entry.key, entry.value),
  ];
}

QuestionBatch _parseOneBatch(String assetPath, String jsonText) {
  try {
    final root = jsonDecode(jsonText) as Map<String, dynamic>;
    final version = root['schemaVersion'];
    if (version != supportedQuestionSchemaVersion) {
      throw FormatException('schemaVersion $version non supportée');
    }
    final part = ToeicPart.fromNumber(root['part'] as int);
    final batchId = root['batchId'] as String;

    final questions = <Question>[];
    for (final group in (root['groups'] as List).cast<Map<String, dynamic>>()) {
      final passages = [
        for (final p in (group['passages'] as List? ?? const []))
          Passage.fromJson(p as Map<String, dynamic>),
      ];
      final audioAsset = group['audio'] as String?;
      for (final q in (group['questions'] as List).cast<Map<String, dynamic>>()) {
        final choices = (q['choices'] as List).cast<String>();
        final correctIndex = q['answerIndex'] as int;
        final id = q['id'] as String;
        if (choices.length < 2 || correctIndex < 0 || correctIndex >= choices.length) {
          throw FormatException('question $id : réponses incohérentes');
        }
        questions.add(Question(
          id: id,
          part: part,
          prompt: q['prompt'] as String,
          choices: choices,
          correctChoiceIndex: correctIndex,
          explanation: q['explanation'] as String,
          passages: passages,
          audioAsset: audioAsset,
        ));
      }
    }
    return QuestionBatch(
      batchId: batchId,
      part: part,
      title: root['title'] as String?,
      questions: questions,
    );
  } on FormatException catch (error) {
    throw FormatException('$assetPath : ${error.message}');
  } on TypeError catch (error) {
    throw FormatException('$assetPath : champ manquant ou de mauvais type ($error)');
  }
}
