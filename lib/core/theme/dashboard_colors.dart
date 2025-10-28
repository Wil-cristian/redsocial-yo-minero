import 'package:flutter/material.dart';

/// 🏆 PALETA DE COLORES PREMIUM VIBRANTE - YOMINERO
/// Colores saturados, gradientes intensos, look premium moderno
class DashboardColors {
  DashboardColors._();

  // ============================================
  // 🔥 ESQUEMA PRINCIPAL - NARANJA-ORO-MADERA (COFRE DORADO)
  // ============================================
  
  /// Color primario principal - Naranja vibrante
  static const Color primary = Color(0xFFFF8C00);
  static const Color primaryLight = Color(0xFFFFAA33);
  static const Color primaryDark = Color(0xFFE67E00);
  
  /// Acento dorado cálido
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFD4A017);
  
  /// Gradiente principal (uso general)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFAA33), Color(0xFFFF9500), Color(0xFFFFB800), Color(0xFFE67E00)],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Gradiente épico (cofre dorado)
  static const LinearGradient epicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFAA33),
      Color(0xFFFF9500),
      Color(0xFFFFB800),
      Color(0xFFE67E00),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  // ============================================
  // ORO BRILLANTE - Color Principal (LEGACY - usa primary en su lugar)
  // ============================================
  
  static const Color gold = Color(0xFFFF9500);
  static const Color goldLight = Color(0xFFFFAA33);
  static const Color goldDark = Color(0xFFE67E00);
  static const Color goldMetallic = Color(0xFFFFB800);
  static const Color goldAntique = Color(0xFFD4A017);
  static const Color goldShadow = Color(0x50FF9500);

  // ============================================
  // NARANJA VIBRANTE - Acentos Cálidos
  // ============================================
  
  static const Color orange = Color(0xFFFF8C00);
  static const Color orangeBright = Color(0xFFFF9500);
  static const Color orangeDark = Color(0xFFE67E00);
  static const Color orangeGlow = Color(0xFFFFAA33);
  static const Color orangeShadow = Color(0x50FF8C00);
  
  // ============================================
  // MADERA - Tonos Cálidos Naturales
  // ============================================
  
  static const Color wood = Color(0xFF8B4513);
  static const Color woodLight = Color(0xFFA0522D);
  static const Color woodDark = Color(0xFF654321);
  static const Color woodGolden = Color(0xFFB8860B);

  // ============================================
  // GRADIENTES DE ORO INTENSOS (LEGACY - usa primaryGradient/epicGradient)
  // ============================================
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFAA33), Color(0xFFFF9500), Color(0xFFE67E00)],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient goldShine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFAA33),
      Color(0xFFFF9500),
      Color(0xFFFFB800),
      Color(0xFFE67E00),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFAA33), Color(0xFFFF9500), Color(0xFFE67E00)],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient orangeFireGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFAA33),
      Color(0xFFFF9500),
      Color(0xFFFF8C00),
      Color(0xFFE67E00),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  static const LinearGradient woodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA0522D), Color(0xFF8B4513), Color(0xFF654321)],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================
  // 💎 ESMERALDA - Gema Tallada con Capas y Translucidez
  // ============================================
  
  /// Esmeralda oscura profunda (base de la gema)
  static const Color emeraldDeep = Color(0xFF00875A);
  
  /// Esmeralda principal (color medio de la gema)
  static const Color emerald = Color(0xFF00D084);
  
  /// Esmeralda brillante (reflejos de luz)
  static const Color emeraldLight = Color(0xFF4ADE80);
  
  /// Esmeralda muy clara (reflejos intensos)
  static const Color emeraldGlow = Color(0xFF86EFAC);
  
  /// Esmeralda con tinte azul (profundidad)
  static const Color emeraldTeal = Color(0xFF14B8A6);
  
  /// Esmeralda translúcida (para capas)
  static const Color emeraldTranslucent = Color(0x80059669);
  
  /// Gradiente de esmeralda tallada (facetas de luz)
  static const LinearGradient emeraldGemGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF86EFAC), // Reflejo superior brillante
      Color(0xFF4ADE80), // Luz media
      Color(0xFF00D084), // Centro de la gema
      Color(0xFF059669), // Profundidad
      Color(0xFF00875A), // Sombra profunda
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente con efecto de facetas (tallado de gema)
  static const LinearGradient emeraldFacetedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFECFDF5), // Reflejo blanco-verde (faceta superior)
      Color(0xFF86EFAC), // Verde claro brillante
      Color(0xFF4ADE80), // Verde medio
      Color(0xFF10B981), // Verde intenso
      Color(0xFF00D084), // Esmeralda principal
      Color(0xFF059669), // Verde profundo
      Color(0xFF047857), // Verde oscuro
      Color(0xFF065F46), // Sombra interior
    ],
    stops: [0.0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1.0],
  );
  
  /// Gradiente radial de esmeralda (efecto de gema vista desde arriba)
  static const RadialGradient emeraldRadialGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFFFFFF), // Reflejo blanco central
      Color(0xFFECFDF5), // Verde casi blanco
      Color(0xFF86EFAC), // Verde claro
      Color(0xFF10B981), // Verde medio
      Color(0xFF059669), // Verde profundo
      Color(0xFF064E3B), // Verde muy oscuro (borde)
    ],
    stops: [0.0, 0.15, 0.35, 0.6, 0.85, 1.0],
  );

  // ============================================
  // 💎 RUBÍ - Gema de Fuego con Intensidad
  // ============================================
  
  /// Rubí oscuro profundo (sangre de dragón)
  static const Color rubyDeep = Color(0xFF7F1D1D);
  
  /// Rubí principal (rojo intenso)
  static const Color ruby = Color(0xFFDC2626);
  
  /// Rubí brillante (reflejos de fuego)
  static const Color rubyLight = Color(0xFFF87171);
  
  /// Rubí muy claro (destellos)
  static const Color rubyGlow = Color(0xFFFCA5A5);
  
  /// Rubí con tinte rosado (reflejos)
  static const Color rubyPink = Color(0xFFFF6B9D);
  
  /// Rubí translúcido
  static const Color rubyTranslucent = Color(0x80DC2626);
  
  /// Gradiente de rubí tallado
  static const LinearGradient rubyGemGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFCA5A5), // Reflejo rosado brillante
      Color(0xFFF87171), // Luz roja media
      Color(0xFFDC2626), // Centro del rubí
      Color(0xFFB91C1C), // Profundidad roja
      Color(0xFF7F1D1D), // Sombra profunda
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente con efecto de facetas de rubí
  static const LinearGradient rubyFacetedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFEF2F2), // Reflejo casi blanco
      Color(0xFFFCA5A5), // Rosa claro brillante
      Color(0xFFF87171), // Rojo claro
      Color(0xFFEF4444), // Rojo medio
      Color(0xFFDC2626), // Rubí principal
      Color(0xFFB91C1C), // Rojo profundo
      Color(0xFF991B1B), // Rojo oscuro
      Color(0xFF7F1D1D), // Sombra interior
    ],
    stops: [0.0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1.0],
  );
  
  /// Gradiente radial de rubí
  static const RadialGradient rubyRadialGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFFFFFF), // Reflejo blanco central
      Color(0xFFFEF2F2), // Rosa casi blanco
      Color(0xFFFCA5A5), // Rosa claro
      Color(0xFFEF4444), // Rojo medio
      Color(0xFFB91C1C), // Rojo profundo
      Color(0xFF7F1D1D), // Rojo muy oscuro
    ],
    stops: [0.0, 0.15, 0.35, 0.6, 0.85, 1.0],
  );

  // ============================================
  // 💎 ZAFIRO - Gema del Cielo Profundo
  // ============================================
  
  /// Zafiro oscuro profundo (azul noche)
  static const Color sapphireDeep = Color(0xFF1E3A8A);
  
  /// Zafiro principal (azul real)
  static const Color sapphire = Color(0xFF2563EB);
  
  /// Zafiro brillante (reflejos celestes)
  static const Color sapphireLight = Color(0xFF60A5FA);
  
  /// Zafiro muy claro (destellos)
  static const Color sapphireGlow = Color(0xFF93C5FD);
  
  /// Zafiro con tinte cian (profundidad)
  static const Color sapphireCyan = Color(0xFF06B6D4);
  
  /// Zafiro translúcido
  static const Color sapphireTranslucent = Color(0x802563EB);
  
  /// Gradiente de zafiro tallado
  static const LinearGradient sapphireGemGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF93C5FD), // Reflejo azul claro
      Color(0xFF60A5FA), // Luz azul media
      Color(0xFF2563EB), // Centro del zafiro
      Color(0xFF1D4ED8), // Profundidad azul
      Color(0xFF1E3A8A), // Sombra profunda
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente con efecto de facetas de zafiro
  static const LinearGradient sapphireFacetedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEFF6FF), // Reflejo casi blanco
      Color(0xFF93C5FD), // Azul claro brillante
      Color(0xFF60A5FA), // Azul claro
      Color(0xFF3B82F6), // Azul medio
      Color(0xFF2563EB), // Zafiro principal
      Color(0xFF1D4ED8), // Azul profundo
      Color(0xFF1E40AF), // Azul oscuro
      Color(0xFF1E3A8A), // Sombra interior
    ],
    stops: [0.0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1.0],
  );
  
  /// Gradiente radial de zafiro
  static const RadialGradient sapphireRadialGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFFFFFF), // Reflejo blanco central
      Color(0xFFEFF6FF), // Azul casi blanco
      Color(0xFF93C5FD), // Azul claro
      Color(0xFF3B82F6), // Azul medio
      Color(0xFF1D4ED8), // Azul profundo
      Color(0xFF1E3A8A), // Azul muy oscuro
    ],
    stops: [0.0, 0.15, 0.35, 0.6, 0.85, 1.0],
  );

  // ============================================
  // 💎 DIAMANTE - Cristal Puro con Arcoíris
  // ============================================
  
  /// Diamante oscuro (sombra de cristal)
  static const Color diamondDeep = Color(0xFF64748B);
  
  /// Diamante principal (cristal)
  static const Color diamond = Color(0xFFE2E8F0);
  
  /// Diamante brillante (reflejos)
  static const Color diamondLight = Color(0xFFF1F5F9);
  
  /// Diamante muy claro (destellos puros)
  static const Color diamondGlow = Color(0xFFFFFBEB);
  
  /// Diamante iridiscente (arcoíris)
  static const Color diamondIridescent = Color(0xFFDDD6FE);
  
  /// Diamante translúcido
  static const Color diamondTranslucent = Color(0x80F8FAFC);
  
  /// Gradiente de diamante tallado
  static const LinearGradient diamondGemGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF), // Reflejo blanco puro
      Color(0xFFFFFBEB), // Amarillo muy claro
      Color(0xFFF1F5F9), // Gris muy claro
      Color(0xFFE2E8F0), // Gris claro
      Color(0xFFCBD5E1), // Gris medio
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente con efecto de facetas de diamante (con arcoíris)
  static const LinearGradient diamondFacetedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF), // Blanco puro
      Color(0xFFFFFBEB), // Amarillo muy claro (reflejo)
      Color(0xFFDDD6FE), // Violeta claro (refracción)
      Color(0xFFBFDBFE), // Azul muy claro
      Color(0xFFF1F5F9), // Cristal
      Color(0xFFE2E8F0), // Gris claro
      Color(0xFFCBD5E1), // Gris medio
      Color(0xFF94A3B8), // Sombra
    ],
    stops: [0.0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1.0],
  );
  
  /// Gradiente radial de diamante
  static const RadialGradient diamondRadialGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFFFFFF), // Blanco puro central
      Color(0xFFFFFBEB), // Amarillo muy claro
      Color(0xFFF1F5F9), // Cristal claro
      Color(0xFFE2E8F0), // Gris claro
      Color(0xFFCBD5E1), // Gris medio
      Color(0xFF94A3B8), // Gris oscuro
    ],
    stops: [0.0, 0.15, 0.35, 0.6, 0.85, 1.0],
  );

  // ============================================
  // PALETA DE SOPORTE VIBRANTE
  // ============================================
  
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color silver = Color(0xFFE8E8E8);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color minerBlue = Color(0xFF2196F3);
  
  // ============================================
  // COLORES DE ESTADO BRILLANTES
  // ============================================
  
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFF8C00);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // GRADIENTES VIBRANTES PARA CARDS
  // ============================================
  
  static const LinearGradient productGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFB800), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient serviceGradient = LinearGradient(
    colors: [Color(0xFFB794F6), Color(0xFF9F7AEA), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient offerGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient questionGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient newsGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient pollGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient communityGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // SISTEMA DE BLANCOS Y GRISES
  // ============================================
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFFFAF0);
  static const Color snowWhite = Color(0xFFF8F9FA);
  
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ============================================
  // CONSTANTES DE FONDO
  // ============================================
  
  static const Color background = white;
  static const Color cardBackground = white;
  static const Color surfaceBackground = snowWhite;
  static const Color divider = gray200;
  static const Color border = gray300;
  static const Color lightGray = gray100;

  // ============================================
  // COLORES VIBRANTES PARA CARDS
  // ============================================
  
  // Naranjas
  static const Color cardOrange = Color(0xFFFF8C00);
  static const Color cardOrangeBg = Color(0xFFFFF4E6);
  static const Color cardOrange2 = Color(0xFFFF6B00);
  static const Color cardOrange2Bg = Color(0xFFFFF0E0);
  
  // Morados
  static const Color cardPurple = Color(0xFF9F7AEA);
  static const Color cardPurpleBg = Color(0xFFF3EBFF);
  static const Color cardBluePurple = Color(0xFF7C3AED);
  
  // Verdes
  static const Color cardGreen = Color(0xFF10B981);
  static const Color cardGreenBg = Color(0xFFE6F9F3);
  static const Color cardWorkerGreen = Color(0xFF059669);
  static const Color cardDarkGreen = Color(0xFF047857);
  static const Color cardDarkGreenBg = Color(0xFFD1FAE5);
  static const Color cardTeal = Color(0xFF14B8A6);
  static const Color cardTealBg = Color(0xFFE6F9F7);
  
  // Azules
  static const Color cardBlue = Color(0xFF3B82F6);
  static const Color cardBlueBg = Color(0xFFEBF5FF);
  static const Color cardDarkBlue = Color(0xFF2563EB);
  static const Color cardDarkBlueBg = Color(0xFFDBEAFE);
  static const Color cardIndigo = Color(0xFF6366F1);
  static const Color cardIndigoBg = Color(0xFFEEF2FF);
  
  // Rosas
  static const Color cardPink = Color(0xFFEC4899);
  static const Color cardPinkBg = Color(0xFFFCE7F3);
  static const Color cardWorkerPink = Color(0xFFDB2777);
  static const Color cardWorkerPinkBg = Color(0xFFFCE7F3);
  static const Color cardCompanyPink = Color(0xFFF472B6);
  static const Color cardCompanyPinkBg = Color(0xFFFDF2F8);
  
  // Amarillos
  static const Color cardYellow = Color(0xFFFBBF24);
  static const Color cardYellowBg = Color(0xFFFEF9E7);
  
  // Morados para trabajadores
  static const Color cardWorkerPurple = Color(0xFF8B5CF6);
  static const Color cardWorkerPurpleBg = Color(0xFFF5F3FF);
  
  // Colores para empresas
  static const Color cardCompanyOrange = Color(0xFFFB923C);
  static const Color cardCompanyOrangeBg = Color(0xFFFFF7ED);
  static const Color cardCompanyPurple = Color(0xFFA78BFA);
  static const Color cardCompanyPurpleBg = Color(0xFFF5F3FF);

  // ============================================
  // 🏅 SISTEMA DE NIVELES - GRADIENTES ADICIONALES
  // ============================================
  
  /// Gradiente de bronce para badges
  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6A87A), Color(0xFFCD7F32), Color(0xFFB87333)],
  );
  
  /// Gradiente de plata para badges
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8), Color(0xFFC0C0C0), Color(0xFF9E9E9E)],
  );
}

