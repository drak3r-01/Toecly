import '../exercises/models.dart';
import '../storage/missed_questions_repository.dart';
import '../storage/part_stats_repository.dart';
import '../storage/session_history_repository.dart';
import '../storage/session_record.dart';

/// Persists what happens during a session: each answer (stats, missed
/// questions) as soon as it is given, and the session summary when it ends.
class AnswerRecorder {
  AnswerRecorder({
    required this.stats,
    required this.missed,
    required this.history,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PartStatsRepository stats;
  final MissedQuestionsRepository missed;
  final SessionHistoryRepository history;
  final DateTime Function() _now;

  /// A wrong answer joins the missed questions; a right one in review removes
  /// the question from them ([masterOnCorrect]).
  Future<void> recordAnswer(
    Exercise exercise,
    Question question, {
    required bool isCorrect,
    bool masterOnCorrect = false,
  }) async {
    await stats.recordAnswer(exercise.part, isCorrect: isCorrect, category: question.category);
    if (!isCorrect) {
      await missed.markMissed(question.id);
    } else if (masterOnCorrect) {
      await missed.markMastered(question.id);
    }
  }

  /// A question left blank at the end of an exam: not counted in the stats
  /// (nothing was answered) but kept for review.
  Future<void> recordSkipped(Question question) => missed.markMissed(question.id);

  Future<void> recordSession({
    required SessionMode mode,
    required List<Exercise> exercises,
    required int totalQuestions,
    required int correctAnswers,
    required Duration duration,
  }) =>
      history.add(SessionRecord(
        mode: mode,
        finishedAt: _now(),
        parts: {for (final e in exercises) e.part},
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        durationSeconds: duration.inSeconds,
      ));
}
