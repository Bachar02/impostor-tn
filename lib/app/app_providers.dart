import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:impostor_tn/data/content/bundled_content_source.dart';
import 'package:impostor_tn/data/persistence/file_state_store.dart';
import 'package:impostor_tn/data/platform/app_platform.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';

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
    contentSourceProvider.overrideWithValue(
      BundledContentSource(rootBundle, channel: channel),
    ),
    contentChannelProvider.overrideWithValue(channel),
    screenProtectionProvider.overrideWithValue(
      const PlatformScreenProtection(),
    ),
  ];
}
