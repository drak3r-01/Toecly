import 'local_store.dart';

/// Ids of the word cards the user marked as known.
class WordProgressRepository {
  WordProgressRepository(this._store);

  final LocalStore _store;

  static const _key = 'known_words';

  Set<String> loadKnown() {
    final data = _store.readJson(_key);
    return data is List
        ? {
            for (final id in data)
              if (id is String) id,
          }
        : {};
  }

  Future<void> markKnown(String id) => _store.writeJson(_key, {...loadKnown(), id}.toList());

  Future<void> clear() => _store.writeJson(_key, <String>[]);
}
