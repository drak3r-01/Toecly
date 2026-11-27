import 'package:material_ui/material_ui.dart';

import '../../core/widgets/toecly_logo.dart';
import '../theme/app_theme.dart';
import '../theme/brand_colors.dart';

/// Animated splash shown over the app at launch, then faded out. The wordmark
/// runs on the Bricolage Grotesque variable axes: each letter swells from thin
/// and condensed to bold and wide, one after the other.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  static const Duration duration = Duration(milliseconds: 2600);

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SplashOverlay.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) setState(() => _visible = false);
        });
  bool _visible = true;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    // Respect the system "reduce animations" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _visible = false;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        Positioned.fill(child: widget.child),
        if (_visible)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _controller.value = 1, // tap to skip
              child: _SplashContent(animation: _controller),
            ),
          ),
      ],
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final logoReveal = CurvedAnimation(parent: animation, curve: const Interval(0, 0.55));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Fade out during the last 12 % of the timeline.
        final fade = 1 - const Interval(0.88, 1).transform(animation.value);
        return Opacity(opacity: fade, child: child);
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.4, -0.6),
            radius: 1.3,
            colors: [BrandColors.inkRaised, BrandColors.ink],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToeclyLogo(size: 150, reveal: logoReveal),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) => _Wordmark(progress: animation.value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const letters = 'Toecly';
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => BrandColors.wordmarkGradient.createShader(bounds),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < letters.length; i++)
            _letter(letters[i], Interval(0.3 + i * 0.07, 0.65 + i * 0.07).transform(progress)),
        ],
      ),
    );
  }

  Widget _letter(String char, double t) {
    final eased = Curves.easeOutCubic.transform(t);
    return Opacity(
      opacity: eased,
      child: Text(
        char,
        style: TextStyle(
          fontFamily: AppTheme.headingFont,
          fontSize: 68,
          color: Colors.white,
          height: 1.1,
          decoration: TextDecoration.none,
          fontVariations: [
            FontVariation('wght', 200 + 600 * eased),
            FontVariation('wdth', 75 + 25 * eased),
            const FontVariation('opsz', 96),
          ],
        ),
      ),
    );
  }
}
