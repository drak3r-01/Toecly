import 'package:material_ui/material_ui.dart';

/// Changes its [epoch] each time the user arrives on a main tab. Animated
/// widgets (bars, gauges, entrances) read it and play again from the start,
/// since the tabs themselves are kept alive.
class ReplayScope extends InheritedWidget {
  const ReplayScope({super.key, required this.epoch, required super.child});

  final int epoch;

  /// 0 outside a scope, so widgets play once.
  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReplayScope>()?.epoch ?? 0;

  @override
  bool updateShouldNotify(ReplayScope oldWidget) => oldWidget.epoch != epoch;
}
