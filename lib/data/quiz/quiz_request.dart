import '../../core/toeic_part.dart';

/// What to draw for a session: parts and a question budget.
/// Encoded in the `/quiz` URL so a session can be opened from any screen.
class QuizRequest {
  QuizRequest({required Iterable<ToeicPart> parts, required this.questionCount})
    : parts = (parts.toList()..sort((a, b) => a.number.compareTo(b.number)));

  final List<ToeicPart> parts;
  final int questionCount;

  static const int defaultQuestionCount = 10;

  /// Reads `parts=5,6&count=10`. Unknown values are dropped; no valid part means all Reading parts.
  factory QuizRequest.fromQuery(Map<String, String> query) {
    final parts = <ToeicPart>{};
    for (final raw in (query['parts'] ?? '').split(',')) {
      final number = int.tryParse(raw);
      if (number == null) continue;
      final matches = ToeicPart.readingParts.where((p) => p.number == number);
      if (matches.isNotEmpty) parts.add(matches.first);
    }
    final count = int.tryParse(query['count'] ?? '');
    return QuizRequest(
      parts: parts.isEmpty ? ToeicPart.readingParts : parts,
      questionCount: count != null && count > 0 ? count : defaultQuestionCount,
    );
  }

  String get location => '/quiz?parts=${parts.map((p) => p.number).join(',')}&count=$questionCount';

  @override
  bool operator ==(Object other) =>
      other is QuizRequest && other.questionCount == questionCount && _sameParts(other);

  bool _sameParts(QuizRequest other) =>
      parts.length == other.parts.length &&
      Iterable<int>.generate(parts.length).every((i) => parts[i] == other.parts[i]);

  @override
  int get hashCode => Object.hash(questionCount, Object.hashAll(parts));
}
