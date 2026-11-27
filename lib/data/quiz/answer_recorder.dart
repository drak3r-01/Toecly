import '../../core/toeic_part.dart';
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
    this.onChanged,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PartStatsRepository stats;
  final MissedQuestionsRepository missed;
  final SessionHistoryRepository history;

  /// Called after anything was saved, so screens showing statistics can refresh.
  final void Function()? onChanged;
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
    onChanged?.call();
  }

  /// A question left blank at the end of an exam: not counted in the stats
  /// (nothing was answered) but kept for review.
  Future<void> recordSkipped(Question question) async {
    await missed.markMissed(question.id);
    onChanged?.call();
  }

  /// Saves a whole mock exam at once: one write per store instead of one per answer.
  /// [answers] maps a question id to the picked choice; a missing id means left blank
  /// (kept for review, not counted in the stats).
  Future<void> recordExam({
    required Iterable<({Exercise exercise, Question question})> entries,
    required Map<String, int> answers,
    required int correctAnswers,
    required Duration duration,
  }) async {
    final answered = <({ToeicPart part, bool isCorrect, QuestionCategory? category})>[];
    final missedIds = <String>[];
    final exercises = <Exercise>{};
    var total = 0;
    for (final entry in entries) {
      total++;
      exercises.add(entry.exercise);
      final answer = answers[entry.question.id];
      final isCorrect = answer == entry.question.answerIndex;
      if (answer != null) {
        answered.add((
          part: entry.exercise.part,
          isCorrect: isCorrect,
          category: entry.question.category,
        ));
      }
      if (!isCorrect) missedIds.add(entry.question.id);
    }
    await stats.recordAnswers(answered);
    await missed.markMissedAll(missedIds);
    await recordSession(
      mode: SessionMode.mockExam,
      exercises: exercises.toList(),
      totalQuestions: total,
      correctAnswers: correctAnswers,
      duration: duration,
    );
  }

  Future<void> recordSession({
    required SessionMode mode,
    required List<Exercise> exercises,
    required int totalQuestions,
    required int correctAnswers,
    required Duration duration,
  }) async {
    await history.add(SessionRecord(
      mode: mode,
      finishedAt: _now(),
      parts: {for (final e in exercises) e.part},
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      durationSeconds: duration.inSeconds,
    ));
    onChanged?.call();
  }
}
