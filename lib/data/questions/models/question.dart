import '../../../core/toeic_part.dart';

/// Un texte de support (Parties 6 et 7) affiché avec une ou plusieurs questions.
class Passage {
  const Passage({this.title, required this.text});

  final String? title;
  final String text;

  factory Passage.fromJson(Map<String, dynamic> json) => Passage(
        title: json['title'] as String?,
        text: json['text'] as String,
      );
}

/// Une question à choix multiples, prête à être posée.
class Question {
  const Question({
    required this.id,
    required this.part,
    required this.prompt,
    required this.choices,
    required this.correctChoiceIndex,
    required this.explanation,
    this.passages = const [],
    this.audioAsset,
  });

  /// Identifiant unique ET stable (sert à retrouver les questions ratées).
  final String id;
  final ToeicPart part;
  final String prompt;
  final List<String> choices;

  /// Position (à partir de 0) de la bonne réponse dans [choices].
  final int correctChoiceIndex;
  final String explanation;

  /// Textes à lire avant de répondre (vide pour la Partie 5).
  final List<Passage> passages;

  /// Chemin d'un fichier audio (réservé au futur mode listening).
  final String? audioAsset;
}
