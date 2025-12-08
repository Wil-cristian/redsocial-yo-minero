import 'package:flutter/material.dart';
import 'achievement_models.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// Helper para obtener colores y gradientes según el tier de gema
class GemColorHelper {
  static Color getColorForTier(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        return AppColorsUnified.orangeDark; // Bronce más oscuro
      case GemTier.silver:
        return AppColorsUnified.orangeMedium; // Plata con tono medio
      case GemTier.gold:
        return AppColorsUnified.orange;
      case GemTier.emerald:
        return AppColorsUnified.gold; // Esmeralda → Oro brillante
      case GemTier.diamond:
        return AppColorsUnified.orangeLight; // Diamante → Naranja claro
    }
  }

  static LinearGradient getGradientForTier(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        // Gradiente bronce: naranja oscuro a naranja medio
        return LinearGradient(
          colors: [
            AppColorsUnified.orangeDark,
            AppColorsUnified.darken(AppColorsUnified.orange, 0.2),
          ],
        );
      case GemTier.silver:
        // Gradiente plata: naranja medio
        return LinearGradient(
          colors: [
            AppColorsUnified.orangeMedium,
            AppColorsUnified.orange,
          ],
        );
      case GemTier.gold:
        return AppColorsUnified.orangeGradient;
      case GemTier.emerald:
        // Gradiente esmeralda → oro brillante
        return LinearGradient(
          colors: [
            AppColorsUnified.gold,
            AppColorsUnified.lighten(AppColorsUnified.gold, 0.1),
          ],
        );
      case GemTier.diamond:
        // Gradiente diamante → naranja claro brillante
        return LinearGradient(
          colors: [
            AppColorsUnified.orangeLight,
            AppColorsUnified.lighten(AppColorsUnified.orange, 0.3),
          ],
        );
    }
  }

  static RadialGradient? getRadialGradientForTier(GemTier tier) {
    switch (tier) {
      case GemTier.emerald:
        // Gradiente radial esmeralda → oro
        return RadialGradient(
          colors: [
            AppColorsUnified.lighten(AppColorsUnified.gold, 0.2),
            AppColorsUnified.gold,
            AppColorsUnified.orange,
          ],
        );
      case GemTier.diamond:
        // Gradiente radial diamante → naranja claro
        return RadialGradient(
          colors: [
            AppColorsUnified.pureWhite.withOpacity(0.9),
            AppColorsUnified.orangeLight,
            AppColorsUnified.orange,
          ],
        );
      default:
        return null;
    }
  }

  static List<BoxShadow> getShadowsForTier(GemTier tier, {bool isGlowing = false}) {
    final color = getColorForTier(tier);
    
    if (isGlowing) {
      return [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 4,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static IconData getIconForTier(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        return Icons.military_tech;
      case GemTier.silver:
        return Icons.workspace_premium;
      case GemTier.gold:
        return Icons.stars;
      case GemTier.emerald:
        return Icons.diamond_outlined;
      case GemTier.diamond:
        return Icons.diamond;
    }
  }
}
