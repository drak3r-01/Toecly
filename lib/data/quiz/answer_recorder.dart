import '../exercises/models.dart';
import '../storage/missed_questions_repository.dart';
import '../storage/part_stats_repository.dart';
import '../storage/session_history_repository.dart';
import '../storage/session_record.dart';
import 'quiz_session.dart';

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

  Future<void> recordSession(
    QuizSession session,
    SessionMode mode,
    Duration duration,
  ) =>
      history.add(SessionRecord(
        mode: mode,
        finishedAt: _now(),
        parts: {for (final e in session.exercises) e.part},
        totalQuestions: session.totalQuestions,
        correctAnswers: session.correctCount,
        durationSeconds: duration.inSeconds,
      ));
}
