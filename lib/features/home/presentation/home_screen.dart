import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PUB-01 Home, slice 1: no settings icon and no "how to play" button
/// (D-29). The restore-failed banner is shown once (F1 step 3).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onNewGame,
    this.restoreFailed = false,
  });

  final VoidCallback onNewGame;
  final bool restoreFailed;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _showBanner = widget.restoreFailed;

  /// The logo file's natural size (SCREEN_SPECIFICATIONS PUB-01 item 3).
  static const double _heroWidth = 320;
  static const double _heroAspect = 320 / 190;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    return Scaffold(
      body: ScreenFrame(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showBanner) ...[
              TesskraBanner(
                message: l10n.stateRestoreFailed,
                kind: TesskraBannerKind.info,
                icon: TesskraIcons.info,
              ),
              const SizedBox(height: TesskraLayout.sectionGap),
            ],
            const SizedBox(height: TesskraLayout.sectionGap),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _heroWidth),
                child: AspectRatio(
                  aspectRatio: _heroAspect,
                  child: SvgPicture.asset(
                    TesskraLogos.ticketLockup,
                    semanticsLabel: l10n.appName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TesskraLayout.sectionGap),
            Text(
              l10n.homeTagline,
              textAlign: TextAlign.center,
              style: TesskraTypography.displayM.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: TesskraSpacing.s3),
            Text(
              isolateNumberRanges(l10n.homeFacts),
              textAlign: TextAlign.center,
              style: TesskraTypography.bodyM.copyWith(color: c.textSecondary),
            ),
          ],
        ),
        actions: [
          TesskraButton(
            label: l10n.homeNewGame,
            onPressed: () {
              setState(() => _showBanner = false);
              widget.onNewGame();
            },
          ),
        ],
      ),
    );
  }
}
