import '../../core/toeic_part.dart';
import '../quiz/quiz_request.dart';
import 'local_store.dart';

/// Remembers the last practice configuration, to resume it in one tap.
class LastPracticeRepository {
  LastPracticeRepository(this._store);

  final LocalStore _store;

  static const _key = 'last_practice';

  /// Null if no practice was started yet, or the stored data is unusable.
  QuizRequest? load() {
    final data = _store.readJson(_key);
    if (data is! Map<String, dynamic>) return null;
    final count = data['count'];
    final parts = data['parts'];
    if (count is! int || count < 1 || parts is! List) return null;
    return QuizRequest.fromQuery({
      'parts': parts.join(','),
      'count': '$count',
      if (data['category'] is String) 'category': data['category'] as String,
    });
  }

  Future<void> save(QuizRequest request) => _store.writeJson(_key, {
    'parts': [for (final ToeicPart part in request.parts) part.number],
    'count': request.questionCount,
    if (request.category != null) 'category': request.category!.jsonName,
  });

  Future<void> clear() => _store.writeJson(_key, <String, dynamic>{});
}
