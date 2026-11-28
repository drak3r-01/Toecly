import 'local_store.dart';

/// Questions answered per calendar day, the daily goal and the resulting streak.
class DailyProgressRepository {
  DailyProgressRepository(this._store);

  final LocalStore _store;

  static const _daysKey = 'daily_progress';
  static const _goalKey = 'daily_goal';
  static const defaultGoal = 10;
  static const goalChoices = [5, 10, 20, 30];

  /// Days older than this are forgotten, so the stored data stays small.
  static const maxDays = 400;

  int get goal {
    final data = _store.readJson(_goalKey);
    return data is int && data > 0 ? data : defaultGoal;
  }

  Future<void> setGoal(int goal) => _store.writeJson(_goalKey, goal);

  int answeredOn(DateTime day) => _days()[_dayKey(day)] ?? 0;

  Future<void> add(int count, DateTime day) async {
    if (count <= 0) return;
    final days = _days();
    final key = _dayKey(day);
    days[key] = (days[key] ?? 0) + count;
    // Keys sort chronologically (yyyy-MM-dd), so the oldest come first.
    final keys = days.keys.toList()..sort();
    for (final old in keys.take(keys.length > maxDays ? keys.length - maxDays : 0)) {
      days.remove(old);
    }
    await _store.writeJson(_daysKey, days);
  }

  /// Consecutive days, ending today or yesterday, on which the goal was reached.
  /// A day that is not over yet never breaks the streak.
  // shortcut: judged against the current goal for every past day, store the goal per day if that bothers.
  int streak(DateTime today) {
    final goal = this.goal;
    final days = _days();
    var day = DateTime(today.year, today.month, today.day);
    if ((days[_dayKey(day)] ?? 0) < goal) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while ((days[_dayKey(day)] ?? 0) >= goal) {
      streak++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }

  Future<void> clear() => _store.writeJson(_daysKey, <String, int>{});

  Map<String, int> _days() {
    final data = _store.readJson(_daysKey);
    return data is Map
        ? {
            for (final entry in data.entries)
              if (entry.key is String && entry.value is int)
                entry.key as String: entry.value as int,
          }
        : {};
  }

  static String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}
