import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// NOT A PRODUCT SCREEN.
///
/// Temporary root used to prove that fonts, tokens, themes, assets and RTL
/// are wired correctly. It is replaced by the approved Home screen once the
/// UX flows and screen specifications exist. Do not extend it.
class FoundationPlaceholderScreen extends StatelessWidget {
  const FoundationPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final margin = TesskraLayout.screenMarginFor(constraints.maxWidth);
            return SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                margin,
                TesskraLayout.screenPaddingTop,
                margin,
                TesskraLayout.screenPaddingBottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: TesskraLayout.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SvgPicture.asset(
                        TesskraLogos.ticketLockup,
                        semanticsLabel: l10n.appName,
                      ),
                      const SizedBox(height: TesskraLayout.sectionGap),
                      Text(
                        l10n.appName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: TesskraLayout.itemGap),
                      Text(
                        'Foundation build — no product screens yet.',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.bodyMedium,
                      ),
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
