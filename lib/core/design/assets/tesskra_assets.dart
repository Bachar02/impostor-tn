/// Paths to bundled design assets.
///
/// Assets are bundled straight from `docs/design/assets/` (single source of
/// truth, see ADR-0004). `test/core/design/asset_manifest_test.dart` checks
/// every path here against the files on disk and the asset manifest.
library;

const _root = 'docs/design/assets';

/// The approved icon set (`docs/design/assets/icons/ic_<name>.svg`).
enum TesskraIcons {
  alert('alert'),
  arrowRight('arrow_right'),
  check('check'),
  chevronLeft('chevron_left'),
  circleQuestionMark('circle_question_mark'),
  equal('equal'),
  eye('eye'),
  eyeOff('eye_off'),
  info('info'),
  lock('lock'),
  messageCircle('message_circle'),
  pencil('pencil'),
  plus('plus'),
  rotateCcw('rotate_ccw'),
  settings('settings'),
  smartphone('smartphone'),
  ticket('ticket'),
  trash('trash'),
  trophy('trophy'),
  user('user'),
  users('users'),
  vibrate('vibrate'),
  volume2('volume_2'),
  volumeX('volume_x'),
  vote('vote'),
  x('x');

  const TesskraIcons(this._fileName);

  final String _fileName;

  /// Bundle path, e.g. `docs/design/assets/icons/ic_eye_off.svg`.
  String get assetPath => '$_root/icons/ic_$_fileName.svg';
}

abstract final class TesskraLogos {
  static const ticketLockup = '$_root/logo/logo_ticket_lockup.svg';
  static const wordmarkInk = '$_root/logo/wordmark_ar_ink.svg';
  static const wordmarkPaper = '$_root/logo/wordmark_ar_paper.svg';
  static const stampTn = '$_root/logo/stamp_tn.svg';

  static const all = [ticketLockup, wordmarkInk, wordmarkPaper, stampTn];
}

/// Licence texts that must ship with the app (PRD §13, design handoff §3).
abstract final class TesskraLicenseFiles {
  static const notoKufiArabic = '$_root/fonts/OFL-NotoKufiArabic.txt';
  static const ibmPlexSansArabic = '$_root/fonts/OFL-IBMPlexSansArabic.txt';
  static const lucide = '$_root/icons/LICENSE-lucide.txt';

  static const all = [notoKufiArabic, ibmPlexSansArabic, lucide];
}
