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
  static const Color orange = Color(0xFFFF6B35);
  
  /// 2️⃣ ORO - Identidad de marca, premium
  static const Color gold = Color(0xFFFFD700);
  
  /// 3️⃣ BACKGROUND - Fondo principal (60% de la app)
  static const Color background = Color(0xFFF8F5EF);
  
  /// 4️⃣ SURFACE - Cards, superficies elevadas
  static const Color surface = Color(0xFFFFFFFF);
  
  /// 5️⃣ TEXTO PRINCIPAL - Negro/gris oscuro
  static const Color textPrimary = Color(0xFF1F2937);
  
  /// 6️⃣ TEXTO SECUNDARIO - Gris medio
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// 7️⃣ SUCCESS - Verde éxito
  static const Color success = Color(0xFF10B981);
  
  /// 8️⃣ ERROR - Rojo error
  static const Color error = Color(0xFFEF4444);
  
  /// 9️⃣ WARNING - Amarillo advertencia
  static const Color warning = Color(0xFFF59E0B);
  
  /// 🔟 COMPANY BLUE - Azul empresa
  static const Color companyBlue = Color(0xFF45B7D1);

  // ============================================
  // 🎨 GRADIENTES (usando los 10 colores base)
  // ============================================
  
  /// Gradiente NARANJA (3 capas usando solo orange)
  static LinearGradient get orangeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      orange.withOpacity(0.8),  // Más claro
      orange,                    // Base
      orange.withOpacity(1.2),  // Más oscuro
    ],
  );
  
  /// Gradiente ORO (3 capas usando solo gold)
  static LinearGradient get goldGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gold.withOpacity(0.7),    // Más claro
      gold,                      // Base
      gold.withOpacity(1.3),    // Más oscuro
    ],
  );
  
  /// Gradiente AZUL EMPRESA (3 capas usando solo companyBlue)
  static LinearGradient get companyGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      companyBlue.withOpacity(0.7),  // Más claro
      companyBlue,                    // Base
      companyBlue.withOpacity(1.2),  // Más oscuro
    ],
  );

  // ============================================
  // 🎨 COLORES DERIVADOS (basados en los 10)
  // ============================================
  
  // Variaciones de FONDO (usando background)
  static Color get backgroundDark => _darken(background, 0.05);
  static Color get backgroundLight => _lighten(background, 0.03);
  
  // Variaciones de SUPERFICIE (usando surface)
  static Color get surfaceElevated => surface;
  static Color get divider => textSecondary.withOpacity(0.2);
  
  // Texto sobre colores
  static const Color textOnOrange = Color(0xFFFFFFFF);
  static const Color textOnGold = Color(0xFF1F2937);
  static const Color textOnCompanyBlue = Color(0xFFFFFFFF);
  static Color get textDisabled => textSecondary.withOpacity(0.5);

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
  static Color get servicePrimary => Color(0xFF9F7AEA); // Púrpura
  static Color get serviceBackground => background;
  
  // GRUPOS
  static Color get groupPrimary => success;
  static Color get groupBackground => background;
  
  // POSTS
  static Color get postPrimary => orange;
  
  // MENSAJERÍA
  static Color get messagePrimary => Color(0xFFEC4899); // Rosa
  static Color get messageBubbleUser => orange;
  static Color get messageBubbleOther => textSecondary.withOpacity(0.1);
  
  // PERFIL
  static Color get profileBadgeGold => gold;
  static Color get profileBadgeSilver => Color(0xFFC0C0C0);
  static Color get profileBadgeBronze => Color(0xFFCD7F32);
  
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
  static Color get favoriteInactive => textSecondary.withOpacity(0.3);
  
  // MENÚ RADIAL
  static Color get radialButton => orange;
  static LinearGradient get radialButtonGradient => orangeGradient;

  // DARK MODE (preparado)
  static const Color darkBackground = Color(0xFF1F2937);
  static const Color darkSurface = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);

  // ============================================
  // 🛠️ FUNCIONES AUXILIARES
  // ============================================
  
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
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
