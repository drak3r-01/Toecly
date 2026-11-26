import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/exercises/models.dart';

Question fakeQuestion(String id, {QuestionCategory? category}) => Question(
      id: id,
      prompt: 'prompt $id',
      choices: const ['a', 'b', 'c', 'd'],
      answerIndex: 0,
      explanation: 'because',
      category: category,
    );

Exercise fakeExercise(
  ToeicPart part,
  String id, {
  int documents = 0,
  int questions = 1,
}) =>
    Exercise(
      id: id,
      part: part,
      documents: [
        for (var i = 0; i < documents; i++)
          ExerciseDocument(type: DocumentType.email, title: 'Doc ${i + 1}', text: 'Text ${i + 1}'),
      ],
      questions: [
        for (var i = 1; i <= questions; i++)
          fakeQuestion(part == ToeicPart.part5 ? id : '$id#$i'),
      ],
    );

/// A stock large enough to draw a full official mock exam.
List<Exercise> fakeFullStock() => [
      for (var i = 0; i < 40; i++) fakeExercise(ToeicPart.part5, 'p5-$i'),
      for (var i = 0; i < 6; i++) fakeExercise(ToeicPart.part6, 'p6-$i', documents: 1, questions: 4),
      for (var i = 0; i < 12; i++)
        fakeExercise(ToeicPart.part7, 'p7s-$i', documents: 1, questions: 3),
      for (var i = 0; i < 4; i++)
        fakeExercise(ToeicPart.part7, 'p7d-$i', documents: 2, questions: 5),
      for (var i = 0; i < 5; i++)
        fakeExercise(ToeicPart.part7, 'p7t-$i', documents: 3, questions: 5),
    ];
