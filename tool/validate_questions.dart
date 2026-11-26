// Validates every question lot before a build: `dart run tool/validate_questions.dart`.
// Exits with code 1 and lists every problem when a lot is malformed.
import 'dart:io';

import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_parser.dart';
import 'package:toecly/data/exercises/models.dart';

void main() {
  final problems = <String>[];
  final all = <Exercise>[];
  var files = 0;

  for (final part in ToeicPart.readingParts) {
    final folder = Directory(part.assetFolder);
    if (!folder.existsSync()) {
      problems.add('${part.assetFolder}: folder is missing');
      continue;
    }
    final lots = folder
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in lots) {
      files++;
      final result = parseBatch(part, file.readAsStringSync());
      problems.addAll(result.errors.map((e) => '${file.path}: $e'));
      all.addAll(result.exercises);
    }
  }
  problems.addAll(findDuplicateIds(all).map((id) => 'duplicate id: $id'));

  if (problems.isEmpty) {
    stdout.writeln('OK: $files lot(s), ${all.length} exercise(s).');
    return;
  }
  stderr.writeln('${problems.length} problem(s):');
  for (final problem in problems) {
    stderr.writeln('  - $problem');
  }
  exit(1);
}
