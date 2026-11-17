import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';

/// System bar icons per surface (SCREEN_SPECIFICATIONS §1 "System bars"):
/// dark icons on paper, light icons on carbon. The bars stay transparent;
/// the app draws behind them.
abstract final class TesskraSystemBars {
  static const paper = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const carbon = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static SystemUiOverlayStyle of(TesskraSurface surface) => switch (surface) {
    TesskraSurface.paper => paper,
    TesskraSurface.carbon => carbon,
  };
}
