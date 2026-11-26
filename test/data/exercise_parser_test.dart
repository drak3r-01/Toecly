import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/exercise_parser.dart';
import 'package:toecly/data/exercises/models.dart';

Map<String, dynamic> p5({Map<String, dynamic> override = const {}}) => {
      'id': 'p5-1',
      'sentence': 'The meeting has been ___ until Monday.',
      'choices': ['a', 'b', 'c', 'd'],
      'answerIndex': 1,
      'explanation': 'Passive voice.',
      ...override,
    };

Map<String, dynamic> p6Question(int blank, {int answerIndex = 0}) => {
      'blank': blank,
      'choices': ['a', 'b', 'c', 'd'],
      'answerIndex': answerIndex,
      'explanation': 'because',
    };

Map<String, dynamic> p6({Map<String, dynamic> override = const {}}) => {
      'id': 'p6-1',
      'documentType': 'email',
      'text': 'One [1] two [2] three [3] four [4].',
      'questions': [for (var i = 1; i <= 4; i++) p6Question(i)],
      ...override,
    };

Map<String, dynamic> p7Question() => {
      'prompt': 'Why?',
      'choices': ['a', 'b', 'c', 'd'],
      'answerIndex': 2,
      'explanation': 'because',
    };

Map<String, dynamic> p7({int documents = 1, int questions = 2, Map<String, dynamic> override = const {}}) => {
      'id': 'p7-1',
      'documents': [
        for (var i = 0; i < documents; i++) {'type': 'email', 'title': 'D$i', 'text': 'text'},
      ],
      'questions': [for (var i = 0; i < questions; i++) p7Question()],
      ...override,
    };

BatchParseResult parse(ToeicPart part, Object lot) => parseBatch(part, jsonEncode(lot));

void main() {
  group('valid lots', () {
    test('Part 5: one exercise, one question sharing the exercise id, category and audio', () {
      final result = parse(ToeicPart.part5, [
        p5(override: {'category': 'grammar', 'audio': 'a.mp3'}),
      ]);
      expect(result.errors, isEmpty);
      final exercise = result.exercises.single;
      expect(exercise.questions.single.id, 'p5-1');
      expect(exercise.questions.single.category, QuestionCategory.grammar);
      expect(exercise.questions.single.prompt, contains('___'));
      expect(exercise.audioAsset, 'a.mp3');
    });

    test('Part 6: four questions with ids <id>#n and the document type', () {
      final exercise = parse(ToeicPart.part6, [p6()]).exercises.single;
      expect(exercise.questions.map((q) => q.id), ['p6-1#1', 'p6-1#2', 'p6-1#3', 'p6-1#4']);
      expect(exercise.documents.single.type, DocumentType.email);
    });

    test('Part 7: single and multiple documents', () {
      final result = parse(ToeicPart.part7, [p7(), p7(documents: 3, questions: 5, override: {'id': 'p7-2'})]);
      expect(result.errors, isEmpty);
      expect(result.exercises.map((e) => e.isMultiDocument), [false, true]);
    });

    test('snake_case names map to enum values', () {
      final item = p7(override: {
        'documents': [
          {'type': 'text_message', 'text': 'hi'},
        ],
      });
      item['questions'][0]['category'] = 'vocabulary_in_context';
      final exercise = parse(ToeicPart.part7, [item]).exercises.single;
      expect(exercise.documents.single.type, DocumentType.textMessage);
      expect(exercise.questions.first.category, QuestionCategory.vocabularyInContext);
    });
  });

  group('invalid lots report the exercise id', () {
    void expectError(ToeicPart part, Object lot, Pattern message) {
      final result = parse(part, lot);
      expect(result.exercises, isEmpty);
      expect(result.errors.single, allOf(startsWith('${(lot as List).first['id']}:'), contains(message)));
    }

    test('Part 5: answerIndex out of range', () {
      expectError(ToeicPart.part5, [p5(override: {'answerIndex': 4})], 'answerIndex');
    });
    test('Part 5: wrong number of choices', () {
      expectError(ToeicPart.part5, [p5(override: {'choices': ['a', 'b']})], 'exactly 4');
    });
    test('Part 5: missing blank marker', () {
      expectError(ToeicPart.part5, [p5(override: {'sentence': 'No blank here.'})], 'blank marker');
    });
    test('Part 5: missing explanation', () {
      expectError(ToeicPart.part5, [p5(override: {'explanation': ''})], 'explanation');
    });
    test('category not allowed in this part', () {
      expectError(ToeicPart.part5, [p5(override: {'category': 'main_idea'})], 'not valid for part 5');
    });
    test('Part 6: missing marker', () {
      expectError(ToeicPart.part6, [p6(override: {'text': 'One [1] two [2] three [3].'})], '[4]');
    });
    test('Part 6: marker used twice', () {
      expectError(ToeicPart.part6, [p6(override: {'text': '[1] [1] [2] [3] [4]'})], '[1]');
    });
    test('Part 6: not four questions', () {
      expectError(ToeicPart.part6, [p6(override: {'questions': [p6Question(1)]})], 'exactly 4');
    });
    test('Part 6: blanks out of order', () {
      expectError(
        ToeicPart.part6,
        [p6(override: {'questions': [p6Question(2), p6Question(1), p6Question(3), p6Question(4)]})],
        'blank',
      );
    });
    test('Part 6: unknown document type', () {
      expectError(ToeicPart.part6, [p6(override: {'documentType': 'telegram'})], 'unknown document type');
    });
    test('Part 7: no document', () {
      expectError(ToeicPart.part7, [p7(documents: 0)], '1 to 3 documents');
    });
    test('Part 7: four documents', () {
      expectError(ToeicPart.part7, [p7(documents: 4, questions: 5)], '1 to 3 documents');
    });
    test('Part 7: single document with 5 questions', () {
      expectError(ToeicPart.part7, [p7(questions: 5)], '2 to 4');
    });
    test('Part 7: multiple documents with 4 questions', () {
      expectError(ToeicPart.part7, [p7(documents: 2, questions: 4)], 'exactly 5');
    });
  });

  test('every bad exercise is reported, the good ones are kept', () {
    final result = parse(ToeicPart.part5, [p5(), p5(override: {'id': 'bad', 'answerIndex': 9})]);
    expect(result.exercises, hasLength(1));
    expect(result.errors, hasLength(1));
  });

  test('a lot that is not a list, or not JSON, is rejected', () {
    expect(parseBatch(ToeicPart.part5, '{}').errors.single, contains('list'));
    expect(parseBatch(ToeicPart.part5, 'not json').errors.single, contains('invalid JSON'));
  });

  test('findDuplicateIds ignores the Part 5 exercise/question id overlap', () {
    final exercises = [
      ...parse(ToeicPart.part5, [p5()]).exercises,
      ...parse(ToeicPart.part6, [p6()]).exercises,
    ];
    expect(findDuplicateIds(exercises), isEmpty);
    expect(findDuplicateIds([...exercises, ...exercises]), contains('p5-1'));
  });
}
