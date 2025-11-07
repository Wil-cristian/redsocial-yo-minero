import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_colors.dart';

final ThemeData yoMineroTheme = _buildTheme();

ThemeData _buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  final scheme = ColorScheme.fromSeed(
    seedColor: DashboardColors.primary,
    brightness: Brightness.light,
    primary: DashboardColors.primary,
  ).copyWith(
    primary: DashboardColors.primary,
    primaryContainer: DashboardColors.primaryLight,
    secondary: DashboardColors.accent,
    secondaryContainer: DashboardColors.accentLight,
    surface: DashboardColors.white,
    error: DashboardColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: DashboardColors.charcoal,
    onError: DashboardColors.white,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: DashboardColors.white,
    primaryColor: DashboardColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: DashboardColors.white,
      foregroundColor: DashboardColors.charcoal,
      elevation: 0,
      shadowColor: DashboardColors.gray200,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: DashboardColors.charcoal,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: DashboardColors.charcoal,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: DashboardColors.charcoal,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: DashboardColors.gray700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: DashboardColors.charcoal,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DashboardColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 2,
        shadowColor: DashboardColors.primaryDark.withValues(alpha: 0.3),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DashboardColors.gray50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DashboardColors.gray300, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DashboardColors.gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DashboardColors.primary, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: DashboardColors.gray100,
      selectedColor: DashboardColors.primaryLight,
      labelStyle: TextStyle(color: DashboardColors.charcoal),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DashboardColors.charcoal,
      contentTextStyle: TextStyle(color: DashboardColors.white),
    ),
    cardTheme: CardThemeData(
      color: DashboardColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      shadowColor: DashboardColors.gray300,
      margin: const EdgeInsets.all(8),
    ),
    dividerColor: DashboardColors.gray200,
    iconTheme: IconThemeData(color: DashboardColors.gray700),
  );
}

// Removed unused PalettePage widget (was only for manual color preview).
