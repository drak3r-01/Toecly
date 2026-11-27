import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/toeic_part.dart';
import 'exercise_parser.dart';
import 'models.dart';

/// Reads every lot of Parts 5-7 bundled in the app. Parsing runs in an isolate.
Future<List<Exercise>> loadBundledExercises({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  // sample*.json are format examples, not real questions.
  final paths = manifest
      .listAssets()
      .where((p) => p.endsWith('.json') && !p.split('/').last.startsWith('sample'))
      .toList();

  final jobs = <String, (ToeicPart, String)>{};
  for (final part in ToeicPart.readingParts) {
    for (final path in paths.where((p) => p.startsWith(part.assetFolder))) {
      jobs[path] = (part, await assets.loadString(path));
    }
  }
  return compute(_parseAll, jobs);
}

List<Exercise> _parseAll(Map<String, (ToeicPart, String)> jobs) {
  final exercises = <Exercise>[];
  for (final entry in jobs.entries) {
    final result = parseBatch(entry.value.$1, entry.value.$2);
    // CI rejects invalid lots; if one slips through, drop only the faulty exercises.
    if (result.errors.isNotEmpty) {
      debugPrint('Skipping invalid exercises in ${entry.key}: ${result.errors.join('; ')}');
    }
    exercises.addAll(result.exercises);
  }
  // An exercise sharing an id with an earlier one is dropped: ids key the saved progress.
  final seen = <String>{};
  final unique = <Exercise>[];
  for (final exercise in exercises) {
    final ids = {exercise.id, ...exercise.questions.map((q) => q.id)};
    if (ids.any(seen.contains)) {
      debugPrint('Skipping exercise with duplicate id ${exercise.id}');
      continue;
    }
    seen.addAll(ids);
    unique.add(exercise);
  }
  return unique;
}
