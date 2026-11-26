import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/scoring/toeic_score_estimator.dart';

void main() {
  test('bounds: 0% starts at 5, 100% ends at 495', () {
    expect(ToeicScoreEstimator.estimateReadingRange(0).min, 5);
    expect(ToeicScoreEstimator.estimateReadingRange(1).max, 495);
  });

  test('rates outside 0..1 are clamped', () {
    expect(ToeicScoreEstimator.estimateReadingRange(-3), ToeicScoreEstimator.estimateReadingRange(0));
    expect(ToeicScoreEstimator.estimateReadingRange(7), ToeicScoreEstimator.estimateReadingRange(1));
  });

  test('a tier boundary belongs to the lower tier', () {
    expect(ToeicScoreEstimator.estimateReadingRange(0.5), const ScoreRange(245, 290));
    expect(ToeicScoreEstimator.estimateReadingRange(0.51), const ScoreRange(295, 345));
  });

  test('tiers are increasing and never overlap', () {
    final tiers = ToeicScoreEstimator.tiers;
    for (var i = 1; i < tiers.length; i++) {
      expect(tiers[i].$1, greaterThan(tiers[i - 1].$1));
      expect(tiers[i].$2.min, greaterThan(tiers[i - 1].$2.max));
    }
    expect(tiers.last.$1, 1.0);
  });

  test('a range prints as min–max', () {
    expect(const ScoreRange(245, 290).toString(), '245–290');
  });
}
