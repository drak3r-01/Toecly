import '../../../core/toeic_part.dart';
import 'question.dart';

/// Contenu d'un fichier JSON de questions (un « lot »).
class QuestionBatch {
  const QuestionBatch({
    required this.batchId,
    required this.part,
    required this.questions,
    this.title,
  });

  final String batchId;
  final ToeicPart part;
  final String? title;
  final List<Question> questions;
}
