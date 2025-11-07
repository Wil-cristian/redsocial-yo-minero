import 'package:flutter/material.dart';
import 'app_colors_unified.dart';

/// 🏆 PALETA DE COLORES PREMIUM - YOMINERO
/// ⚠️ DELEGADO A AppColorsUnified - Sistema de 10 colores base
/// 
/// TODOS los colores ahora derivan del sistema centralizado.
/// Cambiar los 10 base en AppColorsUnified actualiza TODO automáticamente.
class DashboardColors {
  DashboardColors._();

  // ============================================
  // 🎨 ESQUEMA PRINCIPAL - Del Sistema de 10
  // ============================================
  
  static Color get primary => AppColorsUnified.gold;
  static Color get primaryLight => AppColorsUnified.goldLight;
  static Color get primaryDark => AppColorsUnified.goldDark;
  
  static Color get accent => AppColorsUnified.textSecondary;
  static Color get accentLight => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3);
  static Color get accentDark => AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.2);
  
  static LinearGradient get primaryGradient => AppColorsUnified.goldGradient;
  static LinearGradient get epicGradient => AppColorsUnified.goldGradient;

  // ============================================
  // ORO - Derivado de gold
  // ============================================
  
  static Color get gold => AppColorsUnified.gold;
  static Color get goldLight => AppColorsUnified.goldLight;
  static Color get goldDark => AppColorsUnified.goldDark;
  static Color get goldMetallic => AppColorsUnified.goldLight;
  static Color get goldAntique => AppColorsUnified.gold;
  static Color get goldShadow => AppColorsUnified.fade(AppColorsUnified.gold, 0.3);

  // ============================================
  // NARANJA - Derivado de orange
  // ============================================
  
  static Color get orange => AppColorsUnified.orange;
  static Color get orangeBright => AppColorsUnified.orangeLight;
  static Color get orangeDark => AppColorsUnified.orangeDark;
  static Color get orangeGlow => AppColorsUnified.orangeLight;
  static Color get orangeShadow => AppColorsUnified.fade(AppColorsUnified.orange, 0.3);
  
  // ============================================
  // PLATA/MADERA - Derivado de textSecondary
  // ============================================
  
  static Color get wood => AppColorsUnified.textSecondary;
  static Color get woodLight => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3);
  static Color get woodDark => AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.2);
  static Color get woodGolden => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2);

  // ============================================
  // GRADIENTES - Usando los 10 base
  // ============================================
  
  static LinearGradient get goldGradient => AppColorsUnified.goldGradient;
  static LinearGradient get goldShine => AppColorsUnified.goldGradient;
  static LinearGradient get orangeGradient => AppColorsUnified.orangeGradient;
  static LinearGradient get orangeFireGradient => AppColorsUnified.orangeGradient;
  static LinearGradient get woodGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3),
      AppColorsUnified.textSecondary,
      AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.2),
    ],
  );

  // ============================================
  // ESMERALDA - Derivado de success (verde)
  // ============================================
  
  static Color get emeraldDeep => AppColorsUnified.darken(AppColorsUnified.success, 0.3);
  static Color get emerald => AppColorsUnified.success;
  static Color get emeraldLight => AppColorsUnified.lighten(AppColorsUnified.success, 0.2);
  static Color get emeraldGlow => AppColorsUnified.lighten(AppColorsUnified.success, 0.3);
  static Color get emeraldTeal => AppColorsUnified.companyBlue;
  static Color get emeraldTranslucent => AppColorsUnified.fade(AppColorsUnified.success, 0.5);
  
  static LinearGradient get emeraldGemGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.success, 0.3),
      AppColorsUnified.lighten(AppColorsUnified.success, 0.2),
      AppColorsUnified.success,
      AppColorsUnified.darken(AppColorsUnified.success, 0.2),
      AppColorsUnified.darken(AppColorsUnified.success, 0.3),
    ],
  );
  
  static LinearGradient get emeraldFacetedGradient => emeraldGemGradient;
  
  static RadialGradient get emeraldRadialGradient => RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      AppColorsUnified.surface,
      AppColorsUnified.lighten(AppColorsUnified.success, 0.3),
      AppColorsUnified.success,
      AppColorsUnified.darken(AppColorsUnified.success, 0.3),
    ],
  );

  // ============================================
  // RUBÍ - Derivado de error (rojo)
  // ============================================
  
  static Color get rubyDeep => AppColorsUnified.darken(AppColorsUnified.error, 0.3);
  static Color get ruby => AppColorsUnified.error;
  static Color get rubyLight => AppColorsUnified.lighten(AppColorsUnified.error, 0.2);
  static Color get rubyGlow => AppColorsUnified.lighten(AppColorsUnified.error, 0.3);
  static Color get rubyPink => AppColorsUnified.lighten(AppColorsUnified.error, 0.2);
  static Color get rubyTranslucent => AppColorsUnified.fade(AppColorsUnified.error, 0.5);
  
  static LinearGradient get rubyGemGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.error, 0.3),
      AppColorsUnified.lighten(AppColorsUnified.error, 0.2),
      AppColorsUnified.error,
      AppColorsUnified.darken(AppColorsUnified.error, 0.2),
      AppColorsUnified.darken(AppColorsUnified.error, 0.3),
    ],
  );
  
  static LinearGradient get rubyFacetedGradient => rubyGemGradient;
  static RadialGradient get rubyRadialGradient => RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      AppColorsUnified.surface,
      AppColorsUnified.lighten(AppColorsUnified.error, 0.3),
      AppColorsUnified.error,
      AppColorsUnified.darken(AppColorsUnified.error, 0.3),
    ],
  );

  // ============================================
  // ZAFIRO - Derivado de companyBlue (azul)
  // ============================================
  
  static Color get sapphireDeep => AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.3);
  static Color get sapphire => AppColorsUnified.companyBlue;
  static Color get sapphireLight => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.2);
  static Color get sapphireGlow => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.3);
  static Color get sapphireCyan => AppColorsUnified.companyBlue;
  static Color get sapphireTranslucent => AppColorsUnified.fade(AppColorsUnified.companyBlue, 0.5);
  
  static LinearGradient get sapphireGemGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.3),
      AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.3),
    ],
  );
  
  static LinearGradient get sapphireFacetedGradient => sapphireGemGradient;
  static RadialGradient get sapphireRadialGradient => RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      AppColorsUnified.surface,
      AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.3),
      AppColorsUnified.companyBlue,
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.3),
    ],
  );

  // ============================================
  // DIAMANTE - Derivado de surface/textSecondary
  // ============================================
  
  static Color get diamondDeep => AppColorsUnified.textSecondary;
  static Color get diamond => AppColorsUnified.surface;
  static Color get diamondLight => AppColorsUnified.lighten(AppColorsUnified.surface, 0.02);
  static Color get diamondGlow => AppColorsUnified.lighten(AppColorsUnified.surface, 0.05);
  static Color get diamondIridescent => AppColorsUnified.lighten(AppColorsUnified.surface, 0.03);
  static Color get diamondTranslucent => AppColorsUnified.fade(AppColorsUnified.surface, 0.5);
  
  static LinearGradient get diamondGemGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.surface,
      AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3),
      AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2),
      AppColorsUnified.textSecondary,
    ],
  );
  
  static LinearGradient get diamondFacetedGradient => diamondGemGradient;
  static RadialGradient get diamondRadialGradient => RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      AppColorsUnified.surface,
      AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
      AppColorsUnified.textSecondary,
    ],
  );

  // ============================================
  // PALETA DE SOPORTE
  // ============================================
  
  static Color get charcoal => AppColorsUnified.textPrimary;
  static Color get silver => AppColorsUnified.silver;
  static Color get bronze => AppColorsUnified.darken(AppColorsUnified.gold, 0.3);
  static Color get minerBlue => AppColorsUnified.companyBlue;
  
  // ============================================
  // COLORES DE ESTADO
  // ============================================
  
  static Color get error => AppColorsUnified.error;
  static Color get warning => AppColorsUnified.warning;
  static Color get success => AppColorsUnified.success;
  static Color get info => AppColorsUnified.companyBlue;

  // ============================================
  // GRADIENTES PARA CARDS
  // ============================================
  
  static LinearGradient get productGradient => AppColorsUnified.goldGradient;
  
  static LinearGradient get serviceGradient => LinearGradient(
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get offerGradient => LinearGradient(
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.success, 0.2),
      AppColorsUnified.success,
      AppColorsUnified.darken(AppColorsUnified.success, 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get questionGradient => LinearGradient(
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.warning, 0.2),
      AppColorsUnified.warning,
      AppColorsUnified.darken(AppColorsUnified.warning, 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get newsGradient => LinearGradient(
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get pollGradient => LinearGradient(
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.success, 0.2),
      AppColorsUnified.success,
      AppColorsUnified.darken(AppColorsUnified.success, 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get communityGradient => LinearGradient(
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.2),
      AppColorsUnified.companyBlue,
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // SISTEMA DE BLANCOS Y GRISES
  // ============================================
  
  static Color get white => AppColorsUnified.surface;
  static Color get offWhite => AppColorsUnified.lighten(AppColorsUnified.background, 0.02);
  static Color get snowWhite => AppColorsUnified.background;
  
  static Color get gray50 => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4);
  static Color get gray100 => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.35);
  static Color get gray200 => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3);
  static Color get gray300 => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2);
  static Color get gray400 => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.1);
  static Color get gray500 => AppColorsUnified.textSecondary;
  static Color get gray600 => AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.1);
  static Color get gray700 => AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.2);
  static Color get gray800 => AppColorsUnified.textPrimary;
  static Color get gray900 => AppColorsUnified.darken(AppColorsUnified.textPrimary, 0.1);

  // ============================================
  // CONSTANTES DE FONDO
  // ============================================
  
  static Color get background => AppColorsUnified.background;
  static Color get cardBackground => AppColorsUnified.surface;
  static Color get surfaceBackground => AppColorsUnified.background;
  static Color get divider => AppColorsUnified.divider;
  static Color get border => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3);
  static Color get lightGray => AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.35);

  // ============================================
  // COLORES VIBRANTES PARA CARDS (el ROSA problemático aquí)
  // ============================================
  
  // Oro
  static Color get cardOrange => AppColorsUnified.gold;
  static Color get cardOrangeBg => AppColorsUnified.lighten(AppColorsUnified.gold, 0.4);
  static Color get cardOrange2 => AppColorsUnified.darken(AppColorsUnified.gold, 0.1);
  static Color get cardOrange2Bg => AppColorsUnified.lighten(AppColorsUnified.gold, 0.38);
  
  // Morados → Azul
  static Color get cardPurple => AppColorsUnified.companyBlue;
  static Color get cardPurpleBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.4);
  static Color get cardBluePurple => AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.1);
  
  // Verdes
  static Color get cardGreen => AppColorsUnified.success;
  static Color get cardGreenBg => AppColorsUnified.lighten(AppColorsUnified.success, 0.4);
  static Color get cardWorkerGreen => AppColorsUnified.darken(AppColorsUnified.success, 0.1);
  static Color get cardDarkGreen => AppColorsUnified.darken(AppColorsUnified.success, 0.2);
  static Color get cardDarkGreenBg => AppColorsUnified.lighten(AppColorsUnified.success, 0.38);
  static Color get cardTeal => AppColorsUnified.companyBlue;
  static Color get cardTealBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.4);
  
  // Azules
  static Color get cardBlue => AppColorsUnified.companyBlue;
  static Color get cardBlueBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.4);
  static Color get cardDarkBlue => AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.1);
  static Color get cardDarkBlueBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.38);
  static Color get cardIndigo => AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.05);
  static Color get cardIndigoBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.38);
  
  // ROSAS → Error (ESTE ERA EL PROBLEMA #EC4899)
  static Color get cardPink => AppColorsUnified.error;  // ← El rosa "Oferta Especial"
  static Color get cardPinkBg => AppColorsUnified.lighten(AppColorsUnified.error, 0.4);
  static Color get cardWorkerPink => AppColorsUnified.darken(AppColorsUnified.error, 0.1);
  static Color get cardWorkerPinkBg => AppColorsUnified.lighten(AppColorsUnified.error, 0.4);
  static Color get cardCompanyPink => AppColorsUnified.lighten(AppColorsUnified.error, 0.1);
  static Color get cardCompanyPinkBg => AppColorsUnified.lighten(AppColorsUnified.error, 0.42);
  
  // Amarillos
  static Color get cardYellow => AppColorsUnified.warning;
  static Color get cardYellowBg => AppColorsUnified.lighten(AppColorsUnified.warning, 0.4);
  
  // Morados trabajadores → Azul
  static Color get cardWorkerPurple => AppColorsUnified.companyBlue;
  static Color get cardWorkerPurpleBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.42);
  
  // Colores empresas
  static Color get cardCompanyOrange => AppColorsUnified.gold;
  static Color get cardCompanyOrangeBg => AppColorsUnified.lighten(AppColorsUnified.gold, 0.4);
  static Color get cardCompanyPurple => AppColorsUnified.companyBlue;
  static Color get cardCompanyPurpleBg => AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.42);

  // ============================================
  // GRADIENTES DE NIVELES
  // ============================================
  
  static LinearGradient get bronzeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.darken(AppColorsUnified.gold, 0.2),
      AppColorsUnified.darken(AppColorsUnified.gold, 0.3),
      AppColorsUnified.darken(AppColorsUnified.gold, 0.4),
    ],
  );
  
  static LinearGradient get silverGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
      AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.3),
      AppColorsUnified.textSecondary,
      AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.1),
    ],
  );
}
