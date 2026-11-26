import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session_record.dart';

/// Historique des sessions, du plus récent au plus ancien.
/// Au-delà de [maxSessions], les plus anciennes sont purgées.
class SessionHistoryRepository {
  SessionHistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'session_history';
  static const maxSessions = 200;

  List<SessionRecord> loadAll() {
    final raw = _prefs.getStringList(_key) ?? const [];
    return [for (final item in raw) SessionRecord.fromJson(jsonDecode(item) as Map<String, dynamic>)];
  }

  Future<void> add(SessionRecord record) {
    final raw = _prefs.getStringList(_key) ?? const [];
    final updated = [jsonEncode(record.toJson()), ...raw].take(maxSessions).toList();
    return _prefs.setStringList(_key, updated);
  }
}
