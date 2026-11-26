import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercises/exercise_asset_loader.dart';
import '../data/exercises/exercise_repository.dart';
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
