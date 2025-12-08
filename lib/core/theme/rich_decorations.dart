import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'dashboard_colors.dart';

/// Ultra-optimized RichDecorations using factory pattern
class RichDecorations {
  RichDecorations._();

  // Core factory method - replaces 31 static methods with one configurable method
  static BoxDecoration _createRich({
    required List<Color> gradientColors,
    Color? borderColor,
    double borderWidth = 2,
    double borderRadius = 16,
    List<BoxShadow>? shadows,
    bool isElevated = false,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null ? Border.all(color: borderColor, width: borderWidth) : null,
      boxShadow: shadows ?? (isElevated ? [BoxShadow(color: gradientColors.first.withOpacity(isPressed ? 0.2 : 0.4), blurRadius: isPressed ? 8 : 16, offset: Offset(0, isPressed ? 2 : 8))] : null),
    );
  }

  // Gold/Amber family
  static BoxDecoration goldCardRich({bool isElevated = false}) => _createRich(gradientColors: [DashboardColors.cardOrange.withOpacity(0.9), DashboardColors.gold, AppColorsUnified.goldLight], borderColor: DashboardColors.gold, isElevated: isElevated);
  static BoxDecoration goldCardTextured() => _createRich(gradientColors: [AppColorsUnified.backgroundLighter, AppColorsUnified.background, AppColorsUnified.goldLight], borderColor: AppColorsUnified.goldDarker, borderWidth: 3);
  static BoxDecoration goldButton3D({bool isPressed = false}) => _createRich(gradientColors: isPressed ? [DashboardColors.gold.withOpacity(0.7), DashboardColors.cardOrange.withOpacity(0.8)] : [DashboardColors.gold, DashboardColors.cardOrange], borderColor: AppColorsUnified.goldDarker, borderRadius: 12, isPressed: isPressed, isElevated: true);
  static BoxDecoration amberCardRich() => _createRich(gradientColors: [AppColorsUnified.warning, AppColorsUnified.warning, AppColorsUnified.warning], borderColor: AppColorsUnified.warning, isElevated: true);
  static BoxDecoration fabGold() => _createRich(gradientColors: [DashboardColors.gold, AppColorsUnified.goldLight, DashboardColors.cardOrange], borderColor: AppColorsUnified.goldDarker, borderRadius: 28, isElevated: true);

  // Emerald/Green family
  static BoxDecoration emeraldCardRich() => _createRich(gradientColors: [DashboardColors.emeraldLight, DashboardColors.emerald, DashboardColors.emeraldDeep], borderColor: DashboardColors.emeraldGlow, isElevated: true);
  static BoxDecoration emeraldGemCard({bool isElevated = false}) => _createRich(gradientColors: [DashboardColors.emeraldGlow, DashboardColors.emeraldLight, DashboardColors.emerald], borderColor: DashboardColors.emeraldDeep, borderWidth: 3, isElevated: isElevated);
  static BoxDecoration emeraldGemButton({bool isPressed = false}) => _createRich(gradientColors: isPressed ? [DashboardColors.emerald, DashboardColors.emeraldDeep] : [DashboardColors.emeraldGlow, DashboardColors.emerald], borderColor: DashboardColors.emeraldDeep, borderRadius: 12, isPressed: isPressed, isElevated: true);
  static BoxDecoration emeraldGemBadge() => _createRich(gradientColors: [DashboardColors.emeraldDeep, DashboardColors.emerald], borderRadius: 20, borderWidth: 0);

  // Ruby/Red family
  static BoxDecoration rubyGemCard({bool isElevated = false}) => _createRich(gradientColors: [AppColorsUnified.error, AppColorsUnified.error, AppColorsUnified.error], borderColor: AppColorsUnified.error, borderWidth: 3, isElevated: isElevated);
  static BoxDecoration rubyGemBadge() => _createRich(gradientColors: [AppColorsUnified.error, AppColorsUnified.error], borderRadius: 20, borderWidth: 0);

  // Sapphire/Blue family
  static BoxDecoration sapphireCardRich() => _createRich(gradientColors: [AppColorsUnified.companyBlue, AppColorsUnified.companyBlue, AppColorsUnified.companyBlue], borderColor: AppColorsUnified.companyBlue, isElevated: true);

  // Amethyst/Purple family
  static BoxDecoration amethystCardRich() => _createRich(gradientColors: [AppColorsUnified.companyBlueDark, AppColorsUnified.companyBlueDark, AppColorsUnified.companyBlueDark], borderColor: AppColorsUnified.companyBlueDark, isElevated: true);

  // Post type shortcuts (simple delegation)
  static BoxDecoration productCard() => goldCardTextured();
  static BoxDecoration serviceCard() => amethystCardRich();
  static BoxDecoration offerCard() => emeraldCardRich();
  static BoxDecoration questionCard() => amberCardRich();
  static BoxDecoration newsCard() => sapphireCardRich();
  static BoxDecoration pollCard() => _createRich(gradientColors: [AppColorsUnified.orange, AppColorsUnified.orange, AppColorsUnified.orange], borderColor: AppColorsUnified.orange, isElevated: true);

  // Utility decorations
  static BoxDecoration glowingCard({required Color glowColor, double intensity = 0.6}) {
    final safeIntensity = intensity.clamp(0.0, 1.0);
    return _createRich(
      gradientColors: [Colors.white, glowColor.withOpacity(0.1)], 
      shadows: [BoxShadow(color: glowColor.withOpacity(safeIntensity), blurRadius: 20, spreadRadius: 4)], 
      borderColor: glowColor.withOpacity(0.3)
    );
  }
  static BoxDecoration embossedCard({Color baseColor = Colors.white, double depth = 8}) => BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), offset: Offset(-depth, -depth), blurRadius: depth * 2), BoxShadow(color: Colors.white.withOpacity(0.7), offset: Offset(depth, depth), blurRadius: depth * 2)]);
  static BoxDecoration chip({required Color color, bool isSelected = false}) => BoxDecoration(color: isSelected ? color : color.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: isSelected ? 2 : 1));

  // Complex widgets
  static Widget doubleBorderCard({required Widget child, Color? outerColor, Color innerColor = Colors.white}) {
    final effectiveOuterColor = outerColor ?? DashboardColors.gold;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: effectiveOuterColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: effectiveOuterColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: innerColor, borderRadius: BorderRadius.circular(16)), child: child),
    );
  }

  static Widget emeraldFacetsOverlay({required Widget child, double opacity = 0.15}) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return Stack(children: [
      child,
      Positioned.fill(child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [DashboardColors.emeraldGlow.withOpacity(safeOpacity), Colors.transparent, DashboardColors.emeraldDeep.withOpacity(safeOpacity)], stops: const [0.0, 0.5, 1.0], begin: Alignment.topLeft, end: Alignment.bottomRight))))),
    ]);
  }

  static Widget goldFoilOverlay({required Widget child, double opacity = 0.2}) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return Stack(children: [
      child,
      Positioned.fill(child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [DashboardColors.gold.withOpacity(safeOpacity), Colors.transparent, AppColorsUnified.goldLight.withOpacity(safeOpacity)], stops: const [0.0, 0.5, 1.0], begin: Alignment.topLeft, end: Alignment.bottomRight))))),
    ]);
  }

  // Material-style utilities
  static ShapeBorder materialShape({double radius = 16}) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  static EdgeInsets padding({double all = 16}) => EdgeInsets.all(all);
  static EdgeInsets paddingH({double horizontal = 16, double vertical = 12}) => EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
}
