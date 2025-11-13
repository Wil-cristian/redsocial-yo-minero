import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors_unified.dart';

final ThemeData yoMineroTheme = _buildTheme();

ThemeData _buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColorsUnified.orange,
    brightness: Brightness.light,
    primary: AppColorsUnified.orange,
  ).copyWith(
    primary: AppColorsUnified.orange,
    primaryContainer: AppColorsUnified.lighten(AppColorsUnified.orange, 0.2),
    secondary: AppColorsUnified.gold,
    secondaryContainer: AppColorsUnified.lighten(AppColorsUnified.gold, 0.3),
    surface: AppColorsUnified.pureWhite,
    error: AppColorsUnified.error,
    onPrimary: AppColorsUnified.pureWhite,
    onSecondary: AppColorsUnified.pureWhite,
    onSurface: AppColorsUnified.charcoal,
    onError: AppColorsUnified.pureWhite,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColorsUnified.pureWhite,
    primaryColor: AppColorsUnified.orange,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsUnified.pureWhite,
      foregroundColor: AppColorsUnified.charcoal,
      elevation: 0,
      shadowColor: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.1),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: AppColorsUnified.charcoal,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: AppColorsUnified.charcoal,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: AppColorsUnified.charcoal,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: AppColorsUnified.textSecondary,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: AppColorsUnified.charcoal,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsUnified.orange,
        foregroundColor: AppColorsUnified.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 2,
        shadowColor: AppColorsUnified.fade(AppColorsUnified.darken(AppColorsUnified.orange, 0.2), 0.3),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsUnified.background,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.2), width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorsUnified.orange, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsUnified.lighten(AppColorsUnified.background, 0.05),
      selectedColor: AppColorsUnified.lighten(AppColorsUnified.orange, 0.2),
      labelStyle: TextStyle(color: AppColorsUnified.charcoal),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorsUnified.charcoal,
      contentTextStyle: TextStyle(color: AppColorsUnified.pureWhite),
    ),
    cardTheme: CardThemeData(
      color: AppColorsUnified.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      shadowColor: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.2),
      margin: const EdgeInsets.all(8),
    ),
    dividerColor: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.1),
    iconTheme: const IconThemeData(color: AppColorsUnified.textSecondary),
  );
}

// Removed unused PalettePage widget (was only for manual color preview).
