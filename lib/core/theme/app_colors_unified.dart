import 'package:flutter/material.dart';

/// 🎨 SISTEMA CENTRALIZADO DE COLORES - YoMinero
/// 
/// ⚡ SOLO 10 COLORES BASE - Sistema Simplificado
/// 
/// Si cambias UN color aquí → se actualiza en TODA la app automáticamente
/// 
/// Los 10 colores centralizados:
/// 1. orange - Acción, botones CTA, menú radial
/// 2. gold - Identidad, badges premium
/// 3. background - Fondo principal
/// 4. surface - Cards, superficies
/// 5. textPrimary - Texto principal
/// 6. textSecondary - Texto secundario
/// 7. success - Verde, éxitos
/// 8. error - Rojo, errores
/// 9. warning - Amarillo, advertencias
/// 10. companyBlue - Azul empresa
/// 
/// ⚠️ NO crear colores hardcoded fuera de este archivo
/// ⚠️ SIEMPRE referencia AppColorsUnified.xxx
/// 
class AppColorsUnified {
  AppColorsUnified._();

  // ============================================
  // 🎨 LOS 10 COLORES BASE (ÚNICOS)
  // ============================================
  
  /// 1️⃣ NARANJA - Acción, energía, CTAs
  static const Color orange = Color(0xFF333333);  // Gris oscuro
  
  /// 2️⃣ ORO - Identidad de marca, premium
  static const Color gold = Color(0xFFCCCCCC);  // Gris claro
  
  /// 3️⃣ BACKGROUND - Fondo principal (60% de la app)
  static const Color background = Color(0xFFF5F5F5);  // Casi blanco
  
  /// 4️⃣ SURFACE - Cards, superficies elevadas
  static const Color surface = Color(0xFFFFFFFF);  // Blanco
  
  /// 5️⃣ TEXTO PRINCIPAL - Negro/gris oscuro
  static const Color textPrimary = Color(0xFF000000);  // Negro
  
  /// 6️⃣ TEXTO SECUNDARIO - Gris medio
  static const Color textSecondary = Color(0xFF666666);  // Gris medio
  
  /// 7️⃣ SUCCESS - Verde éxito
  static const Color success = Color(0xFF888888);  // Gris
  
  /// 8️⃣ ERROR - Rojo error
  static const Color error = Color(0xFF444444);  // Gris oscuro
  
  /// 9️⃣ WARNING - Amarillo advertencia
  static const Color warning = Color(0xFF999999);  // Gris claro
  
  /// 🔟 COMPANY BLUE - Azul empresa
  static const Color companyBlue = Color(0xFF777777);  // Gris

  // ============================================
  // 🎨 GRADIENTES (usando los 10 colores base)
  // ============================================
  
  /// Gradiente NARANJA (3 capas usando solo orange)
  static LinearGradient get orangeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lighten(orange, 0.15),  // Más claro
      orange,                   // Base
      darken(orange, 0.15),   // Más oscuro
    ],
  );
  
  /// Gradiente ORO (3 capas usando solo gold)
  static LinearGradient get goldGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lighten(gold, 0.12),    // Más claro
      gold,                     // Base
      darken(gold, 0.12),     // Más oscuro
    ],
  );
  
  /// Gradiente AZUL EMPRESA (3 capas usando solo companyBlue)
  static LinearGradient get companyGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lighten(companyBlue, 0.12),  // Más claro
      companyBlue,                   // Base
      darken(companyBlue, 0.12),   // Más oscuro
    ],
  );

  // ============================================
  // 🎨 COLORES DERIVADOS (basados en los 10)
  // ============================================
  
  // Variaciones de FONDO (usando background)
  static Color get backgroundDark => darken(background, 0.05);
  static Color get backgroundLight => lighten(background, 0.03);
  
  // Variaciones de SUPERFICIE (usando surface)
  static Color get surfaceElevated => surface;
  static Color get divider => fade(textSecondary, 0.2);
  
  // Texto sobre colores (derivados de los 10 base)
  static Color get textOnOrange => surface;  // Blanco - usa surface
  static Color get textOnGold => textPrimary;  // Negro - usa textPrimary
  static Color get textOnCompanyBlue => surface;  // Blanco - usa surface
  static Color get textDisabled => fade(textSecondary, 0.5);
  
  // ============================================
  // 🔄 HELPERS DE COMPATIBILIDAD (para código legacy)
  // ============================================
  
  // Variaciones de NARANJA (basadas en orange - uno de los 10 base)
  static Color get orangeLight => lighten(orange, 0.15);
  static Color get orangeMedium => darken(orange, 0.05);
  static Color get orangeDark => darken(orange, 0.15);
  static Color get orangeApple => lighten(orange, 0.08);  // Naranja más claro derivado de orange
  
  // Variaciones de ORO (basadas en gold)
  static Color get goldLight => lighten(gold, 0.12);
  static Color get goldDark => darken(gold, 0.12);
  
  // Variaciones de PLATA (derivadas de textSecondary - uno de los 10 base)
  static Color get silver => lighten(textSecondary, 0.3);  // Plata derivada de textSecondary
  static Color get silverLight => lighten(textSecondary, 0.4);  // Plata clara

  // ============================================
  // 🎨 ALIASES SEMÁNTICOS (usando los 10)
  // ============================================
  
  // HOME
  static Color get homeBackground => background;
  static Color get homeAccent => orange;
  
  // PRODUCTOS
  static Color get productPrimary => gold;
  static Color get productBackground => background;
  static LinearGradient get productGradient => goldGradient;
  
  // SERVICIOS
  static Color get servicePrimary => companyBlue;  // Usa azul de los 10 base
  static Color get serviceBackground => background;
  
  // GRUPOS
  static Color get groupPrimary => success;
  static Color get groupBackground => background;
  
  // POSTS
  static Color get postPrimary => orange;
  
  // MENSAJERÍA
  static Color get messagePrimary => orange;  // Usa naranja de los 10 base
  static Color get messageBubbleUser => orange;
  static Color get messageBubbleOther => fade(textSecondary, 0.1);
  
  // PERFIL
  static Color get profileBadgeGold => gold;
  static Color get profileBadgeSilver => silver;  // Usa helper basado en base
  static Color get profileBadgeBronze => darken(gold, 0.3);  // Derivado de gold
  
  // EMPRESA
  static Color get companyPrimary => companyBlue;
  static Color get companySecondary => companyBlue;
  static LinearGradient get companyHeaderGradient => companyGradient;
  
  // EMPLEADOS
  static Color get employeePrimary => companyBlue;
  
  // MÉTRICAS
  static Color get metricsIncome => success;
  static Color get metricsExpense => error;
  static Color get metricsPlanning => warning;
  static Color get metricsInProgress => companyBlue;
  static Color get metricsCompleted => success;
  
  // NOTIFICACIONES
  static Color get notificationBadge => error;
  static Color get notificationUnread => orange;
  
  // FAVORITOS
  static Color get favoriteActive => gold;
  static Color get favoriteInactive => fade(textSecondary, 0.3);
  
  // MENÚ RADIAL
  static Color get radialButton => orange;
  static LinearGradient get radialButtonGradient => orangeGradient;

  // DARK MODE (derivados de los 10 base - para implementación futura)
  static Color get darkBackground => darken(background, 0.8);  // Fondo muy oscuro
  static Color get darkSurface => darken(surface, 0.7);  // Surface oscuro
  static Color get darkTextPrimary => lighten(textPrimary, 0.7);  // Texto claro
  static Color get darkTextSecondary => lighten(textSecondary, 0.5);  // Texto secundario claro

  // ============================================
  // 🛠️ FUNCIONES AUXILIARES (PÚBLICAS)
  // ============================================
  
  /// Oscurece un color (público para uso en archivos legacy)
  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// Aclara un color (público para uso en archivos legacy)
  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// Agrega transparencia (público para uso en archivos legacy)
  static Color fade(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }
}

// ============================================
// 🎨 EXTENSIÓN DE CONTEXT (acceso rápido)
// ============================================

extension AppColorsContext on BuildContext {
  // Los 10 colores base
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
  
  // Gradientes
  LinearGradient get gradientOrange => AppColorsUnified.orangeGradient;
  LinearGradient get gradientGold => AppColorsUnified.goldGradient;
  LinearGradient get gradientCompany => AppColorsUnified.companyGradient;
  
  // Módulos
  Color get colorProduct => AppColorsUnified.productPrimary;
  Color get colorService => AppColorsUnified.servicePrimary;
  Color get colorGroup => AppColorsUnified.groupPrimary;
  Color get colorMessage => AppColorsUnified.messagePrimary;
  Color get colorCompany => AppColorsUnified.companyPrimary;
}
