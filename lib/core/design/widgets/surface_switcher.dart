import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impostor_tn/core/design/theme/tesskra_system_bars.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';

/// Screen changes inside a flow of paper and carbon screens
/// (INTERACTIONS_AND_ANIMATIONS §4, `animations.json` carbonIn/carbonOut).
///
/// - Paper → carbon (`carbonIn`): a carbon sheet slides up from the bottom
///   edge over the still paper screen; the new content fades in over the
///   last 140 ms and cannot be tapped before the sheet is in place.
/// - Carbon → paper (`carbonOut`): the carbon content leaves in the same
///   frame; only an empty sheet slides down, uncovering the new paper
///   screen, which is complete from the first frame.
/// - Same surface: the new screen fades in over the old one (220 ms). With
///   [dropOutgoing] the old screen leaves at once and the new one fades in
///   over an empty ground.
/// - Reduced motion: carbonIn and carbonOut become 140 ms cross-fades, still
///   with an empty sheet on the carbon side of a carbonOut; same-surface
///   changes are instant.
///
/// System bar icons follow the surface that covers the top of the screen,
/// switching when the sheet passes the midpoint.
///
/// The current screen keeps its state through a transition: layers are
/// keyed and their widget structure never changes.
class SurfaceSwitcher extends StatefulWidget {
  const SurfaceSwitcher({
    super.key,
    required this.screenKey,
    required this.surface,
    required this.child,
    this.dropOutgoing = false,
  });

  /// Identifies the screen; a new key starts a transition.
  final Object screenKey;
  final TesskraSurface surface;
  final Widget child;

  /// The screen being replaced may show a secret: it is never kept for a
  /// transition (SCREEN_SPECIFICATIONS §1.5). Read when [screenKey] changes.
  final bool dropOutgoing;

  @override
  State<SurfaceSwitcher> createState() => _SurfaceSwitcherState();
}

enum _Kind { none, fade, carbonIn, carbonOut }

final class _Layer {
  _Layer(this.id, this.surface, this.child);

  final Object id;
  final TesskraSurface surface;

  /// Null for an empty sheet.
  Widget? child;
}

class _SurfaceSwitcherState extends State<SurfaceSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addStatusListener(_onStatus);
  late final CurvedAnimation _standard = CurvedAnimation(
    parent: _controller,
    curve: TesskraCurves.standard,
  );
  late final CurvedAnimation _contentIn = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      1 -
          TesskraMotion.carbonContentIn.inMicroseconds /
              TesskraMotion.carbonShift.inMicroseconds,
      1,
    ),
  );

  late _Layer _current = _Layer(widget.screenKey, widget.surface, widget.child);
  _Layer? _outgoing;
  _Kind _kind = _Kind.none;
  bool _reduced = false;
  int _sheets = 0;
  late TesskraSurface _top = widget.surface;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTick);
  }

  @override
  void dispose() {
    _standard.dispose();
    _contentIn.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SurfaceSwitcher old) {
    super.didUpdateWidget(old);
    if (widget.screenKey == _current.id) {
      _current.child = widget.child;
      return;
    }
    final from = _current;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final kind = from.surface == widget.surface
        ? _Kind.fade
        : widget.surface == TesskraSurface.carbon
        ? _Kind.carbonIn
        : _Kind.carbonOut;
    final duration = switch (kind) {
      _Kind.fade when reduced => Duration.zero,
      _Kind.fade => TesskraDurations.base,
      _Kind.carbonIn ||
      _Kind.carbonOut when reduced => TesskraMotion.carbonReduced,
      _ => TesskraMotion.carbonShift,
    };
    // carbonOut never keeps carbon content; a dropped screen is replaced by
    // an empty ground of its surface, so nothing else shows through.
    final keep = kind != _Kind.carbonOut && !widget.dropOutgoing;
    _current = _Layer(widget.screenKey, widget.surface, widget.child);
    _controller.stop();
    if (duration == Duration.zero) {
      _outgoing = null;
      _kind = _Kind.none;
      _top = widget.surface;
      return;
    }
    _outgoing = keep ? from : _Layer(_Sheet(++_sheets), from.surface, null);
    _kind = kind;
    _reduced = reduced;
    _top = from.surface;
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _outgoing = null;
        _kind = _Kind.none;
        _top = _current.surface;
      });
    }
  }

  void _onTick() {
    final outgoing = _outgoing;
    if (outgoing == null) return;
    final top = _standard.value >= 0.5 ? _current.surface : outgoing.surface;
    if (top != _top) setState(() => _top = top);
  }

  @override
  Widget build(BuildContext context) {
    final outgoing = _outgoing;
    final current = _current;
    const still = AlwaysStoppedAnimation<Offset>(Offset.zero);
    final layers = <Widget>[];

    Widget layer(
      _Layer l, {
      bool interactive = false,
      Animation<double> opacity = kAlwaysCompleteAnimation,
      Animation<Offset> slide = still,
      Animation<double> content = kAlwaysCompleteAnimation,
    }) => _LayerView(
      key: ValueKey(l.id),
      ground: _ground(l.surface),
      interactive: interactive,
      opacity: opacity,
      slide: slide,
      content: content,
      child: l.child,
    );

    switch (_kind) {
      case _Kind.none:
        layers.add(layer(current, interactive: true));
      case _Kind.fade:
        layers
          ..add(layer(outgoing!))
          ..add(layer(current, interactive: true, opacity: _standard));
      case _Kind.carbonIn:
        layers
          ..add(layer(outgoing!))
          ..add(
            _reduced
                ? layer(current, opacity: _controller)
                : layer(
                    current,
                    slide: Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_standard),
                    content: _contentIn,
                  ),
          );
      case _Kind.carbonOut:
        layers
          ..add(layer(current, interactive: true))
          ..add(
            _reduced
                ? layer(outgoing!, opacity: ReverseAnimation(_controller))
                : layer(
                    outgoing!,
                    slide: Tween(
                      begin: Offset.zero,
                      end: const Offset(0, 1),
                    ).animate(_standard),
                  ),
          );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: TesskraSystemBars.of(_top),
      child: ClipRect(
        child: Stack(fit: StackFit.expand, children: layers),
      ),
    );
  }

  static Color _ground(TesskraSurface surface) => switch (surface) {
    TesskraSurface.paper => TesskraTheme.public.scaffoldBackgroundColor,
    TesskraSurface.carbon => TesskraTheme.private.scaffoldBackgroundColor,
  };
}

/// Identity of an empty sheet layer.
final class _Sheet {
  const _Sheet(this.serial);

  final int serial;

  @override
  bool operator ==(Object other) => other is _Sheet && other.serial == serial;

  @override
  int get hashCode => serial.hashCode;
}

/// One layer. Its structure is the same in every role, so a screen moving
/// from "incoming" to "settled" keeps its state.
class _LayerView extends StatelessWidget {
  const _LayerView({
    super.key,
    required this.ground,
    required this.interactive,
    required this.opacity,
    required this.slide,
    required this.content,
    required this.child,
  });

  final Color ground;
  final bool interactive;
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Animation<double> content;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !interactive,
      child: ExcludeSemantics(
        excluding: !interactive,
        child: FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: slide,
            child: ColoredBox(
              color: ground,
              child: FadeTransition(
                opacity: content,
                child: child ?? const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
