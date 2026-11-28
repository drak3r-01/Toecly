import 'package:flutter_test/flutter_test.dart';
import 'package:toecly/data/storage/daily_progress_repository.dart';
import 'package:toecly/data/storage/local_store.dart';

void main() {
  late DailyProgressRepository repository;
  final today = DateTime(2026, 11, 28, 15);

  setUp(() => repository = DailyProgressRepository(InMemoryStore()));

  Future<void> reach(DateTime day) => repository.add(repository.goal, day);

  test('counts answers per day and defaults to a goal of 10', () async {
    expect(repository.goal, 10);
    await repository.add(3, today);
    await repository.add(2, today);
    expect(repository.answeredOn(today), 5);
    expect(repository.answeredOn(DateTime(2026, 11, 27)), 0);
  });

  test('streak counts consecutive days with the goal reached', () async {
    await reach(today);
    await reach(today.subtract(const Duration(days: 1)));
    await reach(today.subtract(const Duration(days: 2)));
    await reach(today.subtract(const Duration(days: 4))); // a gap ends the streak
    expect(repository.streak(today), 3);
  });

  test('a day not over yet does not break the streak', () async {
    await reach(today.subtract(const Duration(days: 1)));
    await repository.add(2, today); // goal not reached yet today
    expect(repository.streak(today), 1);
  });

  test('a missed yesterday resets the streak', () async {
    await reach(today.subtract(const Duration(days: 2)));
    expect(repository.streak(today), 0);
  });

  test('the goal is stored and old days are forgotten', () async {
    await repository.setGoal(20);
    expect(repository.goal, 20);
    for (var i = 0; i < DailyProgressRepository.maxDays + 5; i++) {
      await repository.add(1, DateTime(2024).add(Duration(days: i)));
    }
    expect(repository.answeredOn(DateTime(2024)), 0);
    expect(repository.answeredOn(DateTime(2024).add(const Duration(days: 404))), 1);
  });
}
