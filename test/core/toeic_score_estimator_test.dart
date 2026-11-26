import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/core/scoring/toeic_score_estimator.dart';

void main() {
  test('le score estimé reste dans les bornes TOEIC', () {
    expect(ToeicScoreEstimator.estimateReadingScore(0), 5);
    expect(ToeicScoreEstimator.estimateReadingScore(1), 495);
    expect(ToeicScoreEstimator.estimateTotalScore(1), 990);
  });
}
