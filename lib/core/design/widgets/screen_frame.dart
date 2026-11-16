import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';

/// The frame of every screen (SCREEN_SPECIFICATIONS §1.1): safe areas,
/// horizontal margin by width (16 below 360, else 24), content capped at 480
/// and centred, content that scrolls, and a bottom action area that is
/// pinned and never scrolls away. Paper or carbon comes from the ambient
/// theme (wrap carbon screens in `PrivateScope`).
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.body,
    this.actions = const [],
    this.top,
    this.centerBody = false,
  });

  /// Scrolls when it does not fit.
  final Widget body;

  /// Pinned at the bottom, stacked with `layout.itemGap`; primary first.
  final List<Widget> actions;

  /// Above the scrolling body, e.g. an app bar.
  final Widget? top;

  /// Centre the body vertically when it is shorter than the space (PRV-01).
  final bool centerBody;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final margin = TesskraLayout.screenMarginFor(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: TesskraLayout.maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    margin,
                    TesskraLayout.screenPaddingTop,
                    margin,
                    TesskraLayout.screenPaddingBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ?top,
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, area) => SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: centerBody ? area.maxHeight : 0,
                              ),
                              child: centerBody ? Center(child: body) : body,
                            ),
                          ),
                        ),
                      ),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: TesskraLayout.itemGap),
                        for (final (index, action) in actions.indexed) ...[
                          if (index > 0)
                            const SizedBox(height: TesskraLayout.itemGap),
                          action,
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
