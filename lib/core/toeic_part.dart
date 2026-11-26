/// Section of the TOEIC exam.
enum ExamSection { listening, reading }

/// The 7 TOEIC parts. Only the Reading parts (5 to 7) are usable for now; the
/// Listening parts are already declared so that adding them needs no structural change.
enum ToeicPart {
  part1(1, ExamSection.listening),
  part2(2, ExamSection.listening),
  part3(3, ExamSection.listening),
  part4(4, ExamSection.listening),
  part5(5, ExamSection.reading),
  part6(6, ExamSection.reading),
  part7(7, ExamSection.reading);

  const ToeicPart(this.number, this.section);

  final int number;
  final ExamSection section;

  /// Asset folder holding the lots of this part: `assets/questions/part5/`.
  String get assetFolder => 'assets/questions/part$number/';

  bool get isAvailable => section == ExamSection.reading;

  static List<ToeicPart> get readingParts =>
      values.where((part) => part.section == ExamSection.reading).toList();

  static ToeicPart fromNumber(int number) => values.firstWhere(
        (part) => part.number == number,
        orElse: () => throw FormatException('Unknown TOEIC part: $number'),
      );
}
