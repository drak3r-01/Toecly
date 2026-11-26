/// Shape of the mock exam, following the official TOEIC Reading section.
class MockExamBlueprint {
  const MockExamBlueprint({
    this.part5Questions = 30,
    this.part6Exercises = 4,
    this.part7SingleExercises = 10,
    this.part7DoubleExercises = 2,
    this.part7TripleExercises = 3,
    this.duration = const Duration(minutes: 75),
  });

  /// The official format: 30 + 4x4 + 29 + 5x5 = 100 questions in 75 minutes.
  static const official = MockExamBlueprint();

  /// Total number of questions of the official exam (the Part 7 single-document
  /// sets hold 29 questions in total, so a drawn exam can differ slightly).
  static const officialQuestionCount = 100;

  final int part5Questions;
  final int part6Exercises;
  final int part7SingleExercises;
  final int part7DoubleExercises;
  final int part7TripleExercises;
  final Duration duration;
}
