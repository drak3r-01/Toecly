import 'package:shared_preferences/shared_preferences.dart';

/// Identifiants des questions ratées à réviser (la plus récente en premier).
/// Au-delà de [maxMissedQuestions], les plus anciennes sont purgées.
class MissedQuestionsRepository {
  MissedQuestionsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'missed_question_ids';
  static const maxMissedQuestions = 500;

  List<String> loadIds() => _prefs.getStringList(_key) ?? const [];

  Future<void> markMissed(String questionId) {
    final updated = [questionId, ...loadIds().where((id) => id != questionId)]
        .take(maxMissedQuestions)
        .toList();
    return _prefs.setStringList(_key, updated);
  }

  /// À appeler quand l'utilisateur réussit enfin la question en révision.
  Future<void> markMastered(String questionId) =>
      _prefs.setStringList(_key, loadIds().where((id) => id != questionId).toList());
}
