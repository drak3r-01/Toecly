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

/// Wraps stored data as `{"version": n, "data": ...}` so each key can evolve on its own:
/// bump the version of one key and give [VersionedJson.readJson] a migration for it.
extension VersionedJson on LocalStore {
  static const defaultVersion = 1;

  /// Returns the stored data brought up to [version] through [migrations] (`migrations[v]`
  /// turns version v data into version v+1), or null when absent, unreadable, written by a
  /// newer app, or older with no migration path.
  Object? readJson(
    String key, {
    int version = defaultVersion,
    Map<int, Object? Function(Object? data)> migrations = const {},
  }) {
    try {
      final decoded = _decode(read(key));
      final storedVersion = decoded?['version'];
      if (storedVersion is! int || storedVersion > version) return null;
      var stored = storedVersion;
      var data = decoded!['data'];
      while (stored < version) {
        final migrate = migrations[stored];
        if (migrate == null) return null;
        data = migrate(data);
        stored++;
      }
      return data;
    } on FormatException {
      // Corrupted data is treated as absent rather than crashing the app.
    } on TypeError {
      // Same for data with an unexpected shape.
    }
    return null;
  }

  /// Writes [data] at [version]. Data stored by a newer app is never overwritten, so
  /// going back to an older release cannot destroy the progress.
  Future<void> writeJson(
    String key,
    Object data, {
    int version = defaultVersion,
  }) async {
    final stored = _decode(read(key))?['version'];
    if (stored is int && stored > version) return;
    await write(key, jsonEncode({'version': version, 'data': data}));
  }

  Map<String, dynamic>? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
