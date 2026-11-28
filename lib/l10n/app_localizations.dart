import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Toecly'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navMockExam.
  ///
  /// In en, this message translates to:
  /// **'Mock exam'**
  String get navMockExam;

  /// No description provided for @navReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get navReview;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @practiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your parts and the number of questions.'**
  String get practiceDescription;

  /// No description provided for @mockExamDescription.
  ///
  /// In en, this message translates to:
  /// **'Full Reading simulation: {questions} questions in {minutes} minutes, with the correction at the end.'**
  String mockExamDescription(int questions, int minutes);

  /// No description provided for @reviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Replay the questions you missed.'**
  String get reviewDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageAuto;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @estimatedScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated Reading score'**
  String get estimatedScoreTitle;

  /// No description provided for @estimatedScoreRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} / 495'**
  String estimatedScoreRange(int min, int max);

  /// No description provided for @estimatedScoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'— / 495'**
  String get estimatedScoreEmpty;

  /// No description provided for @estimatedScoreDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Approximation by tiers, based on your success rate. Listening is not estimated: the total assumes the same level as in Reading (× 2).'**
  String get estimatedScoreDisclaimer;

  /// No description provided for @resumePractice.
  ///
  /// In en, this message translates to:
  /// **'Resume practice'**
  String get resumePractice;

  /// No description provided for @partLabel.
  ///
  /// In en, this message translates to:
  /// **'Part {number} · {name}'**
  String partLabel(int number, String name);

  /// No description provided for @part5Name.
  ///
  /// In en, this message translates to:
  /// **'Incomplete sentences'**
  String get part5Name;

  /// No description provided for @part6Name.
  ///
  /// In en, this message translates to:
  /// **'Text completion'**
  String get part6Name;

  /// No description provided for @part7Name.
  ///
  /// In en, this message translates to:
  /// **'Reading comprehension'**
  String get part7Name;

  /// No description provided for @successRatePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String successRatePercent(int percent);

  /// No description provided for @documentTab.
  ///
  /// In en, this message translates to:
  /// **'Document {number}'**
  String documentTab(int number);

  /// No description provided for @docEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get docEmail;

  /// No description provided for @docLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get docLetter;

  /// No description provided for @docMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get docMemo;

  /// No description provided for @docNotice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get docNotice;

  /// No description provided for @docAdvertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get docAdvertisement;

  /// No description provided for @docArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get docArticle;

  /// No description provided for @docTextMessage.
  ///
  /// In en, this message translates to:
  /// **'Text message'**
  String get docTextMessage;

  /// No description provided for @docOnlineChat.
  ///
  /// In en, this message translates to:
  /// **'Online chat'**
  String get docOnlineChat;

  /// No description provided for @docForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get docForm;

  /// No description provided for @docInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get docInvoice;

  /// No description provided for @docSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get docSchedule;

  /// No description provided for @docJobAd.
  ///
  /// In en, this message translates to:
  /// **'Job ad'**
  String get docJobAd;

  /// No description provided for @docWebPage.
  ///
  /// In en, this message translates to:
  /// **'Web page'**
  String get docWebPage;

  /// No description provided for @docReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get docReview;

  /// No description provided for @categoryGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get categoryGrammar;

  /// No description provided for @categoryVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get categoryVocabulary;

  /// No description provided for @categoryConnector.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get categoryConnector;

  /// No description provided for @categorySentenceInsertion.
  ///
  /// In en, this message translates to:
  /// **'Sentence insertion'**
  String get categorySentenceInsertion;

  /// No description provided for @categoryMainIdea.
  ///
  /// In en, this message translates to:
  /// **'Main idea'**
  String get categoryMainIdea;

  /// No description provided for @categoryDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get categoryDetail;

  /// No description provided for @categoryInference.
  ///
  /// In en, this message translates to:
  /// **'Inference'**
  String get categoryInference;

  /// No description provided for @categoryPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get categoryPurpose;

  /// No description provided for @categoryNotTrue.
  ///
  /// In en, this message translates to:
  /// **'NOT true'**
  String get categoryNotTrue;

  /// No description provided for @categoryVocabularyInContext.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary in context'**
  String get categoryVocabularyInContext;

  /// No description provided for @quizQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String quizQuestionCounter(int current, int total);

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get quizFinish;

  /// No description provided for @quizClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get quizClose;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get quizIncorrect;

  /// No description provided for @quizExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get quizExplanation;

  /// No description provided for @quizBlankLabel.
  ///
  /// In en, this message translates to:
  /// **'Blank {number}'**
  String quizBlankLabel(int number);

  /// No description provided for @quizSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get quizSummaryTitle;

  /// No description provided for @quizSummaryScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String quizSummaryScore(int correct, int total);

  /// No description provided for @quizBackToPractice.
  ///
  /// In en, this message translates to:
  /// **'Back to practice'**
  String get quizBackToPractice;

  /// No description provided for @quizEmpty.
  ///
  /// In en, this message translates to:
  /// **'No questions available for this selection.'**
  String get quizEmpty;

  /// No description provided for @quizLoadError.
  ///
  /// In en, this message translates to:
  /// **'The questions could not be loaded.'**
  String get quizLoadError;

  /// No description provided for @practicePartsLabel.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get practicePartsLabel;

  /// No description provided for @practiceCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get practiceCountLabel;

  /// No description provided for @practiceStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get practiceStart;

  /// No description provided for @examStart.
  ///
  /// In en, this message translates to:
  /// **'Start the exam'**
  String get examStart;

  /// No description provided for @examSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get examSubmit;

  /// No description provided for @examPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get examPrevious;

  /// No description provided for @examKeepWorking.
  ///
  /// In en, this message translates to:
  /// **'Keep working'**
  String get examKeepWorking;

  /// No description provided for @examSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit the exam?'**
  String get examSubmitTitle;

  /// No description provided for @examUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered questions: {count}'**
  String examUnanswered(int count);

  /// No description provided for @examResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam in progress'**
  String get examResumeTitle;

  /// No description provided for @examResumeBody.
  ///
  /// In en, this message translates to:
  /// **'You left an exam before submitting it. The clock kept running.'**
  String get examResumeBody;

  /// No description provided for @examResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get examResume;

  /// No description provided for @examDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get examDiscard;

  /// No description provided for @examQuitTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit the exam?'**
  String get examQuitTitle;

  /// No description provided for @examQuitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost.'**
  String get examQuitMessage;

  /// No description provided for @examQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get examQuit;

  /// No description provided for @examResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock exam result'**
  String get examResultTitle;

  /// No description provided for @examTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time is up: your exam was submitted.'**
  String get examTimeUp;

  /// No description provided for @examTimeUsed.
  ///
  /// In en, this message translates to:
  /// **'Time used: {minutes} min'**
  String examTimeUsed(int minutes);

  /// No description provided for @examByPart.
  ///
  /// In en, this message translates to:
  /// **'By part'**
  String get examByPart;

  /// No description provided for @examFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get examFilterAll;

  /// No description provided for @examFilterMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get examFilterMistakes;

  /// No description provided for @examNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get examNotAnswered;

  /// No description provided for @examBackToExam.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get examBackToExam;

  /// No description provided for @reviewNothing.
  ///
  /// In en, this message translates to:
  /// **'No missed question to review. Well done!'**
  String get reviewNothing;

  /// No description provided for @reviewMissedCount.
  ///
  /// In en, this message translates to:
  /// **'Questions to review: {count}'**
  String reviewMissedCount(int count);

  /// No description provided for @practiceCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get practiceCustom;

  /// No description provided for @practiceCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Number (1–{max})'**
  String practiceCustomLabel(int max);

  /// No description provided for @quizBackToReview.
  ///
  /// In en, this message translates to:
  /// **'Back to review'**
  String get quizBackToReview;

  /// No description provided for @dashboardAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions answered: {count}'**
  String dashboardAnswered(int count);

  /// No description provided for @dashboardSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions: {count}'**
  String dashboardSessions(int count);

  /// No description provided for @resetProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get resetProgressLabel;

  /// No description provided for @resetProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Erase statistics, history and missed questions. Theme and language are kept.'**
  String get resetProgressHint;

  /// No description provided for @resetProgressButton.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgressButton;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get resetProgressMessage;

  /// No description provided for @resetProgressCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetProgressCancel;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetProgressConfirm;

  /// No description provided for @estimatedTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated total (Reading × 2)'**
  String get estimatedTotalTitle;

  /// No description provided for @estimatedTotalRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} / 990'**
  String estimatedTotalRange(int min, int max);

  /// No description provided for @estimatedTotalEmpty.
  ///
  /// In en, this message translates to:
  /// **'— / 990'**
  String get estimatedTotalEmpty;

  /// No description provided for @partDescription5.
  ///
  /// In en, this message translates to:
  /// **'Grammar and vocabulary in a single sentence.'**
  String get partDescription5;

  /// No description provided for @partDescription6.
  ///
  /// In en, this message translates to:
  /// **'Fill the blanks of a short text.'**
  String get partDescription6;

  /// No description provided for @partDescription7.
  ///
  /// In en, this message translates to:
  /// **'Read emails, ads and articles, then answer.'**
  String get partDescription7;

  /// No description provided for @questionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question available} other{{count} questions available}}'**
  String questionsAvailable(int count);

  /// No description provided for @practiceSelectionAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question in your selection} other{{count} questions in your selection}}'**
  String practiceSelectionAvailable(int count);

  /// No description provided for @questionBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Question bank'**
  String get questionBankTitle;

  /// No description provided for @questionBankHint.
  ///
  /// In en, this message translates to:
  /// **'Loaded on this device, counted when the app starts.'**
  String get questionBankHint;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @summaryGreat.
  ///
  /// In en, this message translates to:
  /// **'Outstanding. That is a real C1 performance.'**
  String get summaryGreat;

  /// No description provided for @summaryGood.
  ///
  /// In en, this message translates to:
  /// **'Solid work. Keep that rhythm going.'**
  String get summaryGood;

  /// No description provided for @summaryOk.
  ///
  /// In en, this message translates to:
  /// **'Getting there. Replay your misses to lock them in.'**
  String get summaryOk;

  /// No description provided for @summaryKeep.
  ///
  /// In en, this message translates to:
  /// **'Every mistake is a lesson. Review them and try again.'**
  String get summaryKeep;

  /// No description provided for @hapticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Vibrations'**
  String get hapticsLabel;

  /// No description provided for @hapticsHint.
  ///
  /// In en, this message translates to:
  /// **'A light vibration when you answer a question.'**
  String get hapticsHint;

  /// No description provided for @textSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSizeLabel;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeHuge.
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get textSizeHuge;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily goal (questions per day)'**
  String get dailyGoalLabel;

  /// No description provided for @dailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal'**
  String get dailyGoalTitle;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {goal} questions'**
  String dailyGoalProgress(int done, int goal);

  /// No description provided for @dailyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached, well done!'**
  String get dailyGoalReached;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Reach your goal to start a streak} =1{1-day streak} other{{days}-day streak}}'**
  String dailyStreak(int days);

  /// No description provided for @quizLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this session?'**
  String get quizLeaveTitle;

  /// No description provided for @quizLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your answers are already saved. You can pick up where you stopped from the home screen.'**
  String get quizLeaveMessage;

  /// No description provided for @quizLeaveStay.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get quizLeaveStay;

  /// No description provided for @quizLeaveSave.
  ///
  /// In en, this message translates to:
  /// **'Leave, resume later'**
  String get quizLeaveSave;

  /// No description provided for @quizLeaveDiscard.
  ///
  /// In en, this message translates to:
  /// **'Quit for good'**
  String get quizLeaveDiscard;

  /// No description provided for @dashboardResumeSession.
  ///
  /// In en, this message translates to:
  /// **'Resume your session ({done} / {total})'**
  String dashboardResumeSession(int done, int total);

  /// No description provided for @weakSpotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak spots'**
  String get weakSpotsTitle;

  /// No description provided for @weakSpotsHint.
  ///
  /// In en, this message translates to:
  /// **'Your lowest success rates (5 answers or more). Tap one to train on it.'**
  String get weakSpotsHint;

  /// No description provided for @weakSpotName.
  ///
  /// In en, this message translates to:
  /// **'Part {part} · {category}'**
  String weakSpotName(int part, String category);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
