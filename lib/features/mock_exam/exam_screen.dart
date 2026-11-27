import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation/app_destination.dart';
import '../../app/providers.dart';
import '../../data/exercises/mock_exam_blueprint.dart';
import '../../data/exercises/models.dart';
import '../../data/quiz/exam_session.dart';
import '../../data/quiz/exam_snapshot.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../l10n/app_localizations.dart';
import '../quiz/exercise_page.dart';
import 'exam_result_view.dart';

/// Draws a mock exam and runs it.
class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key, this.resume = false});

  static const path = '/exam';

  /// Resume the exam saved before the app was closed, if it can still be rebuilt.
  final bool resume;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  // The draw is made once: a rebuild must never change the exam.
  late final Future<_ExamStart> _start = _prepare();

  Future<_ExamStart> _prepare() async {
    final repository = ref.read(exerciseRepositoryProvider);
    final saved = widget.resume ? ref.read(examProgressProvider).load() : null;
    if (saved != null) {
      final exercises = await repository.restoreExam(saved);
      if (exercises != null) return (exercises: exercises, saved: saved);
    }
    final seen = ref.read(seenQuestionsProvider).loadIds();
    return (
      exercises: await repository.drawMockExam(
        MockExamBlueprint.official,
        seen,
      ),
      saved: null,
    );
  }

  /// Leaving for good (quit, or the result was read): nothing is left to resume.
  Future<void> _leave() async {
    await ref.read(examProgressProvider).clear();
    ref.read(dataRevisionProvider.notifier).bump();
    if (!mounted) return;
    context.canPop() ? context.pop() : context.go(AppDestination.mockExam.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<_ExamStart>(
      future: _start,
      builder: (context, snapshot) {
        final exercises = snapshot.data?.exercises;
        final Widget body;
        if (snapshot.hasError) {
          body = Center(child: Text(l10n.quizLoadError));
        } else if (exercises == null) {
          body = const Center(child: CircularProgressIndicator());
        } else if (exercises.isEmpty) {
          body = Center(child: Text(l10n.quizEmpty));
        } else {
          final saved = snapshot.data!.saved;
          return ExamView(
            exercises: exercises,
            onLeave: _leave,
            onSubmitted: _record,
            onProgress: (session, endsAt, total) => ref.read(examProgressProvider).save(
                  ExamSnapshot.capture(session, endsAt: endsAt, total: total),
                ),
            resumeFrom: saved,
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _leave,
            ),
          ),
          body: body,
        );
      },
    );
  }

  /// Saves the whole exam at once: nothing is revealed before, so nothing is lost by waiting.
  Future<void> _record(ExamSession session, Duration used) async {
    await ref.read(examProgressProvider).clear();
    await ref.read(answerRecorderProvider).recordExam(
      entries: [
        for (final e in session.entries) (exercise: e.exercise, question: e.question),
      ],
      answers: session.answers,
      correctAnswers: session.correctCount,
      duration: used,
    );
  }
}

typedef _ExamStart = ({List<Exercise> exercises, ExamSnapshot? saved});

/// The exam itself: countdown, free navigation, submission, then the result.
class ExamView extends StatefulWidget {
  const ExamView({
    super.key,
    required this.exercises,
    required this.onLeave,
    this.onSubmitted,
    this.onProgress,
    this.resumeFrom,
    this.duration,
  });

  final List<Exercise> exercises;
  final VoidCallback onLeave;

  /// Defaults to the official exam duration.
  final Duration? duration;

  /// Called when the exam starts and after each answer or move, so it can be saved.
  final void Function(ExamSession session, DateTime endsAt, Duration total)? onProgress;

  /// Answers, position and end time of an exam being resumed.
  final ExamSnapshot? resumeFrom;

  /// Called once, when the exam is submitted (by the user or when time runs out).
  final FutureOr<void> Function(ExamSession session, Duration used)? onSubmitted;

  @override
  State<ExamView> createState() => _ExamViewState();
}

class _ExamViewState extends State<ExamView> {
  late final ExamSession _session = ExamSession(widget.exercises);
  late final Duration _total = widget.resumeFrom == null
      ? widget.duration ?? MockExamBlueprint.official.duration
      : Duration(seconds: widget.resumeFrom!.totalSeconds);
  // The countdown follows the wall clock, not the number of ticks: ticks are late when the
  // app is in the background or the UI is busy.
  late final DateTime _endsAt = widget.resumeFrom?.endsAt ?? clock.now().add(_total);
  late Duration _remaining = _endsAt.difference(clock.now());
  Timer? _timer;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.resumeFrom;
    if (saved != null) {
      _session.restore(answers: saved.answers, currentIndex: saved.currentIndex);
    }
    _saveProgress();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _endsAt.difference(clock.now()));
      if (_remaining <= Duration.zero) {
        _timeUp = true;
        _submit();
      }
    });
    // The app was closed past the deadline: the exam is over as soon as it reopens.
    if (_remaining <= Duration.zero) {
      _timeUp = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => mounted ? _submit() : null,
      );
    }
  }

  void _saveProgress() {
    if (!_session.isSubmitted) widget.onProgress?.call(_session, _endsAt, _total);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submit() {
    if (_session.isSubmitted) return;
    _timer?.cancel();
    setState(_session.submit);
    final used = _total - (_remaining < Duration.zero ? Duration.zero : _remaining);
    widget.onSubmitted?.call(_session, used);
  }

  Future<bool> _confirm({
    required String title,
    String? message,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: message == null ? null : Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.examKeepWorking),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _askSubmit() async {
    final l10n = AppLocalizations.of(context);
    final unanswered = _session.unansweredCount;
    final ok = await _confirm(
      title: l10n.examSubmitTitle,
      message: unanswered == 0 ? null : l10n.examUnanswered(unanswered),
      action: l10n.examSubmit,
    );
    if (ok) _submit();
  }

  Future<void> _askQuit() async {
    final l10n = AppLocalizations.of(context);
    if (_session.isSubmitted) return widget.onLeave();
    if (await _confirm(
      title: l10n.examQuitTitle,
      message: l10n.examQuitMessage,
      action: l10n.examQuit,
    )) {
      widget.onLeave();
    }
  }

  void _move(void Function() move) {
    setState(move);
    _saveProgress();
  }

  void _openGrid() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _session.totalQuestions; i++)
                _GridCell(
                  number: i + 1,
                  answered: _session.answerFor(_session.entries[i].question) != null,
                  current: i == _session.currentIndex,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _session.goTo(i));
                    _saveProgress();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // The system back button / gesture must ask before throwing the exam away.
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: _session.isSubmitted,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _askQuit();
        },
        child: _buildExam(context),
      );

  Widget _buildExam(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_session.isSubmitted) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.quizClose,
            onPressed: widget.onLeave,
          ),
          title: Text(l10n.examResultTitle),
        ),
        body: SafeArea(
          child: ExamResultView(
            session: _session,
            timeUp: _timeUp,
            used: _total - (_remaining < Duration.zero ? Duration.zero : _remaining),
            onLeave: widget.onLeave,
          ),
        ),
      );
    }

    final entry = _session.current;
    final urgent = _remaining <= const Duration(minutes: 5);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.quizClose,
          onPressed: _askQuit,
        ),
        title: Row(
          children: [
            Icon(Icons.timer_outlined, color: urgent ? scheme.error : null),
            const SizedBox(width: 6),
            Text(
              _format(_remaining),
              style: TextStyle(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: urgent ? scheme.error : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.grid_view),
            label: Text(
              l10n.quizQuestionCounter(
                _session.currentIndex + 1,
                _session.totalQuestions,
              ),
            ),
            onPressed: _openGrid,
          ),
          const SizedBox(width: 4),
          FilledButton(onPressed: _askSubmit, child: Text(l10n.examSubmit)),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: AnimatedProgressBar(
                value: _session.answeredCount / _session.totalQuestions,
                height: 8,
              ),
            ),
            Expanded(
              child: ExercisePage(
                exercise: entry.exercise,
                questionIndex: entry.questionIndex,
                answers: _session.answers,
                revealed: false,
                onSelect: (index) {
                  setState(() => _session.select(index));
                  _saveProgress();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chevron_left),
                      label: Text(l10n.examPrevious),
                      onPressed: _session.currentIndex == 0 ? null : () => _move(_session.previous),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.chevron_right),
                      label: Text(l10n.quizNext),
                      onPressed: _session.currentIndex == _session.totalQuestions - 1
                          ? null
                          : () => _move(_session.next),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(Duration d) {
    final total = d < Duration.zero ? Duration.zero : d;
    final hours = total.inHours;
    final minutes = (total.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (total.inSeconds % 60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.number,
    required this.answered,
    required this.current,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: answered ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: current ? BorderSide(color: scheme.primary, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(child: Text('$number')),
        ),
      ),
    );
  }
}
