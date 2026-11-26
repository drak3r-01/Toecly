import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The only door to local persistence. Repositories talk to this interface, so
/// replacing shared_preferences (e.g. with SQLite) means changing one class.
abstract interface class LocalStore {
  String? read(String key);
  Future<void> write(String key, String value);
}

class SharedPreferencesStore implements LocalStore {
  SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStore> open() async =>
      SharedPreferencesStore(await SharedPreferences.getInstance());

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
}

/// Memory-only store, for tests.
class InMemoryStore implements LocalStore {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

/// Wraps stored data as `{"version": n, "data": ...}` so the format can evolve.
extension VersionedJson on LocalStore {
  static const currentVersion = 1;

  /// Returns the stored data, or null when absent, unreadable, or from an unknown version.
  Object? readJson(String key) {
    final raw = read(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['version'] == currentVersion) return decoded['data'];
    } on FormatException {
      // Corrupted data is treated as absent rather than crashing the app.
    }
    return null;
  }

  Future<void> writeJson(String key, Object data) =>
      write(key, jsonEncode({'version': currentVersion, 'data': data}));
}
