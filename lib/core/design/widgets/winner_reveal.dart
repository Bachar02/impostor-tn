import 'dart:async';

import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/haptics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';

/// `winnerReveal` (PUB-09 interactions): the result stamp slams in (scale
/// 1.6 → 1 on the `stamp` curve, heavy haptic as it lands), then the
/// content below it rises 8 and fades in. 600 ms.
///
/// With reduced motion: a 140 ms fade, no slam; the haptic remains. When
/// [animate] is false (recovery, a result already seen) everything is shown
/// at once and nothing vibrates.
class WinnerReveal extends StatefulWidget {
  const WinnerReveal({
    super.key,
    required this.animate,
    required this.stamp,
    required this.content,
    this.delay = Duration.zero,
  });

  final bool animate;

  /// Waits for a screen transition to finish, so the slam is seen.
  final Duration delay;
  final Widget stamp;
  final Widget content;

  @override
  State<WinnerReveal> createState() => _WinnerRevealState();
}

class _WinnerRevealState extends State<WinnerReveal>
    with SingleTickerProviderStateMixin {
  /// The stamp lands half way; the content rises from 40 % to the end.
  static const _landing = 0.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.animate ? 0 : 1,
  );
  late final _stampScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, _landing, curve: TesskraCurves.stamp),
  );
  late final _stampOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.15),
  );
  late final _contentIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1, curve: TesskraCurves.enter),
  );

  bool _started = false;
  bool _reduced = false;
  bool _landed = false;
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !widget.animate) return;
    _started = true;
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _stampScale.curve = Curves.linear;
      _stampOpacity.curve = Curves.linear;
      _contentIn.curve = Curves.linear;
    } else {
      _controller.addListener(_onTick);
    }
    _controller.duration = _reduced
        ? TesskraMotion.winnerReduced
        : TesskraMotion.winnerReveal;
    if (widget.delay == Duration.zero) {
      _start();
    } else {
      _delay = Timer(widget.delay, () {
        if (mounted) _start();
      });
    }
  }

  void _start() {
    if (_reduced) Haptics.heavy();
    unawaited(_controller.forward());
  }

  void _onTick() {
    if (!_landed && _controller.value >= _landing) {
      _landed = true;
      Haptics.heavy();
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _stampScale.dispose();
    _stampOpacity.dispose();
    _contentIn.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeTransition(
          opacity: _stampOpacity,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: _reduced ? 1 : TesskraMotion.stampScale,
              end: 1,
            ).animate(_stampScale),
            child: widget.stamp,
          ),
        ),
        FadeTransition(
          opacity: _contentIn,
          child: AnimatedBuilder(
            animation: _contentIn,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                0,
                _reduced
                    ? 0
                    : TesskraMotion.listItemRise * (1 - _contentIn.value),
              ),
              child: child,
            ),
            child: widget.content,
          ),
        ),
      ],
    );
  }
}
