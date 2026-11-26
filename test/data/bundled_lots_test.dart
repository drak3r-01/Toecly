import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_asset_loader.dart';
import 'package:toecly/data/exercises/exercise_parser.dart';
import 'package:toecly/data/exercises/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled lot is valid and ids are unique', () {
    final all = <Exercise>[];
    for (final part in ToeicPart.readingParts) {
      final files = Directory(part.assetFolder)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));
      expect(files, isNotEmpty, reason: 'no lot in ${part.assetFolder}');
      for (final file in files) {
        final result = parseBatch(part, file.readAsStringSync());
        expect(result.errors, isEmpty, reason: file.path);
        all.addAll(result.exercises);
      }
    }
    expect(findDuplicateIds(all), isEmpty);
  });

  test('each part folder documents its schema in a README', () {
    for (final part in ToeicPart.readingParts) {
      expect(File('${part.assetFolder}README.md').existsSync(), isTrue, reason: part.assetFolder);
    }
  });

  test('the app loads the bundled lots through the asset bundle', () async {
    final exercises = await loadBundledExercises();
    expect(exercises.map((e) => e.part).toSet(), ToeicPart.readingParts.toSet());
  });
}
