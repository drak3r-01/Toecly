import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/questions/question_asset_loader.dart';
import 'package:toecly/data/questions/question_batch_parser.dart';
import 'package:toecly/data/questions/question_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('les lots d\'exemple embarqués sont chargés (via isolate) et tirés sans doublon', () async {
    final repository = QuestionRepository();
    final drawn = await repository.drawRandomQuestions(
      parts: {ToeicPart.part5, ToeicPart.part7},
      count: 100,
    );
    expect(drawn.length, 4);
    expect(drawn.map((q) => q.id).toSet().length, 4);
    expect(drawn.every((q) => q.part == ToeicPart.part5 || q.part == ToeicPart.part7), isTrue);
    expect(await const QuestionAssetLoader().loadAllBatches(), hasLength(3));
  });

  test('un JSON invalide donne une erreur qui nomme le fichier', () {
    expect(
      () => parseQuestionBatches({'assets/questions/part5/cassé.json': '{"schemaVersion":1,"part":5,"batchId":"x","groups":[{"questions":[{"id":"a","prompt":"p","choices":["1","2"],"answerIndex":5,"explanation":"e"}]}]}'}),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('cassé.json'))),
    );
  });
}
