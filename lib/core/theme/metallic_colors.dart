import 'package:flutter/material.dart';
import 'app_colors_unified.dart';

/// 💎 COLORES METÁLICOS - NOW DELEGATED TO AppColorsUnified
/// Todos los colores derivan del sistema de 10 base
class MetallicColors {
  MetallicColors._();

  // ============================================
  // 🥇 ORO - Del sistema de 10
  // ============================================
  
  static LinearGradient get goldShine => AppColorsUnified.goldGradient;
  static LinearGradient get goldMetallic => AppColorsUnified.goldGradient;
  static LinearGradient get goldButton => AppColorsUnified.goldGradient;

  // ============================================
  // 💎 ESMERALDA - Del success (verde)
  // ============================================
  
  static LinearGradient get emeraldShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.success, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.success, 0.2),
      AppColorsUnified.success,
      AppColorsUnified._darken(AppColorsUnified.success, 0.2),
      AppColorsUnified._darken(AppColorsUnified.success, 0.3),
    ],
  );
  
  static LinearGradient get emeraldCrystal => emeraldShine;

  // ============================================
  // 🪙 PLATINO/PLATA - Del textSecondary
  // ============================================
  
  static LinearGradient get platinumShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.surface,
      AppColorsUnified._lighten(AppColorsUnified.textSecondary, 0.4),
      AppColorsUnified._lighten(AppColorsUnified.textSecondary, 0.3),
      AppColorsUnified.textSecondary,
      AppColorsUnified._darken(AppColorsUnified.textSecondary, 0.1),
    ],
  );
  
  static LinearGradient get silverMetallic => platinumShine;

  // ============================================
  // 🟤 BRONCE - Del gold oscurecido
  // ============================================
  
  static LinearGradient get bronzeShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._darken(AppColorsUnified.gold, 0.1),
      AppColorsUnified._darken(AppColorsUnified.gold, 0.2),
      AppColorsUnified._darken(AppColorsUnified.gold, 0.3),
      AppColorsUnified._darken(AppColorsUnified.gold, 0.4),
      AppColorsUnified._darken(AppColorsUnified.gold, 0.5),
    ],
  );

  // ============================================
  // 🔷 ZAFIRO - Del companyBlue
  // ============================================
  
  static LinearGradient get sapphireShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified._darken(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified._darken(AppColorsUnified.companyBlue, 0.3),
    ],
  );

  // ============================================
  // 🔮 AMATISTA - Del companyBlue (púrpura → azul)
  // ============================================
  
  static LinearGradient get amethystShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified._darken(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified._darken(AppColorsUnified.companyBlue, 0.3),
    ],
  );

  // ============================================
  // 🍊 ÁMBAR - Del warning (naranja/amarillo)
  // ============================================
  
  static LinearGradient get amberShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.warning, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.warning, 0.2),
      AppColorsUnified.warning,
      AppColorsUnified._darken(AppColorsUnified.warning, 0.2),
      AppColorsUnified._darken(AppColorsUnified.warning, 0.3),
    ],
  );

  // ============================================
  // 💗 RUBÍ - Del error (rojo)
  // ============================================
  
  static LinearGradient get rubyShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.error, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.error, 0.2),
      AppColorsUnified.error,
      AppColorsUnified._darken(AppColorsUnified.error, 0.2),
      AppColorsUnified._darken(AppColorsUnified.error, 0.3),
    ],
  );

  // ============================================
  // 🌊 AGUAMARINA - Del companyBlue
  // ============================================
  
  static LinearGradient get aquamarineShine => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified._darken(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified._darken(AppColorsUnified.companyBlue, 0.3),
    ],
  );

  // ============================================
  // 🎨 GRADIENTES RADIALES
  // ============================================
  
  static RadialGradient get goldRadial => RadialGradient(
    center: const Alignment(0.3, -0.5),
    radius: 1.5,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.gold, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.gold, 0.2),
      AppColorsUnified.gold,
      AppColorsUnified._darken(AppColorsUnified.gold, 0.2),
    ],
  );
  
  static RadialGradient get emeraldRadial => RadialGradient(
    center: const Alignment(0.3, -0.5),
    radius: 1.5,
    colors: [
      AppColorsUnified._lighten(AppColorsUnified.success, 0.3),
      AppColorsUnified._lighten(AppColorsUnified.success, 0.2),
      AppColorsUnified.success,
      AppColorsUnified._darken(AppColorsUnified.success, 0.2),
    ],
  );

  // ============================================
  // ✨ EFECTOS ESPECIALES
  // ============================================
  
  static LinearGradient get goldShimmer => LinearGradient(
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    colors: [
      AppColorsUnified._fade(AppColorsUnified.gold, 0.0),
      AppColorsUnified._fade(AppColorsUnified.gold, 0.3),
      AppColorsUnified._fade(AppColorsUnified.gold, 0.5),
      AppColorsUnified._fade(AppColorsUnified.gold, 0.3),
      AppColorsUnified._fade(AppColorsUnified.gold, 0.0),
    ],
  );
  
  static Color get goldOverlay => AppColorsUnified._fade(AppColorsUnified.gold, 0.1);
  static Color get emeraldOverlay => AppColorsUnified._fade(AppColorsUnified.success, 0.1);
  static Color get silverOverlay => AppColorsUnified._fade(AppColorsUnified.textSecondary, 0.1);
}

/// 🎨 HELPER: Decoraciones metálicas usando AppColorsUnified
class MetallicDecoration {
  static BoxDecoration gold({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: AppColorsUnified.goldGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColorsUnified._fade(AppColorsUnified.gold, 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColorsUnified._fade(AppColorsUnified.goldLight, 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration emerald({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.emeraldShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColorsUnified._fade(AppColorsUnified.success, 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration platinum({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.platinumShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColorsUnified._fade(AppColorsUnified.textPrimary, 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration sapphire({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.sapphireShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColorsUnified._fade(AppColorsUnified.companyBlue, 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
