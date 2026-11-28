import '../exercises/models.dart';
import 'exam_snapshot.dart';
import 'quiz_session.dart';

/// A practice or review session in progress, saved after every step so it can be resumed
/// later (the user left, or Android killed the app). Pure Dart, stored as JSON.
class QuizSnapshot {
  const QuizSnapshot({
    required this.location,
    required this.exerciseIds,
    required this.choices,
    required this.answers,
    required this.exerciseIndex,
    required this.questionIndex,
  });

  /// Route that reopens the session (without the resume flag), e.g. `/quiz?parts=5&count=10`.
  final String location;
  final List<String> exerciseIds;

  /// Choices as displayed (already shuffled), by question id.
  final Map<String, List<String>> choices;
  final Map<String, int> answers;
  final int exerciseIndex;
  final int questionIndex;

  /// Questions answered so far, and in total.
  int get answeredCount => answers.length;
  int get totalQuestions => choices.length;

  factory QuizSnapshot.capture(QuizSession session, {required String location}) => QuizSnapshot(
    location: location,
    exerciseIds: [for (final e in session.exercises) e.id],
    choices: {
      for (final e in session.exercises)
        for (final q in e.questions) q.id: List.of(q.choices),
    },
    answers: session.answers,
    exerciseIndex: session.exerciseIndex,
    questionIndex: session.questionIndex,
  );

  Map<String, dynamic> toJson() => {
    'location': location,
    'exerciseIds': exerciseIds,
    'choices': choices,
    'answers': answers,
    'exerciseIndex': exerciseIndex,
    'questionIndex': questionIndex,
  };

  /// Throws when the data is not shaped like a snapshot.
  factory QuizSnapshot.fromJson(Map<String, dynamic> json) => QuizSnapshot(
    location: json['location'] as String,
    exerciseIds: (json['exerciseIds'] as List).cast<String>(),
    choices: {
      for (final e in (json['choices'] as Map).entries)
        e.key as String: (e.value as List).cast<String>(),
    },
    answers: {for (final e in (json['answers'] as Map).entries) e.key as String: e.value as int},
    exerciseIndex: json['exerciseIndex'] as int,
    questionIndex: json['questionIndex'] as int,
  );

  /// The session as it was, rebuilt on the current [bank]; null when it cannot be
  /// reproduced (bank changed, or the saved position is out of range).
  ({List<Exercise> exercises, QuizSession session})? restore(Iterable<Exercise> bank) {
    final exercises = restoreExercises(bank, exerciseIds, choices);
    if (exercises == null || exerciseIndex < 0 || exerciseIndex >= exercises.length) return null;
    if (questionIndex < 0 || questionIndex >= exercises[exerciseIndex].questions.length) {
      return null;
    }
    return (
      exercises: exercises,
      session: QuizSession.restore(
        exercises,
        answers: answers,
        exerciseIndex: exerciseIndex,
        questionIndex: questionIndex,
      ),
    );
  }
}
