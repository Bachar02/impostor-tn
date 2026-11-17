import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:impostor_tn/data/content/bundled_content_source.dart';
import 'package:impostor_tn/data/content/development_content.dart';
import 'package:impostor_tn/data/persistence/file_state_store.dart';
import 'package:impostor_tn/data/platform/app_platform.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';

/// Binds the application layer to the data layer (ADR-0001 composition
/// root). Development content is reachable only in debug builds (ADR-0009).
List<Override> appOverrides() {
  const channel = kDebugMode
      ? ContentChannel.development
      : ContentChannel.release;
  return [
    stateStoreProvider.overrideWith(
      (ref) async => FileStateStore(await AppPlatform.privateFilesDirectory()),
    ),
    contentSourceProvider.overrideWithValue(_contentSource(channel)),
    contentChannelProvider.overrideWithValue(channel),
    screenProtectionProvider.overrideWithValue(
      const PlatformScreenProtection(),
    ),
  ];
}

ContentSource _contentSource(ContentChannel channel) {
  final bundled = BundledContentSource(rootBundle, channel: channel);
  // D-35: synthetic development words exist in debug builds only. kDebugMode
  // is a compile-time constant, so release builds drop this branch and the
  // development data with it (checked by test and by a release-binary grep).
  if (kDebugMode) {
    return DevelopmentContentSource(bundled);
  }
  return bundled;
}
