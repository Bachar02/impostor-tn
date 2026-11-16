import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';

/// The single wrapper of every private (carbon) screen (SCREEN_SPECIFICATIONS
/// §1.5, ADR-0006).
///
/// - Applies the carbon theme.
/// - Calls [onLeaveForeground] as soon as the app is hidden, so the owner
///   removes any secret in the same frame and returns to the neutral handoff
///   (UX_FLOWS F11). "Hidden" follows the specification: home, app switcher,
///   another app, lock; a notification shade only makes the app inactive and
///   does not count. Not verified on a device.
///
/// Screenshot and app-switcher protection is not switched here: under D-18
/// it covers the whole game, from start until it ends or is left, so it
/// belongs to the game flow, not to each private screen.
class PrivateScope extends StatefulWidget {
  const PrivateScope({
    super.key,
    required this.child,
    required this.onLeaveForeground,
  });

  final Widget child;
  final VoidCallback onLeaveForeground;

  @override
  State<PrivateScope> createState() => _PrivateScopeState();
}

class _PrivateScopeState extends State<PrivateScope> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: () => widget.onLeaveForeground());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TesskraTheme.private,
      child: Builder(
        builder: (context) => DefaultTextStyle.merge(
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
