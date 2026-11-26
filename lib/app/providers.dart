import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercises/exercise_asset_loader.dart';
import '../data/exercises/exercise_repository.dart';
import '../data/exercises/models.dart';
import '../data/quiz/quiz_request.dart';
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
