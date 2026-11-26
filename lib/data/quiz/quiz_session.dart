import '../exercises/models.dart';

/// Progress through a list of exercises, one question at a time, with
/// immediate correction: an answer is locked as soon as it is given.
/// Pure Dart (no Flutter), so the engine is unit-tested without a UI.
class QuizSession {
  QuizSession(List<Exercise> exercises) : exercises = List.unmodifiable(exercises);

  final List<Exercise> exercises;
  final Map<String, int> _answers = {};
  int _exerciseIndex = 0;
  int _questionIndex = 0;

  bool get isEmpty => exercises.isEmpty;
  bool get isFinished => _exerciseIndex >= exercises.length;

  Exercise get exercise => exercises[_exerciseIndex];
  int get questionIndex => _questionIndex;
  Question get question => exercise.questions[_questionIndex];

  int get totalQuestions => exercises.fold(0, (sum, e) => sum + e.questions.length);

  /// Number of questions already answered (also the index of the current one).
  int get answeredCount => _answers.length;

  int get correctCount {
    var correct = 0;
    for (final exercise in exercises) {
      for (final question in exercise.questions) {
        if (_answers[question.id] == question.answerIndex) correct++;
      }
    }
    return correct;
  }

  /// Choice picked for [question], or null if it is not answered yet.
  int? answerFor(Question question) => _answers[question.id];

  bool get isCurrentAnswered => !isFinished && _answers.containsKey(question.id);

  bool get isLastQuestion =>
      _exerciseIndex == exercises.length - 1 && _questionIndex == exercise.questions.length - 1;

  /// Records the answer to the current question. A second answer is ignored.
  void select(int choiceIndex) {
    if (isFinished || isCurrentAnswered) return;
    if (choiceIndex < 0 || choiceIndex >= question.choices.length) {
      throw RangeError.index(choiceIndex, question.choices, 'choiceIndex');
    }
    _answers[question.id] = choiceIndex;
  }

  /// Moves to the next question (or exercise). Only possible once the current
  /// question is answered; after the last one the session is finished.
  void advance() {
    if (!isCurrentAnswered) return;
    if (_questionIndex < exercise.questions.length - 1) {
      _questionIndex++;
    } else {
      _exerciseIndex++;
      _questionIndex = 0;
    }
  }
}
