import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';

/// Opens a carbon screen over a paper one (`carbonIn`,
/// INTERACTIONS_AND_ANIMATIONS §4): a carbon sheet slides up from the bottom
/// edge, the new content fades in over the last 140 ms. Reduced motion: a
/// 140 ms cross-fade.
///
/// [reducedMotion] is read once, when the route is created, from the
/// context that pushes it.
class CarbonInRoute<T> extends PageRouteBuilder<T> {
  CarbonInRoute({required WidgetBuilder builder, required bool reducedMotion})
    : super(
        pageBuilder: (context, _, _) => builder(context),
        transitionDuration: reducedMotion
            ? TesskraMotion.carbonReduced
            : TesskraMotion.carbonShift,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, _, child) {
          if (reducedMotion) {
            return FadeTransition(opacity: animation, child: child);
          }
          final standard = CurvedAnimation(
            parent: animation,
            curve: TesskraCurves.standard,
          );
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(standard),
            child: ColoredBox(
              color: TesskraTheme.private.scaffoldBackgroundColor,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Interval(
                    1 -
                        TesskraMotion.carbonContentIn.inMicroseconds /
                            TesskraMotion.carbonShift.inMicroseconds,
                    1,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
      );
}

/// Leaves a carbon screen for a paper one (`carbonOut`): the new paper
/// screen is complete and opaque from the first frame, so nothing of the
/// carbon screen underneath shows; an empty carbon sheet slides down to
/// uncover it. Reduced motion: the sheet fades out in 140 ms.
class CarbonOutRoute<T> extends PageRouteBuilder<T> {
  CarbonOutRoute({required WidgetBuilder builder, required bool reducedMotion})
    : super(
        pageBuilder: (context, _, _) => builder(context),
        transitionDuration: reducedMotion
            ? TesskraMotion.carbonReduced
            : TesskraMotion.carbonShift,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, _, child) {
          final sheet = ColoredBox(
            key: sheetKey,
            color: TesskraTheme.private.scaffoldBackgroundColor,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              child,
              IgnorePointer(
                child: reducedMotion
                    ? FadeTransition(
                        opacity: ReverseAnimation(animation),
                        child: sheet,
                      )
                    : SlideTransition(
                        position:
                            Tween(
                              begin: Offset.zero,
                              end: const Offset(0, 1),
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: TesskraCurves.standard,
                              ),
                            ),
                        child: sheet,
                      ),
              ),
            ],
          );
        },
      );

  /// The empty carbon sheet, for tests.
  @visibleForTesting
  static const sheetKey = ValueKey<String>('carbon-out-sheet');
}
