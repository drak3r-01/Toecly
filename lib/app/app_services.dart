import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/questions/question_repository.dart';
import '../data/storage/missed_questions_repository.dart';
import '../data/storage/part_stats_repository.dart';
import '../data/storage/session_history_repository.dart';
import 'theme/theme_mode_controller.dart';

/// Regroupe les services partagés par toute l'application (injection simple).
class AppServices {
  AppServices({
    required this.themeModeController,
    required this.questions,
    required this.sessionHistory,
    required this.missedQuestions,
    required this.partStats,
  });

  final ThemeModeController themeModeController;
  final QuestionRepository questions;
  final SessionHistoryRepository sessionHistory;
  final MissedQuestionsRepository missedQuestions;
  final PartStatsRepository partStats;

  static Future<AppServices> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppServices(
      themeModeController: ThemeModeController(prefs),
      questions: QuestionRepository(),
      sessionHistory: SessionHistoryRepository(prefs),
      missedQuestions: MissedQuestionsRepository(prefs),
      partStats: PartStatsRepository(prefs),
    );
  }
}

/// Donne accès aux [AppServices] depuis n'importe quel widget : `AppScope.of(context)`.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
