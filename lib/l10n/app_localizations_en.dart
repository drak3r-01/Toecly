// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Toecly';

  @override
  String get navHome => 'Home';

  @override
  String get navPractice => 'Practice';

  @override
  String get navMockExam => 'Mock exam';

  @override
  String get navReview => 'Review';

  @override
  String get navSettings => 'Settings';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get practiceDescription =>
      'Choose your parts and the number of questions.';

  @override
  String mockExamDescription(int questions, int minutes) {
    return 'Full Reading simulation: $questions questions in $minutes minutes, with the correction at the end.';
  }

  @override
  String get reviewDescription => 'Replay the questions you missed.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageAuto => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get estimatedScoreTitle => 'Estimated Reading score';

  @override
  String estimatedScoreRange(int min, int max) {
    return '$min–$max / 495';
  }

  @override
  String get estimatedScoreEmpty => '— / 495';

  @override
  String get estimatedScoreDisclaimer =>
      'Approximation by tiers, based on your success rate. Listening is not estimated.';

  @override
  String get resumePractice => 'Resume practice';

  @override
  String partLabel(int number, String name) {
    return 'Part $number · $name';
  }

  @override
  String get part5Name => 'Incomplete sentences';

  @override
  String get part6Name => 'Text completion';

  @override
  String get part7Name => 'Reading comprehension';

  @override
  String successRatePercent(int percent) {
    return '$percent%';
  }

  @override
  String documentTab(int number) {
    return 'Document $number';
  }

  @override
  String get docEmail => 'Email';

  @override
  String get docLetter => 'Letter';

  @override
  String get docMemo => 'Memo';

  @override
  String get docNotice => 'Notice';

  @override
  String get docAdvertisement => 'Advertisement';

  @override
  String get docArticle => 'Article';

  @override
  String get docTextMessage => 'Text message';

  @override
  String get docOnlineChat => 'Online chat';

  @override
  String get docForm => 'Form';

  @override
  String get docInvoice => 'Invoice';

  @override
  String get docSchedule => 'Schedule';

  @override
  String get docJobAd => 'Job ad';

  @override
  String get docWebPage => 'Web page';

  @override
  String get docReview => 'Review';

  @override
  String get categoryGrammar => 'Grammar';

  @override
  String get categoryVocabulary => 'Vocabulary';

  @override
  String get categoryConnector => 'Connectors';

  @override
  String get categorySentenceInsertion => 'Sentence insertion';

  @override
  String get categoryMainIdea => 'Main idea';

  @override
  String get categoryDetail => 'Detail';

  @override
  String get categoryInference => 'Inference';

  @override
  String get categoryPurpose => 'Purpose';

  @override
  String get categoryNotTrue => 'NOT true';

  @override
  String get categoryVocabularyInContext => 'Vocabulary in context';

  @override
  String quizQuestionCounter(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get quizNext => 'Next';

  @override
  String get quizFinish => 'Finish';

  @override
  String get quizClose => 'Close';

  @override
  String get quizCorrect => 'Correct!';

  @override
  String get quizIncorrect => 'Incorrect';

  @override
  String get quizExplanation => 'Explanation';

  @override
  String quizBlankLabel(int number) {
    return 'Blank $number';
  }

  @override
  String get quizSummaryTitle => 'Session complete';

  @override
  String quizSummaryScore(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String get quizBackToPractice => 'Back to practice';

  @override
  String get quizEmpty => 'No questions available for this selection.';

  @override
  String get quizLoadError => 'The questions could not be loaded.';

  @override
  String get practicePartsLabel => 'Parts';

  @override
  String get practiceCountLabel => 'Number of questions';

  @override
  String get practiceStart => 'Start';

  @override
  String get examStart => 'Start the exam';

  @override
  String get examSubmit => 'Submit';

  @override
  String get examPrevious => 'Previous';

  @override
  String get examKeepWorking => 'Keep working';

  @override
  String get examSubmitTitle => 'Submit the exam?';

  @override
  String examUnanswered(int count) {
    return 'Unanswered questions: $count';
  }

  @override
  String get examQuitTitle => 'Quit the exam?';

  @override
  String get examQuitMessage => 'Your progress will be lost.';

  @override
  String get examQuit => 'Quit';

  @override
  String get examResultTitle => 'Mock exam result';

  @override
  String get examTimeUp => 'Time is up: your exam was submitted.';

  @override
  String examTimeUsed(int minutes) {
    return 'Time used: $minutes min';
  }

  @override
  String get examByPart => 'By part';

  @override
  String get examFilterAll => 'All';

  @override
  String get examFilterMistakes => 'Mistakes';

  @override
  String get examNotAnswered => 'Not answered';

  @override
  String get examBackToExam => 'Done';
}
