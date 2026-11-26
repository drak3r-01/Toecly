import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/toeic_part.dart';
import 'package:toecly/data/quiz/exam_session.dart';

import '../support/fixtures.dart';

void main() {
  ExamSession build() => ExamSession([
        fakeExercise(ToeicPart.part5, 'a'),
        fakeExercise(ToeicPart.part6, 'b', documents: 1, questions: 2),
      ]);

  test('questions are flattened in exam order', () {
    final session = build();
    expect(session.totalQuestions, 3);
    expect(session.entries.map((e) => e.question.id), ['a', 'b#1', 'b#2']);
  });

  test('navigation is free and stays within bounds', () {
    final session = build();
    session.previous();
    expect(session.currentIndex, 0);
    session.goTo(2);
    expect(session.current.question.id, 'b#2');
    session.next();
    expect(session.currentIndex, 2);
    session.goTo(99);
    expect(session.currentIndex, 2);
    session.previous();
    expect(session.currentIndex, 1);
  });

  test('an answer can be changed until the exam is submitted', () {
    final session = build();
    session.select(2);
    session.select(0);
    expect(session.answerFor(session.current.question), 0);
    expect(session.correctCount, 1);

    session.submit();
    session.select(3);
    expect(session.answerFor(session.current.question), 0);
  });

  test('counts answered, unanswered and correct answers per part', () {
    final session = build();
    session.select(0); // a: right
    session.goTo(1);
    session.select(1); // b#1: wrong (fake questions are right on choice 0)
    expect(session.answeredCount, 2);
    expect(session.unansweredCount, 1);
    expect(session.correctCount, 1);
    expect(session.totalFor(ToeicPart.part6), 2);
    expect(session.correctFor(ToeicPart.part5), 1);
    expect(session.correctFor(ToeicPart.part6), 0);
    expect(session.successRate, closeTo(1 / 3, 1e-9));
  });

  test('rejects a choice outside the question', () {
    expect(() => build().select(4), throwsRangeError);
  });
}
