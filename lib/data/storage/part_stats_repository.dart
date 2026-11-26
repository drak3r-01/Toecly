import 'package:shared_preferences/shared_preferences.dart';

import '../../core/toeic_part.dart';

/// Compteurs cumulés par partie (jamais purgés, contrairement à l'historique).
class PartStatsRepository {
  PartStatsRepository(this._prefs);

  final SharedPreferences _prefs;

  String _answeredKey(ToeicPart part) => 'stats_part${part.number}_answered';
  String _correctKey(ToeicPart part) => 'stats_part${part.number}_correct';

  int answered(ToeicPart part) => _prefs.getInt(_answeredKey(part)) ?? 0;
  int correct(ToeicPart part) => _prefs.getInt(_correctKey(part)) ?? 0;

  /// Taux de réussite (0.0 à 1.0), ou 0 si aucune réponse enregistrée.
  double successRate(ToeicPart part) {
    final total = answered(part);
    return total == 0 ? 0 : correct(part) / total;
  }

  Future<void> recordAnswer(ToeicPart part, {required bool isCorrect}) async {
    await _prefs.setInt(_answeredKey(part), answered(part) + 1);
    if (isCorrect) await _prefs.setInt(_correctKey(part), correct(part) + 1);
  }
}
