import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/toeic_part.dart';
import '../data/exercises/exercise_asset_loader.dart';
import '../data/exercises/exercise_repository.dart';
import '../data/exercises/models.dart';
import '../data/quiz/answer_recorder.dart';
import '../data/quiz/quiz_request.dart';
import '../data/storage/last_practice_repository.dart';
import '../data/storage/local_store.dart';
import '../data/storage/missed_questions_repository.dart';
import '../data/storage/part_stats_repository.dart';
import '../data/storage/session_history_repository.dart';

/// Overridden in `main()` once the store is open (and with an in-memory store in tests).
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider must be overridden'),
);

final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) => ExerciseRepository(loadBundledExercises));

final missedQuestionsProvider =
    Provider((ref) => MissedQuestionsRepository(ref.watch(localStoreProvider)));

final partStatsProvider = Provider((ref) => PartStatsRepository(ref.watch(localStoreProvider)));

final sessionHistoryProvider =
    Provider((ref) => SessionHistoryRepository(ref.watch(localStoreProvider)));

/// Draws the exercises of a quiz session; kept while the quiz screen is open.
final quizDrawProvider = FutureProvider.autoDispose.family<List<Exercise>, QuizRequest>(
  (ref, request) => ref.watch(exerciseRepositoryProvider).drawByQuestionCount(
        parts: request.parts.toSet(),
        questionCount: request.questionCount,
      ),
);

/// Bumped each time results are saved. Screens that show statistics watch it
/// to re-read them (the repositories themselves hold no state).
class DataRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dataRevisionProvider = NotifierProvider<DataRevisionNotifier, int>(DataRevisionNotifier.new);

final lastPracticeProvider =
    Provider((ref) => LastPracticeRepository(ref.watch(localStoreProvider)));

final answerRecorderProvider = Provider(
  (ref) => AnswerRecorder(
    stats: ref.watch(partStatsProvider),
    missed: ref.watch(missedQuestionsProvider),
    history: ref.watch(sessionHistoryProvider),
    onChanged: () => ref.read(dataRevisionProvider.notifier).bump(),
  ),
);

/// Missed question ids that still exist in the question bank. Ids of questions removed
/// or renamed since (the bank gets regenerated) are dropped from storage here.
final missedIdsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  ref.watch(dataRevisionProvider);
  final existing = await ref.watch(exerciseRepositoryProvider).questionIds();
  final missed = ref.read(missedQuestionsProvider);
  // An empty bank means the load went wrong, not that every question vanished.
  return existing.isEmpty ? missed.loadIds() : missed.retainOnly(existing);
});

/// Exercises to review: those holding missed questions, up to the given number of questions.
final reviewDrawProvider = FutureProvider.autoDispose.family<List<Exercise>, int>(
  (ref, questionCount) async => ref
      .watch(exerciseRepositoryProvider)
      .drawForReview(await ref.read(missedIdsProvider.future), questionCount),
);

/// Questions available per Reading part, counted once when the app starts
/// (the app warms it up, which also loads the bundled lots).
final questionCountsProvider = FutureProvider<Map<ToeicPart, int>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return {for (final part in ToeicPart.readingParts) part: await repository.countQuestions(part)};
});
