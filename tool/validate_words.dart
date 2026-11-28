// Validates every word lot before a build: `dart run tool/validate_words.dart`.
// Exits with code 1 and lists every problem when a lot is malformed.
import 'dart:io';

import 'package:toecly/data/words/word_card.dart';

void main() {
  final problems = <String>[];
  final all = <WordCard>[];
  final folder = Directory('assets/words');
  if (!folder.existsSync()) {
    stderr.writeln('assets/words: folder is missing');
    exit(1);
  }
  final lots = folder.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in lots) {
    final result = parseWordLot(file.readAsStringSync());
    problems.addAll(result.errors.map((e) => '${file.path}: $e'));
    all.addAll(result.cards);
  }
  problems.addAll(findDuplicateWords(all));

  if (problems.isEmpty) {
    stdout.writeln('OK: ${lots.length} lot(s), ${all.length} card(s).');
    return;
  }
  stderr.writeln('${problems.length} problem(s):');
  for (final problem in problems) {
    stderr.writeln('  - $problem');
  }
  exit(1);
}
