import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/mock_exam/exam_screen.dart';
import '../features/mock_exam/mock_exam_screen.dart';
import '../data/quiz/quiz_request.dart';
import '../features/practice/practice_setup_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/review/review_screen.dart';
import '../features/settings/settings_screen.dart';
import 'navigation/app_destination.dart';
import 'navigation/page_transitions.dart';
import 'navigation/responsive_shell.dart';

GoRouter createAppRouter() {
  GoRoute route(AppDestination destination, Widget Function() screen) => GoRoute(
        path: destination.path,
        pageBuilder: (context, state) => fadeSlidePage(state: state, child: screen()),
      );

  return GoRouter(
    initialLocation: AppDestination.dashboard.path,
    routes: [
      GoRoute(
        path: '/quiz',
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: QuizScreen(
            request: QuizRequest.fromQuery(state.uri.queryParameters),
          ),
        ),
      ),
      GoRoute(
        path: ReviewScreen.sessionPath,
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: ReviewSessionScreen(
            questionCount: int.tryParse(state.uri.queryParameters['count'] ?? '') ?? 10,
          ),
        ),
      ),
      GoRoute(
        path: ExamScreen.path,
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: ExamScreen(resume: state.uri.queryParameters['resume'] == '1'),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ResponsiveShell(navigationShell: navigationShell),
        // The branch order MUST match AppDestination.values.
        branches: [
          StatefulShellBranch(
            routes: [route(AppDestination.dashboard, DashboardScreen.new)],
          ),
          StatefulShellBranch(
            routes: [route(AppDestination.practice, PracticeSetupScreen.new)],
          ),
          StatefulShellBranch(
            routes: [route(AppDestination.mockExam, MockExamScreen.new)],
          ),
          StatefulShellBranch(
            routes: [route(AppDestination.review, ReviewScreen.new)],
          ),
          StatefulShellBranch(
            routes: [route(AppDestination.settings, SettingsScreen.new)],
          ),
        ],
      ),
    ],
  );
}
