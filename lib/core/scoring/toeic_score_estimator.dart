/// Estimation du score TOEIC.
///
/// PLACEHOLDER : formule linéaire simple, à remplacer par la vraie méthode
/// (table de conversion officielle approchée, pondération par partie…).
class ToeicScoreEstimator {
  const ToeicScoreEstimator._();

  static const int readingMax = 495;
  static const int totalMax = 990;

  /// Score Reading estimé (5 à 495, par pas de 5) à partir du taux de réussite (0.0 à 1.0).
  static int estimateReadingScore(double successRate) {
    final raw = 5 + successRate.clamp(0.0, 1.0) * (readingMax - 5);
    return (raw / 5).round() * 5;
  }

  /// Score total estimé sur 990 : sans listening, on suppose le même niveau qu'en reading.
  static int estimateTotalScore(double readingSuccessRate) =>
      estimateReadingScore(readingSuccessRate) * 2;
}
