import 'package:flutter/material.dart';
import 'app_colors_unified.dart';

/// Legacy color constants - NOW DELEGATED TO AppColorsUnified
class YoMineroColors {
  YoMineroColors._();
  
  static Color get machineryOrange => AppColorsUnified.orange;
  static Color get goldYellow => AppColorsUnified.gold;
  static Color get earthDark => AppColorsUnified._darken(AppColorsUnified.textPrimary, 0.2);
  static Color get sandLight => AppColorsUnified._lighten(AppColorsUnified.background, 0.05);
  static Color get charcoal => AppColorsUnified.textPrimary;
  static Color get stoneGray => AppColorsUnified.textSecondary;
  static Color get alertRed => AppColorsUnified.error;
  static Color get successGreen => AppColorsUnified.success;
  static Color get infoBlue => AppColorsUnified.companyBlue;
  static Color get copper => AppColorsUnified._darken(AppColorsUnified.gold, 0.2);
  static Color get silver => AppColorsUnified.silver;
  static Color get graphite => AppColorsUnified._darken(AppColorsUnified.textSecondary, 0.3);
}

/// Semantic palette - NOW DELEGATED TO AppColorsUnified
class AppColors {
  AppColors._();

  // Brand / primary system
  static Color get primary => AppColorsUnified.orange;
  static Color get primaryContainer => AppColorsUnified._lighten(AppColorsUnified.orange, 0.4);
  static Color get primaryHover => AppColorsUnified._darken(AppColorsUnified.orange, 0.1);
  static Color get primaryPressed => AppColorsUnified._darken(AppColorsUnified.orange, 0.2);

  // Secondary / accent
  static Color get secondary => AppColorsUnified.gold;
  static Color get secondaryContainer => AppColorsUnified._lighten(AppColorsUnified.gold, 0.4);

  // Neutrals / backgrounds
  static Color get background => AppColorsUnified.background;
  static Color get backgroundAlt => AppColorsUnified.backgroundDark;
  static Color get surface => AppColorsUnified.surface;
  static Color get surfaceAlt => AppColorsUnified._lighten(AppColorsUnified.surface, 0.02);
  static Color get outline => AppColorsUnified._lighten(AppColorsUnified.textSecondary, 0.3);

  // Text
  static Color get textPrimary => AppColorsUnified.textPrimary;
  static Color get textSecondary => AppColorsUnified.textSecondary;
  static Color get textDisabled => AppColorsUnified.textDisabled;

  // States
  static Color get success => AppColorsUnified.success;
  static Color get successContainer => AppColorsUnified._lighten(AppColorsUnified.success, 0.4);
  static Color get error => AppColorsUnified.error;
  static Color get errorContainer => AppColorsUnified._lighten(AppColorsUnified.error, 0.4);
  static Color get warning => AppColorsUnified.warning;
  static Color get warningContainer => AppColorsUnified._lighten(AppColorsUnified.warning, 0.4);
  static Color get info => AppColorsUnified.companyBlue;
  static Color get infoContainer => AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.4);

  // Utility
  static Color get focus => AppColorsUnified._darken(AppColorsUnified.gold, 0.3);
  static Color get black => AppColorsUnified.textPrimary;
  static Color get white => AppColorsUnified.surface;

  /// Returns best contrasting on-color for given background
  static Color onColor(Color background) =>
      background.computeLuminance() > 0.54 
        ? AppColorsUnified.textPrimary 
        : AppColorsUnified.surface;
}

/// Context extension - Delegated to AppColorsUnified
extension AppColorScheme on BuildContext {
  Color get cPrimary => AppColorsUnified.orange;
  Color get cPrimaryContainer => AppColorsUnified._lighten(AppColorsUnified.orange, 0.4);
  Color get cSecondary => AppColorsUnified.gold;
  Color get cSecondaryContainer => AppColorsUnified._lighten(AppColorsUnified.gold, 0.4);
  Color get cBg => AppColorsUnified.background;
  Color get cBgAlt => AppColorsUnified.backgroundDark;
  Color get cSurface => AppColorsUnified.surface;
  Color get cSurfaceAlt => AppColorsUnified._lighten(AppColorsUnified.surface, 0.02);
  Color get cOutline => AppColorsUnified._lighten(AppColorsUnified.textSecondary, 0.3);
  Color get cText => AppColorsUnified.textPrimary;
  Color get cTextSecondary => AppColorsUnified.textSecondary;
  Color get cSuccess => AppColorsUnified.success;
  Color get cError => AppColorsUnified.error;
  Color get cWarning => AppColorsUnified.warning;
  Color get cInfo => AppColorsUnified.companyBlue;
}

/// Color utilities - Using AppColorsUnified helpers
extension YoMineroColorUtils on Color {
  Color darken([double amount = .1]) => AppColorsUnified._darken(this, amount);
  Color lighten([double amount = .1]) => AppColorsUnified._lighten(this, amount);
}
