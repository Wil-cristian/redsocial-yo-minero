import 'package:flutter/material.dart';
import '../theme/dashboard_colors.dart';
import 'achievement_models.dart';

/// Helper para obtener colores y gradientes según el tier de gema
class GemColorHelper {
  static Color getColorForTier(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        return DashboardColors.bronze;
      case GemTier.silver:
        return DashboardColors.silver;
      case GemTier.gold:
        return DashboardColors.primary;
      case GemTier.emerald:
        return DashboardColors.emerald;
      case GemTier.diamond:
        return DashboardColors.diamond;
    }
  }

  static LinearGradient getGradientForTier(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        return DashboardColors.bronzeGradient;
      case GemTier.silver:
        return DashboardColors.silverGradient;
      case GemTier.gold:
        return DashboardColors.primaryGradient;
      case GemTier.emerald:
        return DashboardColors.emeraldGemGradient;
      case GemTier.diamond:
        return DashboardColors.diamondGemGradient;
    }
  }

  static RadialGradient? getRadialGradientForTier(GemTier tier) {
    switch (tier) {
      case GemTier.emerald:
        return DashboardColors.emeraldRadialGradient;
      case GemTier.diamond:
        return DashboardColors.diamondRadialGradient;
      default:
        return null;
    }
  }

  static List<BoxShadow> getShadowsForTier(GemTier tier, {bool isGlowing = false}) {
    final color = getColorForTier(tier);
    
    if (isGlowing) {
      return [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 40,
          spreadRadius: 4,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
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
