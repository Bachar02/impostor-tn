import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';

/// Three pulsing dots (DESIGN_SYSTEM §5 "Loading"). Decorative: the owner
/// provides the semantic label.
///
/// Static when animations are disabled, and always static on carbon:
/// SCREEN_SPECIFICATIONS §1.5 allows no looping animation on private screens.
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key, this.color, this.dotSize = TesskraSpacing.s2});

  /// Defaults to the ambient text colour.
  final Color? color;
  final double dotSize;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TesskraDurations.slow * 3,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? DefaultTextStyle.of(context).style.color;
    final still = _still(context);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TesskraSpacing.s1,
                ),
                child: Opacity(
                  opacity: still ? 1 : _opacity(i),
                  child: SizedBox.square(
                    dimension: widget.dotSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static bool _still(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
      TesskraTokens.of(context).isCarbon;

  double _opacity(int index) {
    final phase = (_controller.value * 3 - index) % 3;
    return phase < 1 ? 1 : 0.35;
  }
}
