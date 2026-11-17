import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/private_scope.dart';
import 'package:impostor_tn/core/design/widgets/role_ticket.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

import '../core/design/widgets/widget_harness.dart';

/// Measures a category on the two revealed role tickets (D-39): the
/// Civilian's chip "category: X" and the Impostor's big text. Shared by the
/// proposed-label test and the catalog guard so both use one definition of
/// "fits".
final _l10n = lookupAppLocalizations(const Locale('ar'));

/// SYNTHETIC: a short placeholder word, not content. Category checks keep
/// the word short so they test the category only (Q-29 stays open).
const _placeholderWord = 'كلمة';

RevealedTicket civilianTicket(String category) => RevealedTicket(
  label: _l10n.revealRoleLabelSealed,
  name: 'لاعب',
  caption: '${_l10n.roleCivilian} · ${_l10n.revealWordLabel}',
  bigText: _placeholderWord,
  chip: _l10n.revealCategory(category),
);

RevealedTicket impostorTicket(String category) => RevealedTicket(
  label: _l10n.revealRoleLabelSealed,
  name: 'لاعب',
  caption: '${_l10n.roleImpostor} · ${_l10n.revealCategoryOnly}',
  bigText: category,
  chip: _l10n.revealNoWord,
);

double _margin(Size size) => size.width < TesskraLayout.compactBreakpointWidth
    ? TesskraLayout.screenMarginHCompact
    : TesskraLayout.screenMarginH;

/// Pumps [content] as on PRV-02 (screen margins of [size]) and returns the
/// ticket size.
Future<Size> pumpTicketAt(
  WidgetTester tester,
  RevealedTicket content,
  Size size,
  double scale,
) async {
  await pumpRtl(
    tester,
    PrivateScope(
      onLeaveForeground: () {},
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: _margin(size)),
        child: RoleTicket(content: content),
      ),
    ),
    size: size,
    textScale: scale,
  );
  expect(tester.takeException(), isNull);
  return tester.getSize(find.byType(RoleTicket));
}

/// One `labelM` chip line at [scale].
double chipLine(double scale) =>
    TesskraTypography.labelM.fontSize! *
    scale *
    TesskraTypography.labelM.height!;

/// One big-text line at the 40 floor.
final floorLine =
    TesskraTypography.displayXLMinFontSize *
    TesskraTypography.displayXL.height!;

/// The big-text height reserved at [scale] (FittedDisplayText, D-39):
/// each line rounded up, as the widget does.
double bigTextReserve(double scale) => math.max(
  (TesskraTypography.displayXL.fontSize! *
          math.min(scale, TesskraTypography.maxTextScaleSupported) *
          TesskraTypography.displayXL.height!)
      .ceilToDouble(),
  RoleTicket.categoryLines * floorLine.ceilToDouble(),
);

/// The result of measuring one category at one frame.
final class CategoryFit {
  const CategoryFit({
    required this.civilian,
    required this.impostor,
    required this.chipHeight,
    required this.chipLimit,
    required this.bigTextHeight,
    required this.bigTextLimit,
  });

  final Size civilian;
  final Size impostor;
  final double chipHeight;
  final double chipLimit;
  final double bigTextHeight;
  final double bigTextLimit;

  bool get parity => civilian == impostor;
  bool get chipWithinReserve => chipHeight <= chipLimit;
  bool get bigTextWithinReserve => bigTextHeight <= bigTextLimit;

  /// Parity holds by the reserve, not by coincidence.
  bool get fits => parity && chipWithinReserve && bigTextWithinReserve;

  /// Sizes only: no category text, so it can appear in a test report.
  @override
  String toString() =>
      'CategoryFit(civilian $civilian, impostor $impostor, '
      'chip $chipHeight/$chipLimit, big $bigTextHeight/$bigTextLimit)';
}

/// Half a pixel of tolerance for line-metric rounding.
const _epsilon = 0.5;

Future<CategoryFit> measureCategory(
  WidgetTester tester,
  String category,
  Size size,
  double scale,
) async {
  final civilian = await pumpTicketAt(
    tester,
    civilianTicket(category),
    size,
    scale,
  );
  final chipHeight = tester
      .getSize(find.text(_l10n.revealCategory(category)))
      .height;
  final impostor = await pumpTicketAt(
    tester,
    impostorTicket(category),
    size,
    scale,
  );
  final bigTextHeight = tester.getSize(find.text(category)).height;
  return CategoryFit(
    civilian: civilian,
    impostor: impostor,
    chipHeight: chipHeight,
    chipLimit:
        RoleTicket.categoryLines * chipLine(scale).ceilToDouble() + _epsilon,
    bigTextHeight: bigTextHeight,
    bigTextLimit: bigTextReserve(scale) + _epsilon,
  );
}
