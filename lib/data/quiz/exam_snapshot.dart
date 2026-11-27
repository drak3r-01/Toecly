import '../exercises/models.dart';
import 'exam_session.dart';

/// Everything needed to resume a mock exam after the app was killed: which exercises were
/// drawn, in which order the choices were shown, the answers, the position and the
/// wall-clock end time. Pure Dart, stored as JSON by `ExamProgressRepository`.
class ExamSnapshot {
  const ExamSnapshot({
    required this.exerciseIds,
    required this.choices,
    required this.answers,
    required this.currentIndex,
    required this.endsAt,
    required this.totalSeconds,
  });

  final List<String> exerciseIds;

  /// Choices as displayed (already shuffled), by question id.
  final Map<String, List<String>> choices;

  /// Picked choice index (in the displayed order), by question id.
  final Map<String, int> answers;
  final int currentIndex;
  final DateTime endsAt;
  final int totalSeconds;

  factory ExamSnapshot.capture(
    ExamSession session, {
    required DateTime endsAt,
    required Duration total,
  }) =>
      ExamSnapshot(
        exerciseIds: [for (final e in session.exercises) e.id],
        choices: {
          for (final e in session.entries) e.question.id: List.of(e.question.choices),
        },
        answers: session.answers,
        currentIndex: session.currentIndex,
        endsAt: endsAt,
        totalSeconds: total.inSeconds,
      );

  Map<String, dynamic> toJson() => {
        'exerciseIds': exerciseIds,
        'choices': choices,
        'answers': answers,
        'currentIndex': currentIndex,
        'endsAt': endsAt.toIso8601String(),
        'totalSeconds': totalSeconds,
      };

  /// Throws when the data is not shaped like a snapshot.
  factory ExamSnapshot.fromJson(Map<String, dynamic> json) => ExamSnapshot(
        exerciseIds: (json['exerciseIds'] as List).cast<String>(),
        choices: {
          for (final e in (json['choices'] as Map).entries)
            e.key as String: (e.value as List).cast<String>(),
        },
        answers: {
          for (final e in (json['answers'] as Map).entries) e.key as String: e.value as int,
        },
        currentIndex: json['currentIndex'] as int,
        endsAt: DateTime.parse(json['endsAt'] as String),
        totalSeconds: json['totalSeconds'] as int,
      );

  /// Rebuilds the drawn exercises from the current [bank], with the choices in the order
  /// they were displayed. Returns null when the bank changed since (an exercise is gone or
  /// its choices differ), because the exam can then no longer be reproduced faithfully.
  List<Exercise>? restore(Iterable<Exercise> bank) {
    final byId = {for (final e in bank) e.id: e};
    final exercises = <Exercise>[];
    for (final id in exerciseIds) {
      final original = byId[id];
      if (original == null) return null;
      final questions = <Question>[];
      for (final question in original.questions) {
        final shown = choices[question.id];
        if (shown == null || !_samePool(shown, question.choices)) return null;
        questions.add(
          Question(
            id: question.id,
            prompt: question.prompt,
            choices: shown,
            answerIndex: shown.indexOf(question.choices[question.answerIndex]),
            explanation: question.explanation,
            category: question.category,
          ),
        );
      }
      exercises.add(
        Exercise(
          id: original.id,
          part: original.part,
          documents: original.documents,
          questions: questions,
          audioAsset: original.audioAsset,
        ),
      );
    }
    return exercises;
  }

  static bool _samePool(List<String> a, List<String> b) =>
      a.length == b.length && ([...a]..sort()).join('\u0000') == ([...b]..sort()).join('\u0000');
}
