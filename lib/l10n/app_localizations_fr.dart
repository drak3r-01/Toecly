// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Toecly';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPractice => 'Entraînement';

  @override
  String get navMockExam => 'Examen blanc';

  @override
  String get navReview => 'Révision';

  @override
  String get navSettings => 'Réglages';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get practiceDescription =>
      'Choisis tes parties et le nombre de questions.';

  @override
  String mockExamDescription(int questions, int minutes) {
    return 'Simulation complète du Reading : $questions questions en $minutes minutes, correction à la fin.';
  }

  @override
  String get reviewDescription => 'Rejoue les questions que tu as ratées.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageAuto => 'Système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get estimatedScoreTitle => 'Score Reading estimé';

  @override
  String estimatedScoreRange(int min, int max) {
    return '$min–$max / 495';
  }

  @override
  String get estimatedScoreEmpty => '— / 495';

  @override
  String get estimatedScoreDisclaimer =>
      'Approximation par paliers, d\'après ton taux de réussite. Le Listening n\'est pas estimé.';

  @override
  String get resumePractice => 'Reprendre l\'entraînement';

  @override
  String partLabel(int number, String name) {
    return 'Partie $number · $name';
  }

  @override
  String get part5Name => 'Phrases à compléter';

  @override
  String get part6Name => 'Textes à compléter';

  @override
  String get part7Name => 'Compréhension de textes';

  @override
  String successRatePercent(int percent) {
    return '$percent %';
  }

  @override
  String documentTab(int number) {
    return 'Document $number';
  }

  @override
  String get docEmail => 'E-mail';

  @override
  String get docLetter => 'Lettre';

  @override
  String get docMemo => 'Note de service';

  @override
  String get docNotice => 'Avis';

  @override
  String get docAdvertisement => 'Publicité';

  @override
  String get docArticle => 'Article';

  @override
  String get docTextMessage => 'SMS';

  @override
  String get docOnlineChat => 'Discussion en ligne';

  @override
  String get docForm => 'Formulaire';

  @override
  String get docInvoice => 'Facture';

  @override
  String get docSchedule => 'Planning';

  @override
  String get docJobAd => 'Offre d\'emploi';

  @override
  String get docWebPage => 'Page web';

  @override
  String get docReview => 'Avis client';

  @override
  String get categoryGrammar => 'Grammaire';

  @override
  String get categoryVocabulary => 'Vocabulaire';

  @override
  String get categoryConnector => 'Mots de liaison';

  @override
  String get categorySentenceInsertion => 'Insertion de phrase';

  @override
  String get categoryMainIdea => 'Idée principale';

  @override
  String get categoryDetail => 'Détail';

  @override
  String get categoryInference => 'Inférence';

  @override
  String get categoryPurpose => 'Objectif';

  @override
  String get categoryNotTrue => 'Faux (NOT)';

  @override
  String get categoryVocabularyInContext => 'Vocabulaire en contexte';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get quizNext => 'Suivant';

  @override
  String get quizFinish => 'Terminer';

  @override
  String get quizClose => 'Fermer';

  @override
  String get quizCorrect => 'Bonne réponse !';

  @override
  String get quizIncorrect => 'Mauvaise réponse';

  @override
  String get quizExplanation => 'Explication';

  @override
  String quizBlankLabel(int number) {
    return 'Blanc $number';
  }

  @override
  String get quizSummaryTitle => 'Session terminée';

  @override
  String quizSummaryScore(int correct, int total) {
    return '$correct / $total bonnes réponses';
  }

  @override
  String get quizBackToPractice => 'Retour à l\'entraînement';

  @override
  String get quizEmpty => 'Aucune question disponible pour cette sélection.';

  @override
  String get quizLoadError => 'Impossible de charger les questions.';

  @override
  String get practicePartsLabel => 'Parties';

  @override
  String get practiceCountLabel => 'Nombre de questions';

  @override
  String get practiceStart => 'Commencer';

  @override
  String get examStart => 'Commencer l\'examen';

  @override
  String get examSubmit => 'Rendre';

  @override
  String get examPrevious => 'Précédent';

  @override
  String get examKeepWorking => 'Continuer';

  @override
  String get examSubmitTitle => 'Rendre l\'examen ?';

  @override
  String examUnanswered(int count) {
    return 'Questions sans réponse : $count';
  }

  @override
  String get examQuitTitle => 'Quitter l\'examen ?';

  @override
  String get examQuitMessage => 'Votre progression sera perdue.';

  @override
  String get examQuit => 'Quitter';

  @override
  String get examResultTitle => 'Résultat de l\'examen blanc';

  @override
  String get examTimeUp => 'Temps écoulé : votre examen a été rendu.';

  @override
  String examTimeUsed(int minutes) {
    return 'Temps utilisé : $minutes min';
  }

  @override
  String get examByPart => 'Par partie';

  @override
  String get examFilterAll => 'Toutes';

  @override
  String get examFilterMistakes => 'Erreurs';

  @override
  String get examNotAnswered => 'Sans réponse';

  @override
  String get examBackToExam => 'Terminer';
}
