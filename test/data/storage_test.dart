import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/models.dart';
import 'package:toecly/data/storage/local_store.dart';
import 'package:toecly/data/storage/missed_questions_repository.dart';
import 'package:toecly/data/storage/part_stats_repository.dart';
import 'package:toecly/data/storage/session_history_repository.dart';
import 'package:toecly/data/storage/session_record.dart';

SessionRecord record(int n) => SessionRecord(
      mode: SessionMode.practice,
      finishedAt: DateTime.utc(2026, 1, 1, 0, n),
      parts: {ToeicPart.part5, ToeicPart.part7},
      totalQuestions: 20,
      correctAnswers: n % 20,
      durationSeconds: 60,
    );

void main() {
  group('LocalStore', () {
    test('SharedPreferencesStore persists strings', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferencesStore.open();
      await store.write('k', 'v');
      expect(store.read('k'), 'v');
      expect(store.read('missing'), isNull);
    });

    test('versioned JSON round-trips', () async {
      final store = InMemoryStore();
      await store.writeJson('k', [1, 2]);
      expect(store.readJson('k'), [1, 2]);
    });

    test('corrupted or unknown-version data reads as absent', () {
      final store = InMemoryStore()
        ..values['bad'] = '{not json'
        ..values['future'] = '{"version": 99, "data": [1]}';
      expect(store.readJson('bad'), isNull);
      expect(store.readJson('future'), isNull);
    });
  });

  group('MissedQuestionsRepository', () {
    test('most recent first, no duplicates', () async {
      final repository = MissedQuestionsRepository(InMemoryStore());
      await repository.markMissed('a');
      await repository.markMissed('b');
      await repository.markMissed('a');
      expect(repository.loadIds(), ['a', 'b']);
    });

    test('mastered questions are removed', () async {
      final repository = MissedQuestionsRepository(InMemoryStore());
      await repository.markMissed('a');
      await repository.markMissed('b');
      await repository.markMastered('a');
      expect(repository.loadIds(), ['b']);
    });

    test('keeps the 500 most recent and drops the oldest', () async {
      final repository = MissedQuestionsRepository(InMemoryStore());
      const max = MissedQuestionsRepository.maxMissedQuestions;
      expect(max, 500);
      for (var i = 0; i < max + 5; i++) {
        await repository.markMissed('q$i');
      }
      final ids = repository.loadIds();
      expect(ids, hasLength(max));
      expect(ids.first, 'q${max + 4}');
      expect(ids, isNot(contains('q0')));
    });
  });

  group('PartStatsRepository', () {
    test('counts per part and per category', () async {
      final repository = PartStatsRepository(InMemoryStore());
      await repository.recordAnswer(ToeicPart.part5, isCorrect: true, category: QuestionCategory.grammar);
      await repository.recordAnswer(ToeicPart.part5, isCorrect: false, category: QuestionCategory.grammar);
      await repository.recordAnswer(ToeicPart.part5, isCorrect: true, category: QuestionCategory.vocabulary);
      await repository.recordAnswer(ToeicPart.part6, isCorrect: true);

      expect(repository.forPart(ToeicPart.part5).answered, 3);
      expect(repository.forPart(ToeicPart.part5).correct, 2);
      expect(repository.forCategory(ToeicPart.part5, QuestionCategory.grammar).rate, 0.5);
      expect(repository.forCategory(ToeicPart.part5, QuestionCategory.vocabulary).rate, 1);
      expect(repository.forPart(ToeicPart.part6).answered, 1);
    });

    test('same category name in two parts is counted separately', () async {
      final repository = PartStatsRepository(InMemoryStore());
      await repository.recordAnswer(ToeicPart.part5, isCorrect: true, category: QuestionCategory.vocabulary);
      expect(repository.forCategory(ToeicPart.part6, QuestionCategory.vocabulary).answered, 0);
    });

    test('nothing answered gives a rate of 0', () {
      expect(PartStatsRepository(InMemoryStore()).forPart(ToeicPart.part7).rate, 0);
    });
  });

  group('SessionHistoryRepository', () {
    test('round-trips a record, newest first', () async {
      final repository = SessionHistoryRepository(InMemoryStore());
      await repository.add(record(1));
      await repository.add(record(2));
      final loaded = repository.loadAll();
      expect(loaded.first.correctAnswers, 2);
      expect(loaded.first.parts, {ToeicPart.part5, ToeicPart.part7});
      expect(loaded.first.finishedAt, DateTime.utc(2026, 1, 1, 0, 2));
    });

    test('keeps at most 200 sessions', () async {
      final repository = SessionHistoryRepository(InMemoryStore());
      for (var i = 0; i < SessionHistoryRepository.maxSessions + 3; i++) {
        await repository.add(record(i));
      }
      expect(repository.loadAll(), hasLength(SessionHistoryRepository.maxSessions));
    });
  });

  test('only the mock exam hides the correction until the end', () {
    expect(SessionMode.practice.revealsAnswerImmediately, isTrue);
    expect(SessionMode.review.revealsAnswerImmediately, isTrue);
    expect(SessionMode.mockExam.revealsAnswerImmediately, isFalse);
  });
}
