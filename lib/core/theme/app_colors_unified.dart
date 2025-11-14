import 'package:flutter/material.dart';

/// Sistema Centralizado de Colores - YoMinero v3.0
/// Reorganizado según teoría del color profesional
/// 
/// Filosofía: 90% Blanco/Gris + 8% Negro + 2% Oro Premium
/// 
/// Estructura (orden lógico por jerarquía):
/// 1. PALETA BASE  Primitivos inmutables (10 colores)
/// 2. ESCALAS CROMÁTICAS  Variantes sistemáticas por familia
/// 3. COLORES SEMÁNTICOS  Propósito específico de UI
/// 4. GRADIENTES  Efectos visuales
/// 5. HELPERS  Utilidades de transformación
class AppColorsUnified {
  AppColorsUnified._();

  // 
  // 1. PALETA BASE - Primitivos inmutables
  // ═
  
  // Neutrales fundamentales - Contraste profesional
  static const Color background = Color(0xFFFFFFFF);    // Blanco puro absoluto
  static const Color surface = Color(0xFFFAFAFA);       // Gris ultra claro neutral
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900 - Contraste 16:1
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 - Legible
  
  // Acento premium - Oro elegante balanceado
  static const Color gold = Color(0xFFCA8A04);          // Amber 600 - Sofisticado
  
  // Estados semánticos - Contraste optimizado
  static const Color success = Color(0xFF16A34A);       // Green 600 - Vibrante claro
  static const Color error = Color(0xFFDC2626);         // Red 600 - Alerta visible
  static const Color warning = Color(0xFFEA580C);       // Orange 600 - Destacado
  
  // Color corporativo - Azul confiable
  static const Color companyBlue = Color(0xFF2563EB);   // Blue 600 - Profesional
  
  // DEPRECATED - Mantener solo por compatibilidad legacy
  static const Color orange = Color(0xFF94A3B8);        // Slate 400 - Legacy neutral

  // ═══════════════════════════════════════════════════════════
  // 2. ESCALAS CROMÁTICAS - Variantes por familia de color
  // ═══════════════════════════════════════════════════════════
  
  // ───────────────────────────────────────────
  // 2A. Oro Metálico - Sistema de 5 capas
  // Simula metal pulido con iluminación direccional
  // ───────────────────────────────────────────
  static const Color goldHighlight = Color(0xFFFEF3C7);  // Capa 1: Amber 100 - Brillo sutil
  static const Color goldBright = Color(0xFFFDE047);     // Capa 2: Yellow 300 - Luminoso
  static const Color goldBase = gold;                    // Capa 3: Amber 600 - Equilibrado
  static const Color goldShadow = Color(0xFF92400E);     // Capa 4: Amber 800 - Profundidad
  static const Color goldDeep = Color(0xFF78350F);       // Capa 5: Amber 900 - Contraste
  
  // Variantes de intensidad (nomenclatura semántica)
  static Color get goldLightest => goldHighlight;
  static Color get goldLighter => goldBright;
  static Color get goldLight => lighten(goldBase, 0.12);
  static Color get goldDark => goldShadow;
  static Color get goldDarker => goldDeep;
  static Color get goldDarkest => darken(goldDeep, 0.15);
  
  // Aliases numéricos (compatibilidad con código existente)
  static Color get goldLayer1 => goldHighlight;
  static Color get goldLayer2 => goldBright;
  static Color get goldLayer3 => goldBase;
  static Color get goldLayer4 => goldShadow;
  static Color get goldLayer5 => goldDeep;
  
  // ───────────────────────────────────────────
  // 2B. Escala de Grises
  // Del blanco perla más cálido al gris oscuro
  // ───────────────────────────────────────────
  static Color get grey50 => const Color(0xFFF8FAFC);   // Slate 50 - Ultra sutil
  static Color get grey100 => const Color(0xFFF1F5F9);  // Slate 100 - Muy claro
  static Color get grey200 => const Color(0xFFE2E8F0);  // Slate 200 - Claro
  static Color get grey300 => const Color(0xFFCBD5E1);  // Slate 300 - Medio claro
  static Color get grey400 => const Color(0xFF94A3B8);  // Slate 400 - Medio
  static Color get grey500 => const Color(0xFF64748B);  // Slate 500 - Balanceado
  static Color get grey600 => const Color(0xFF475569);  // Slate 600 - Oscuro
  static Color get grey700 => const Color(0xFF334155);  // Slate 700 - Muy oscuro
  
  // ───────────────────────────────────────────
  // 2C. Variantes de Estados Semánticos
  // ───────────────────────────────────────────
  static Color get successLight => lighten(success, 0.2);
  static Color get successLighter => lighten(success, 0.3);
  static Color get successDark => darken(success, 0.1);
  
  // ───────────────────────────────────────────
  // 2D. Variantes Corporativas
  // ───────────────────────────────────────────
  static Color get companyBlueLight => lighten(companyBlue, 0.2);
  static Color get companyBlueLighter => lighten(companyBlue, 0.3);
  static Color get companyBlueLightest => lighten(companyBlue, 0.4);
  static Color get companyBlueDark => darken(companyBlue, 0.2);
  static Color get companyBlueDarker => darken(companyBlue, 0.3);
  
  // ───────────────────────────────────────────
  // 2E. Metálicos Secundarios
  // ───────────────────────────────────────────
  static Color get silver => grey400;
  static Color get silverLight => grey300;
  static Color get bronzeDark => darken(gold, 0.25);
  
  // ───────────────────────────────────────────
  // 2F. Transparencias de Blanco
  // ───────────────────────────────────────────
  static Color get pureWhite => surface;
  static Color get whiteTransparent05 => fade(surface, 0.05);
  static Color get whiteTransparent10 => fade(surface, 0.1);
  static Color get whiteTransparent15 => fade(surface, 0.15);
  static Color get whiteTransparent20 => fade(surface, 0.2);
  static Color get whiteTransparent30 => fade(surface, 0.3);
  static Color get whiteTransparent70 => fade(surface, 0.7);
  static Color get whiteTransparent80 => fade(surface, 0.8);
  static Color get whiteTransparent90 => fade(surface, 0.9);
  static Color get whiteA05 => whiteTransparent05;
  static Color get whiteA10 => whiteTransparent10;
  
  // ───────────────────────────────────────────
  // 2G. Transparencias de Negro
  // ───────────────────────────────────────────
  static Color get pureBlack => textPrimary;
  static Color get blackTransparent05 => fade(textPrimary, 0.05);
  static Color get blackTransparent08 => fade(textPrimary, 0.08);
  static Color get blackTransparent10 => fade(textPrimary, 0.1);
  static Color get blackTransparent20 => fade(textPrimary, 0.2);
  static Color get blackTransparent30 => fade(textPrimary, 0.3);
  static Color get blackTransparent70 => fade(textPrimary, 0.7);
  static Color get black87 => fade(textPrimary, 0.87);
  static Color get black26 => fade(textPrimary, 0.26);
  static Color get blackA05 => blackTransparent05;
  static Color get blackA10 => blackTransparent10;
  static Color get blackA20 => blackTransparent20;
  static Color get blackA70 => blackTransparent70;

  // ═══════════════════════════════════════════════════════════
  // 3. COLORES SEMÁNTICOS - Propósito específico de UI
  // ═══════════════════════════════════════════════════════════
  
  // ───────────────────────────────────────────
  // 3A. Fondos
  // ───────────────────────────────────────────
  static Color get backgroundDark => grey100;
  static Color get backgroundLight => background;
  static Color get backgroundLighter => grey50;
  
  // ───────────────────────────────────────────
  // 3B. Superficies (Cards, Sheets, Dialogs)
  // ───────────────────────────────────────────
  static Color get surfaceElevated => surface;
  static Color get surfaceTinted => grey50;
  static Color get surfaceLight => surface;
  
  // ───────────────────────────────────────────
  // 3C. Bordes y Separadores
  // ───────────────────────────────────────────
  static Color get divider => fade(textPrimary, 0.08);
  static Color get borderLight => grey200;
  static Color get borderMedium => grey300;
  static Color get borderDark => grey400;
  static Color get border => grey300;
  static Color get borderStrong => grey400;
  static Color get outline => grey300;
  static Color get outlineFocus => gold;
  
  // ───────────────────────────────────────────
  // 3D. Overlays y Sombras
  // ───────────────────────────────────────────
  static Color get overlayLight => blackTransparent10;
  static Color get overlayMedium => blackTransparent30;
  static Color get overlayDark => blackTransparent70;
  static Color get overlay => overlayMedium;
  
  static Color get shadowLight => blackTransparent05;
  static Color get shadowMedium => blackTransparent10;
  static Color get shadowDark => blackTransparent20;
  static Color get shadow => shadowMedium;
  
  // ───────────────────────────────────────────
  // 3E. Texto Contextual
  // ───────────────────────────────────────────
  static Color get textOnOrange => textPrimary;
  static Color get textOnGold => textPrimary;
  static Color get textOnCompanyBlue => surface;
  static Color get textDisabled => fade(textSecondary, 0.4);
  
  // ───────────────────────────────────────────
  // 3F. Iconos
  // ───────────────────────────────────────────
  static Color get iconPrimary => textPrimary;
  static Color get iconSecondary => textSecondary;
  static Color get iconDisabled => fade(textSecondary, 0.3);
  static Color get iconOnColor => surface;
  
  // ───────────────────────────────────────────
  // 3G. Inputs y Fields
  // ───────────────────────────────────────────
  static Color get inputFill => surface;
  static Color get inputBorder => grey300;
  static Color get inputBorderFocus => gold;
  static Color get inputHint => grey500;
  static Color get inputDisabled => grey100;
  
  // ───────────────────────────────────────────
  // 3H. Chips y Tags
  // ───────────────────────────────────────────
  static Color get chipBackground => grey200;
  static Color get chipBackgroundSelected => gold;
  static Color get chipText => textPrimary;
  static Color get chipTextSelected => surface;
  
  // ───────────────────────────────────────────
  // 3I. CTAs y Botones (Call-to-Action)
  // ───────────────────────────────────────────
  static Color get ctaPrimary => gold;
  static Color get ctaPrimaryText => textPrimary;
  static Color get ctaSecondary => grey100;
  static Color get ctaSecondaryText => textPrimary;
  
  // ───────────────────────────────────────────
  // 3J. Módulos de Aplicación (Contextos)
  // ───────────────────────────────────────────
  static Color get homeBackground => background;
  static Color get homeAccent => gold;
  
  static Color get productPrimary => gold;
  static Color get productBackground => background;
  
  static Color get servicePrimary => companyBlue;
  static Color get serviceBackground => background;
  
  static Color get groupPrimary => success;
  static Color get groupBackground => background;
  
  static Color get postPrimary => gold;
  
  static Color get messagePrimary => gold;
  static Color get messageBubbleUser => grey100;
  static Color get messageBubbleOther => grey200;
  
  static Color get companyPrimary => companyBlue;
  static Color get companySecondary => companyBlue;
  
  static Color get employeePrimary => companyBlue;
  
  // ───────────────────────────────────────────
  // 3K. Badges y Métricas
  // ───────────────────────────────────────────
  static Color get profileBadgeGold => gold;
  static Color get profileBadgeSilver => silver;
  static Color get profileBadgeBronze => darken(gold, 0.3);
  
  static Color get badgeGold => gold;
  
  static Color get metricsIncome => success;
  static Color get metricsExpense => error;
  static Color get metricsPlanning => warning;
  static Color get metricsInProgress => companyBlue;
  static Color get metricsCompleted => success;
  
  // ───────────────────────────────────────────
  // 3L. Notificaciones y Estados de UI
  // ───────────────────────────────────────────
  static Color get notificationBadge => error;
  static Color get notificationUnread => gold;
  
  static Color get favoriteActive => gold;
  static Color get favoriteInactive => fade(textSecondary, 0.3);
  
  static Color get radialButton => gold;
  
  static Color get stateSuccess => success;
  static Color get stateError => error;
  static Color get stateWarning => warning;
  
  // ───────────────────────────────────────────
  // 3M. Dark Mode (Placeholder para implementación futura)
  // ───────────────────────────────────────────
  static Color get darkBackground => const Color(0xFF0F172A);  // Slate 900 - Profundo
  static Color get darkSurface => const Color(0xFF1E293B);     // Slate 800 - Elevado
  static Color get darkTextPrimary => const Color(0xFFF1F5F9); // Slate 100 - Claro
  static Color get darkTextSecondary => const Color(0xFF94A3B8); // Slate 400 - Secundario
  
  // ───────────────────────────────────────────
  // 3N. DEPRECATED (Compatibilidad legacy)
  // ───────────────────────────────────────────
  static Color get orangeLight => lighten(orange, 0.15);
  static Color get orangeMedium => darken(orange, 0.05);
  static Color get orangeDark => darken(orange, 0.15);
  static Color get orangeApple => lighten(orange, 0.08);
  
  static Color get wood => grey700;
  static Color get copperDark => grey600;
  static Color get charcoal => textPrimary;

  // ═══════════════════════════════════════════════════════════
  // 4. GRADIENTES - Efectos visuales complejos
  // ═══════════════════════════════════════════════════════════
  
  // ───────────────────────────────────────────
  // 4A. Gradientes de Fondo (Sutiles)
  // ───────────────────────────────────────────
  
  /// Gradiente blanco limpio - Para fondos completos
  static LinearGradient get greySoftGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
  
  /// Gradiente sutil - Para áreas delimitadas
  static LinearGradient get greySectionGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );
  
  static LinearGradient get homeGradient => greySoftGradient;
  
  // ───────────────────────────────────────────
  // 4B. Gradientes de Oro (4 variantes especializadas)
  // ───────────────────────────────────────────
  
  /// Oro metálico completo - 5 capas para CTAs principales
  /// Simula metal pulido con iluminación superior izquierda
  static LinearGradient get goldGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldHighlight, goldBright, goldBase, goldShadow, goldDeep],
    stops: [0.0, 0.25, 0.50, 0.75, 1.0],
  );
  
  /// Oro radial - Para botones circulares o FABs
  static RadialGradient get goldRadialGradient => const RadialGradient(
    center: Alignment(-0.3, -0.3),
    radius: 1.2,
    colors: [goldHighlight, goldBright, goldBase, goldShadow, goldDeep],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// Oro sutil - Para fondos de cards premium (con transparencia)
  static LinearGradient get goldSubtleGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      goldHighlight.withValues(alpha: 0.3),
      goldBase.withValues(alpha: 0.2),
      goldShadow.withValues(alpha: 0.1),
    ],
  );
  
  /// Oro shimmer - Para animaciones hover y loading
  static LinearGradient get goldShimmerGradient => const LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [goldDeep, goldShadow, goldHighlight, goldShadow, goldDeep],
    stops: [0.0, 0.35, 0.5, 0.65, 1.0],
  );
  
  static LinearGradient get productGradient => goldGradient;
  static LinearGradient get radialButtonGradient => goldGradient;
  
  // ───────────────────────────────────────────
  // 4C. Gradientes Corporativos
  // ───────────────────────────────────────────
  static LinearGradient get companyGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lighten(companyBlue, 0.12),
      companyBlue,
      darken(companyBlue, 0.12),
    ],
  );
  
  static LinearGradient get companyHeaderGradient => companyGradient;
  
  // ───────────────────────────────────────────
  // 4D. Gradientes Legacy (compatibilidad)
  // ───────────────────────────────────────────
  static LinearGradient get orangeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lighten(orange, 0.15), orange, darken(orange, 0.15)],
  );
  
  static LinearGradient get epicGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFFFFBF8),
      const Color(0xFFFFF9F5),
      gold.withValues(alpha: 0.3),
      gold,
    ],
    stops: const [0.0, 0.3, 0.6, 1.0],
  );

  // ═══════════════════════════════════════════════════════════
  // 5. HELPERS - Utilidades de transformación de color
  // ═══════════════════════════════════════════════════════════
  
  /// Oscurece un color en el espacio HSL (Hue, Saturation, Lightness)
  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// Aclara un color en el espacio HSL
  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// Agrega transparencia a un color (opacity: 0.0 = transparente, 1.0 = opaco)
  static Color fade(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

// ═══════════════════════════════════════════════════════════
// EXTENSIÓN DE CONTEXT - Acceso rápido desde BuildContext
// ═══════════════════════════════════════════════════════════

extension AppColorsContext on BuildContext {
  // Paleta base
  Color get colorOrange => AppColorsUnified.orange;
  Color get colorGold => AppColorsUnified.gold;
  Color get colorBackground => AppColorsUnified.background;
  Color get colorSurface => AppColorsUnified.surface;
  Color get colorTextPrimary => AppColorsUnified.textPrimary;
  Color get colorTextSecondary => AppColorsUnified.textSecondary;
  Color get colorSuccess => AppColorsUnified.success;
  Color get colorError => AppColorsUnified.error;
  Color get colorWarning => AppColorsUnified.warning;
  Color get colorCompanyBlue => AppColorsUnified.companyBlue;
  
  // Capas de oro metálico
  Color get goldHighlight => AppColorsUnified.goldHighlight;
  Color get goldBright => AppColorsUnified.goldBright;
  Color get goldBase => AppColorsUnified.goldBase;
  Color get goldShadow => AppColorsUnified.goldShadow;
  Color get goldDeep => AppColorsUnified.goldDeep;
  
  // Gradientes principales
  LinearGradient get gradientGreySoft => AppColorsUnified.greySoftGradient;
  LinearGradient get gradientGreySection => AppColorsUnified.greySectionGradient;
  LinearGradient get gradientGold => AppColorsUnified.goldGradient;
  RadialGradient get gradientGoldRadial => AppColorsUnified.goldRadialGradient;
  LinearGradient get gradientGoldSubtle => AppColorsUnified.goldSubtleGradient;
  LinearGradient get gradientGoldShimmer => AppColorsUnified.goldShimmerGradient;
  LinearGradient get gradientOrange => AppColorsUnified.orangeGradient;
  LinearGradient get gradientCompany => AppColorsUnified.companyGradient;
  LinearGradient get gradientHome => AppColorsUnified.homeGradient;
  
  // CTAs
  Color get colorCtaPrimary => AppColorsUnified.ctaPrimary;
  Color get colorCtaPrimaryText => AppColorsUnified.ctaPrimaryText;
  Color get colorCtaSecondary => AppColorsUnified.ctaSecondary;
  Color get colorCtaSecondaryText => AppColorsUnified.ctaSecondaryText;
  
  // Módulos
  Color get colorProduct => AppColorsUnified.productPrimary;
  Color get colorService => AppColorsUnified.servicePrimary;
  Color get colorGroup => AppColorsUnified.groupPrimary;
  Color get colorMessage => AppColorsUnified.messagePrimary;
  Color get colorCompany => AppColorsUnified.companyPrimary;
}
