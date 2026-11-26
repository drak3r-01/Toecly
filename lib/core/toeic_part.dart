/// Section de l'examen TOEIC.
enum ExamSection { listening, reading }

/// Les 7 parties du TOEIC. Seules les parties de lecture (5 à 7) sont
/// utilisables pour l'instant ; les parties d'écoute sont déjà déclarées
/// pour que l'ajout du listening ne demande aucun changement de structure.
enum ToeicPart {
  part1(1, ExamSection.listening, 'Photographies'),
  part2(2, ExamSection.listening, 'Question-Réponse'),
  part3(3, ExamSection.listening, 'Conversations'),
  part4(4, ExamSection.listening, 'Exposés'),
  part5(5, ExamSection.reading, 'Phrases à compléter'),
  part6(6, ExamSection.reading, 'Textes à compléter'),
  part7(7, ExamSection.reading, 'Compréhension de textes');

  const ToeicPart(this.number, this.section, this.label);

  final int number;
  final ExamSection section;
  final String label;

  /// Dossier des questions dans les assets : `assets/questions/part5/`.
  String get assetFolder => 'assets/questions/part$number/';

  bool get isAvailable => section == ExamSection.reading;

  static List<ToeicPart> get readingParts =>
      values.where((part) => part.section == ExamSection.reading).toList();

  static ToeicPart fromNumber(int number) => values.firstWhere(
        (part) => part.number == number,
        orElse: () => throw FormatException('Partie TOEIC inconnue : $number'),
      );
}
