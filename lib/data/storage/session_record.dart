import '../../core/toeic_part.dart';

enum SessionMode {
  practice,
  mockExam,
  review;

  /// Training shows the correction after each question; the exam only at the end.
  bool get revealsAnswerImmediately => this != SessionMode.mockExam;
}

/// Summary of a finished session.
class SessionRecord {
  const SessionRecord({
    required this.mode,
    required this.finishedAt,
    required this.parts,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.durationSeconds,
  });

  final SessionMode mode;
  final DateTime finishedAt;
  final Set<ToeicPart> parts;
  final int totalQuestions;
  final int correctAnswers;
  final int durationSeconds;

  double get successRate => totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'finishedAt': finishedAt.toIso8601String(),
        'parts': [for (final part in parts) part.number],
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'durationSeconds': durationSeconds,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        mode: SessionMode.values.byName(json['mode'] as String),
        finishedAt: DateTime.parse(json['finishedAt'] as String),
        parts: {for (final n in (json['parts'] as List).cast<int>()) ToeicPart.fromNumber(n)},
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        durationSeconds: json['durationSeconds'] as int,
      );
}
