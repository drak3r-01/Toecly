import '../../core/toeic_part.dart';
import '../exercises/models.dart';

/// A question of the exam together with its exercise (documents, part).
class ExamEntry {
  const ExamEntry(this.exercise, this.questionIndex);

  final Exercise exercise;
  final int questionIndex;

  Question get question => exercise.questions[questionIndex];
}

/// A mock exam in progress: free navigation, answers can be changed until the
/// exam is submitted, and the correction only exists after that.
/// Pure Dart (no Flutter), like [QuizSession].
class ExamSession {
  ExamSession(List<Exercise> exercises)
      : exercises = List.unmodifiable(exercises),
        entries = List.unmodifiable([
          for (final exercise in exercises)
            for (var i = 0; i < exercise.questions.length; i++) ExamEntry(exercise, i),
        ]);

  final List<Exercise> exercises;

  /// Every question, in exam order.
  final List<ExamEntry> entries;

  final Map<String, int> _answers = {};
  int _current = 0;
  bool _submitted = false;

  bool get isEmpty => entries.isEmpty;
  bool get isSubmitted => _submitted;
  int get totalQuestions => entries.length;
  int get currentIndex => _current;
  ExamEntry get current => entries[_current];

  int? answerFor(Question question) => _answers[question.id];

  /// Choices already picked, by question id.
  Map<String, int> get answers => Map.unmodifiable(_answers);

  int get answeredCount => _answers.length;
  int get unansweredCount => totalQuestions - answeredCount;

  /// Picks (or changes) the answer to the current question. Locked after [submit].
  void select(int choiceIndex) {
    if (_submitted) return;
    if (choiceIndex < 0 || choiceIndex >= current.question.choices.length) {
      throw RangeError.index(choiceIndex, current.question.choices, 'choiceIndex');
    }
    _answers[current.question.id] = choiceIndex;
  }

  void goTo(int index) {
    if (index >= 0 && index < totalQuestions) _current = index;
  }

  void next() => goTo(_current + 1);
  void previous() => goTo(_current - 1);

  void submit() => _submitted = true;

  bool isCorrect(ExamEntry entry) => _answers[entry.question.id] == entry.question.answerIndex;

  int get correctCount => entries.where(isCorrect).length;

  int totalFor(ToeicPart part) => entries.where((e) => e.exercise.part == part).length;

  int correctFor(ToeicPart part) =>
      entries.where((e) => e.exercise.part == part && isCorrect(e)).length;

  double get successRate => totalQuestions == 0 ? 0 : correctCount / totalQuestions;
}
