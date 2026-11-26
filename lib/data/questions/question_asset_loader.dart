import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/question_batch.dart';
import 'question_batch_parser.dart';

/// Découvre tous les fichiers `assets/questions/**/*.json` embarqués dans
/// l'application, puis les parse dans un isolate pour ne jamais bloquer l'UI.
class QuestionAssetLoader {
  const QuestionAssetLoader({AssetBundle? bundle}) : _bundle = bundle; // ignore: prefer_initializing_formals

  final AssetBundle? _bundle;

  static const _questionsFolder = 'assets/questions/';

  Future<List<QuestionBatch>> loadAllBatches() async {
    final bundle = _bundle ?? rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final jsonPaths = manifest
        .listAssets()
        .where((path) => path.startsWith(_questionsFolder) && path.endsWith('.json'))
        .toList();

    final texts = await Future.wait(jsonPaths.map(bundle.loadString));
    final jsonTextByPath = Map.fromIterables(jsonPaths, texts);
    // Le parsing (CPU) se fait hors du thread UI.
    return compute(parseQuestionBatches, jsonTextByPath);
  }
}
