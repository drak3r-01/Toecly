import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  test('sample files are not loaded as questions', () async {
    final exercises = await loadBundledExercises();
    expect(exercises.where((e) => e.id.contains('sample')), isEmpty);
  });

  test('an invalid exercise or a duplicate id is skipped, not fatal', () async {
    String p5(String id) => jsonEncode([
          {
            'id': id,
            'sentence': 'We ___ it.',
            'choices': ['a', 'b', 'c', 'd'],
            'answerIndex': 0,
            'explanation': 'x',
          },
        ]);
    final files = {
      'assets/questions/part5/lot01.json': p5('p5-001'),
      'assets/questions/part5/lot02.json': '{not json',
      'assets/questions/part5/lot03.json': p5('p5-001'), // duplicate id
      'assets/questions/part5/lot04.json': p5('p5-002'),
      'assets/questions/part5/sample.json': p5('p5-sample'),
    };
    final exercises = await loadBundledExercises(bundle: _FakeBundle(files));
    expect(exercises.map((e) => e.id), ['p5-001', 'p5-002']);
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final manifest = {
        for (final path in files.keys) path: [<String, Object>{'asset': path}],
      };
      return const StandardMessageCodec().encodeMessage(manifest)!;
    }
    final text = files[key];
    if (text == null) throw FlutterError('Unable to load asset: $key');
    final bytes = Uint8List.fromList(utf8.encode(text));
    return ByteData.sublistView(bytes);
  }
}
