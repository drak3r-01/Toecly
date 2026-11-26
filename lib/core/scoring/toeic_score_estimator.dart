/// Estimated range of the TOEIC Reading score.
class ScoreRange {
  const ScoreRange(this.min, this.max);

  final int min;
  final int max;

  @override
  String toString() => '$min–$max';

  @override
  bool operator ==(Object other) => other is ScoreRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// Approximates the Reading score (5–495) from the success rate, by tiers.
///
/// This is an approximation of the official (secret) conversion table, so a
/// range is returned instead of a single misleading number. Listening is not
/// estimated.
class ToeicScoreEstimator {
  const ToeicScoreEstimator._();

  /// Upper bound of the success rate (inclusive) of each tier, with its score range.
  static const List<(double, ScoreRange)> tiers = [
    (0.10, ScoreRange(5, 60)),
    (0.20, ScoreRange(65, 120)),
    (0.30, ScoreRange(125, 185)),
    (0.40, ScoreRange(190, 240)),
    (0.50, ScoreRange(245, 290)),
    (0.60, ScoreRange(295, 345)),
    (0.70, ScoreRange(350, 395)),
    (0.80, ScoreRange(400, 440)),
    (0.90, ScoreRange(445, 475)),
    (1.00, ScoreRange(480, 495)),
  ];

  /// [successRate] is between 0.0 and 1.0 (values outside are clamped).
  static ScoreRange estimateReadingRange(double successRate) {
    final rate = successRate.clamp(0.0, 1.0);
    return tiers.firstWhere((tier) => rate <= tier.$1).$2;
  }
}
