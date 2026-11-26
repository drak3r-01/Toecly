import '../core/toeic_part.dart';
import '../data/exercises/models.dart';
import 'app_localizations.dart';

/// Localized display names for the domain enums.
extension PartLabel on AppLocalizations {
  String partName(ToeicPart part) => switch (part) {
        ToeicPart.part5 => part5Name,
        ToeicPart.part6 => part6Name,
        ToeicPart.part7 => part7Name,
        _ => 'Part ${part.number}',
      };

  String partTitle(ToeicPart part) => partLabel(part.number, partName(part));

  String documentTypeName(DocumentType type) => switch (type) {
        DocumentType.email => docEmail,
        DocumentType.letter => docLetter,
        DocumentType.memo => docMemo,
        DocumentType.notice => docNotice,
        DocumentType.advertisement => docAdvertisement,
        DocumentType.article => docArticle,
        DocumentType.textMessage => docTextMessage,
        DocumentType.onlineChat => docOnlineChat,
        DocumentType.form => docForm,
        DocumentType.invoice => docInvoice,
        DocumentType.schedule => docSchedule,
        DocumentType.jobAd => docJobAd,
        DocumentType.webPage => docWebPage,
        DocumentType.review => docReview,
      };

  String categoryName(QuestionCategory category) => switch (category) {
        QuestionCategory.grammar => categoryGrammar,
        QuestionCategory.vocabulary => categoryVocabulary,
        QuestionCategory.connector => categoryConnector,
        QuestionCategory.sentenceInsertion => categorySentenceInsertion,
        QuestionCategory.mainIdea => categoryMainIdea,
        QuestionCategory.detail => categoryDetail,
        QuestionCategory.inference => categoryInference,
        QuestionCategory.purpose => categoryPurpose,
        QuestionCategory.notTrue => categoryNotTrue,
        QuestionCategory.vocabularyInContext => categoryVocabularyInContext,
      };
}
