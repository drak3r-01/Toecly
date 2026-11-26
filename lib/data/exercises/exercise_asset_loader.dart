import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/toeic_part.dart';
import 'exercise_parser.dart';
import 'models.dart';

/// Reads every lot of Parts 5-7 bundled in the app. Parsing runs in an isolate.
Future<List<Exercise>> loadBundledExercises({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final paths = manifest.listAssets().where((p) => p.endsWith('.json')).toList();

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
    if (result.errors.isNotEmpty) {
      throw FormatException('${entry.key}: ${result.errors.join('; ')}');
    }
    exercises.addAll(result.exercises);
  }
  final duplicates = findDuplicateIds(exercises);
  if (duplicates.isNotEmpty) throw FormatException('Duplicate ids: ${duplicates.join(', ')}');
  return exercises;
}
