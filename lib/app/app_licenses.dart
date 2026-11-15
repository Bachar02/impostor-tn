import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';

/// Registers the bundled font and icon licences so they appear in the
/// in-app licence page (PRD §13: ship required attribution files).
void registerAppLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield await _entry('Noto Kufi Arabic', TesskraLicenseFiles.notoKufiArabic);
    yield await _entry(
      'IBM Plex Sans Arabic',
      TesskraLicenseFiles.ibmPlexSansArabic,
    );
    yield await _entry('Lucide Icons', TesskraLicenseFiles.lucide);
  });
}

Future<LicenseEntry> _entry(String package, String assetPath) async {
  final text = await rootBundle.loadString(assetPath);
  return LicenseEntryWithLineBreaks([package], text);
}
