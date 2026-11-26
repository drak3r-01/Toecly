import 'dart:math';

import '../../core/toeic_part.dart';
import 'models/question.dart';
import 'models/question_batch.dart';
import 'question_asset_loader.dart';

/// Point d'accès unique aux questions. Charge tout une seule fois (lazy),
/// puis tire des questions au hasard parmi tous les lots des parties demandées.
class QuestionRepository {
  QuestionRepository({QuestionAssetLoader? loader, Random? random})
      : _loader = loader ?? const QuestionAssetLoader(),
        _random = random ?? Random();

  final QuestionAssetLoader _loader;
  final Random _random;
  Future<Map<String, Question>>? _questionsById;

  Future<Map<String, Question>> _loadOnce() => _questionsById ??= _loader
      .loadAllBatches()
      .then((batches) => _indexById(batches));

  Map<String, Question> _indexById(List<QuestionBatch> batches) {
    final index = <String, Question>{};
    for (final question in batches.expand((batch) => batch.questions)) {
      if (index.containsKey(question.id)) {
        throw StateError('Identifiant de question en double : ${question.id}');
      }
      index[question.id] = question;
    }
    return index;
  }

  Future<int> countQuestions(ToeicPart part) async =>
      (await _loadOnce()).values.where((q) => q.part == part).length;

  /// Tire [count] questions distinctes au hasard dans [parts].
  /// Renvoie moins de questions si le stock est insuffisant.
  Future<List<Question>> drawRandomQuestions({
    required Set<ToeicPart> parts,
    required int count,
  }) async {
    final pool = (await _loadOnce()).values.where((q) => parts.contains(q.part)).toList()
      ..shuffle(_random);
    return pool.take(count).toList();
  }

  /// Retrouve des questions à partir de leurs identifiants (mode révision).
  /// Les identifiants qui n'existent plus sont ignorés.
  Future<List<Question>> findByIds(Iterable<String> ids) async {
    final index = await _loadOnce();
    return [for (final id in ids) if (index[id] != null) index[id]!];
  }
}
