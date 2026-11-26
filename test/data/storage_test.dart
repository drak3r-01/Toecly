import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';

void main() {
  test('les questions ratées les plus anciennes sont purgées', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = MissedQuestionsRepository(await SharedPreferences.getInstance());
    for (var i = 0; i < MissedQuestionsRepository.maxMissedQuestions + 5; i++) {
      await repository.markMissed('q$i');
    }
    final ids = repository.loadIds();
    expect(ids.length, MissedQuestionsRepository.maxMissedQuestions);
    expect(ids.first, 'q${MissedQuestionsRepository.maxMissedQuestions + 4}');
    expect(ids.contains('q0'), isFalse);
  });
}
