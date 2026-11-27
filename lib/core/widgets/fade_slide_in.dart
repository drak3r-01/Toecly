import 'package:material_ui/material_ui.dart';

import 'replay_scope.dart';

/// Fades and slides its child in once, after [delay] (for staggered lists).
/// The delay lives inside the animation curve, so no timer is left pending.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 500);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration + widget.delay,
  )..forward();

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delay.inMilliseconds / (_duration + widget.delay).inMilliseconds,
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  int? _epoch;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final epoch = ReplayScope.of(context);
    if (_epoch != null && _epoch != epoch) {
      _controller.forward(from: 0); // the user came back to this tab
    }
    _epoch = epoch;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
