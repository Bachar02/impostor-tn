import 'package:flutter/painting.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_palette.dart';

/// Hard offset, zero-blur shadows. Mirrors `docs/design/tokens/shadows.json`.
///
/// Offsets are physical and are NOT mirrored in RTL. The private theme uses no
/// shadow except on the role ticket.
abstract final class TesskraShadows {
  static const publicSm = BoxShadow(
    color: TesskraPalette.ink,
    offset: Offset(3, 3),
  );
  static const publicMd = BoxShadow(
    color: TesskraPalette.ink,
    offset: Offset(4, 4),
  );
  static const publicLg = BoxShadow(
    color: TesskraPalette.ink,
    offset: Offset(6, 6),
  );
  static const privateTicket = BoxShadow(
    color: TesskraPalette.shadowDeep,
    offset: Offset(0, 6),
  );
}
