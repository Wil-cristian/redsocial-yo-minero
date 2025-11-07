import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// 🎨 SISTEMA UNIFICADO DE COLORES - YoMinero
/// 
/// ESTE ES EL ÚNICO ARCHIVO DE COLORES DE TODA LA APP
/// Todos los colores están organizados por módulos y contextos
/// 
/// ⚠️ NO crear colores hardcoded fuera de este archivo
/// ⚠️ NO usar Color(0xFF...) directamente en páginas/widgets
/// ⚠️ SIEMPRE referencia AppColorsUnified.xxx
/// 
/// Fecha creación: 2025-01-07
/// 
class AppColorsUnified {
  AppColorsUnified._();

  // ============================================
  // 🧡 NARANJA CON CAPAS - COLOR PRIMARIO
  // ============================================
  
  /// NARANJA con gradiente multicapa (no plano)
  /// Perfecto para industria minera, cálido y vibrante
  
  // Naranja base (usarlo para colores planos)
  static const Color orange = AppColorsUnified.orange;  // Naranja vibrante principal
  static const Color orangeLight = AppColorsUnified.orangeLight;  // Naranja claro brillante
  static const Color orangeDark = AppColorsUnified.orangeDark;  // Naranja oscuro profundo
  static const Color orangeMedium = AppColorsUnified.orangeMedium;  // Naranja medio
  static const Color orangeApple = AppColorsUnified.orangeApple;  // Naranja Apple style
  static const Color orangeBright = AppColorsUnified.orangeBright;  // Naranja muy brillante
  
  /// Gradiente NARANJA Principal (5 capas) - Efecto 3D
  /// Usar para botones principales, headers, FAB
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.orangeLight,  // Highlight superior brillante
      AppColorsUnified.orangeApple,  // Capa clara
      AppColorsUnified.orange,  // Naranja principal (centro)
      AppColorsUnified.orangeMedium,  // Capa media-oscura
      AppColorsUnified.orangeDark,  // Sombra profunda
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente NARANJA Vertical (para headers)
  static const LinearGradient orangeVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColorsUnified.orangeLight,  // Top highlight
      AppColorsUnified.orangeApple,
      AppColorsUnified.orange,  // Centro
      AppColorsUnified.orangeMedium,
      AppColorsUnified.orangeDark,  // Bottom shadow
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente NARANJA Fuego (7 capas) - Ultra dramático
  /// Usar para elementos hero, splash screens
  static const LinearGradient orangeFire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFAF0),  // Blanco cálido (reflejo)
      AppColorsUnified.orangeLight,  // Amarillo-naranja brillante
      AppColorsUnified.orangeBright,  // Naranja muy claro
      AppColorsUnified.orangeApple,  // Naranja medio-claro
      AppColorsUnified.orange,  // Naranja principal
      AppColorsUnified.orangeMedium,  // Naranja medio-oscuro
      AppColorsUnified.orangeDark,  // Naranja profundo
    ],
    stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.8, 1.0],
  );
  
  /// Gradiente NARANJA Radial (para FAB circulares)
  static const RadialGradient orangeRadial = RadialGradient(
    center: Alignment(0.3, -0.5),  // Offset para simular luz
    radius: 1.5,
    colors: [
      Color(0xFFFFFAF0),  // Centro brillante
      AppColorsUnified.orangeLight,
      AppColorsUnified.orange,  // Naranja principal
      AppColorsUnified.orangeDark,  // Borde oscuro
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Sombra de naranja (para BoxShadow)
  static const Color orangeShadow = Color(0x50FF6B35);  // 50% opacidad
  static const Color orangeGlow = Color(0x40FFB84D);  // Glow suave

  // ============================================
  // 🥇 ORO Y PLATA - Colores Secundarios Premium
  // ============================================
  
  /// ORO - Para elementos premium, badges, achievements
  static const Color gold = AppColorsUnified.gold;  // Oro clásico
  static const Color goldLight = AppColorsUnified.goldLight;  // Oro claro brillante
  static const Color goldDark = AppColorsUnified.goldDark;  // Oro oscuro
  static const Color goldPure = AppColorsUnified.goldPure;  // Oro puro 24K
  
  /// PLATA - Para elementos secundarios, badges plateados
  static const Color silver = AppColorsUnified.silver;  // Plata base
  static const Color silverLight = AppColorsUnified.silverLight;  // Plata clara
  static const Color silverDark = AppColorsUnified.silverDark;  // Plata oscura
  
  /// Gradiente ORO (5 capas)
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFAF0),  // Highlight blanco dorado
      AppColorsUnified.goldLight,  // Oro brillante
      AppColorsUnified.gold,  // Oro puro
      AppColorsUnified.goldDark,  // Oro medio
      Color(0xFFAA8C3A),  // Oro oscuro
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente PLATA (5 capas)
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.white,  // Highlight blanco
      Color(0xFFF5F5F5),
      AppColorsUnified.silverLight,  // Plata brillante
      AppColorsUnified.silver,  // Plata media
      Color(0xFF9E9E9E),  // Plata oscura
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// Gradiente ORO + PLATA épico (premium)
  static const LinearGradient goldSilverEpic = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColorsUnified.goldLight,  // Oro claro
      AppColorsUnified.gold,  // Oro base
      AppColorsUnified.silverLight,  // Plata clara
      AppColorsUnified.silver,  // Plata base
      AppColorsUnified.gold,  // Oro base final
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  // ============================================
  // 🎨 FONDOS Y SUPERFICIES
  // ============================================
  
  static const Color background = AppColorsUnified.background;  // Fondo principal cálido
  static const Color backgroundAlt = AppColorsUnified.backgroundAlt;  // Fondo alternativo
  static const Color surface = AppColorsUnified.white;  // Superficie blanca
  static const Color surfaceAlt = AppColorsUnified.surfaceAlt;  // Superficie cálida
  static const Color cardBackground = AppColorsUnified.white;  // Fondo de cards
  static const Color divider = AppColorsUnified.divider;  // Divisores
  static const Color outline = AppColorsUnified.outline;  // Bordes

  // ============================================
  // ✍️ TEXTO
  // ============================================
  
  static const Color textPrimary = AppColorsUnified.textPrimary;  // Texto principal
  static const Color textSecondary = AppColorsUnified.textSecondary;  // Texto secundario
  static const Color textDisabled = AppColorsUnified.textDisabled;  // Texto deshabilitado
  static const Color textOnOrange = AppColorsUnified.white;  // Texto sobre naranja
  static const Color textOnGold = AppColorsUnified.black;  // Texto sobre oro

  // ============================================
  // ✅ ESTADOS (Success, Error, Warning, Info)
  // ============================================
  
  /// Verde ÉXITO
  static const Color success = AppColorsUnified.success;  // Verde esmeralda
  static const Color successLight = AppColorsUnified.successLight;
  static const Color successDark = AppColorsUnified.successDark;
  static const Color successContainer = AppColorsUnified.successContainer;  // Fondo verde claro
  
  /// Rojo ERROR
  static const Color error = AppColorsUnified.error;  // Rojo rubí
  static const Color errorLight = AppColorsUnified.errorLight;
  static const Color errorDark = AppColorsUnified.errorDark;
  static const Color errorContainer = AppColorsUnified.errorContainer;  // Fondo rojo claro
  
  /// Amarillo WARNING
  static const Color warning = AppColorsUnified.warning;  // Amarillo ámbar
  static const Color warningLight = AppColorsUnified.warningLight;
  static const Color warningDark = AppColorsUnified.warningDark;
  static const Color warningContainer = AppColorsUnified.warningContainer;  // Fondo amarillo claro
  
  /// Azul INFO
  static const Color info = AppColorsUnified.companyPrimary;  // Azul zafiro
  static const Color infoLight = AppColorsUnified.infoLight;
  static const Color infoDark = AppColorsUnified.sapphire;
  static const Color infoContainer = AppColorsUnified.infoContainer;  // Fondo azul claro

  // ============================================
  // 💎 GEMAS PRECIOSAS (para badges premium)
  // ============================================
  
  /// ESMERALDA (Verde premium)
  static const Color emerald = AppColorsUnified.emerald;
  static const Color emeraldLight = AppColorsUnified.emeraldLight;
  static const Color emeraldDark = AppColorsUnified.emeraldDark;
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6EE7B7), AppColorsUnified.successLight, AppColorsUnified.success, AppColorsUnified.successDark, Color(0xFF047857)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// RUBÍ (Rojo premium)
  static const Color ruby = AppColorsUnified.error;
  static const Color rubyLight = AppColorsUnified.errorLight;
  static const Color rubyDark = AppColorsUnified.rubyDark;
  static const LinearGradient rubyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDA4AF), AppColorsUnified.errorLight, AppColorsUnified.ruby, AppColorsUnified.error, AppColorsUnified.errorDark],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// ZAFIRO (Azul premium)
  static const Color sapphire = AppColorsUnified.sapphire;
  static const Color sapphireLight = AppColorsUnified.infoLight;
  static const Color sapphireDark = AppColorsUnified.sapphireDark;
  static const LinearGradient sapphireGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsUnified.sapphireLight, AppColorsUnified.infoLight, AppColorsUnified.companyPrimary, AppColorsUnified.sapphire, Color(0xFF1E40AF)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// AMATISTA (Púrpura premium)
  static const Color amethyst = AppColorsUnified.amethyst;
  static const Color amethystLight = AppColorsUnified.amethystLight;
  static const Color amethystDark = Color(0xFF6B21A8);
  static const LinearGradient amethystGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE9D5FF), AppColorsUnified.amethystLight, AppColorsUnified.amethyst, AppColorsUnified.amethystDark, Color(0xFF6B21A8)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// DIAMANTE (Cristal premium)
  static const Color diamond = Color(0xFFE2E8F0);
  static const Color diamondLight = Color(0xFFF1F5F9);
  static const Color diamondDark = Color(0xFF64748B);

  // ============================================
  // 🏠 MÓDULO: HOME PAGE
  // ============================================
  
  /// Colores específicos del HomePage
  static const Color homeWelcomeGradientStart = orange;  // Gradiente bienvenida
  static const Color homeWelcomeGradientEnd = orangeDark;
  static const Color homeCardBackground = surface;
  static const Color homeIconTint = orange;

  // ============================================
  // 🛒 MÓDULO: PRODUCTOS (Products)
  // ============================================
  
  /// Colores para cards de productos
  static const Color productPrimary = orange;
  static const Color productBackground = AppColorsUnified.productBackground;  // Fondo cálido oro
  static const LinearGradient productGradient = goldGradient;  // Usar gradiente oro
  static const Color productBadge = gold;
  static const Color productPrice = orange;
  static const Color productDiscount = error;

  // ============================================
  // 🔧 MÓDULO: SERVICIOS (Services)
  // ============================================
  
  /// Colores para cards de servicios
  static const Color servicePrimary = AppColorsUnified.servicePrimary;  // Púrpura
  static const Color serviceBackground = AppColorsUnified.serviceBackground;  // Fondo púrpura claro
  static const LinearGradient serviceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsUnified.servicePrimary, AppColorsUnified.servicePrimary, AppColorsUnified.amethystDark],
  );
  static const Color serviceBadge = AppColorsUnified.serviceBadge;
  static const Color servicePrice = servicePrimary;

  // ============================================
  // 👥 MÓDULO: GRUPOS (Groups)
  // ============================================
  
  /// Colores para grupos
  static const Color groupPrimary = AppColorsUnified.success;  // Verde
  static const Color groupBackground = AppColorsUnified.groupBackground;  // Fondo verde claro
  static const LinearGradient groupGradient = emeraldGradient;
  static const Color groupMemberCount = textSecondary;
  static const Color groupBadge = emerald;

  // ============================================
  // 📝 MÓDULO: POSTS / COMUNIDAD
  // ============================================
  
  /// Colores para posts y feed comunitario
  static const Color postPrimary = orange;
  static const Color postBackground = surface;
  static const Color postLikeActive = error;
  static const Color postLikeInactive = AppColorsUnified.favoriteInactive;
  static const Color postCommentIcon = AppColorsUnified.companyPrimary;
  static const Color postShareIcon = success;
  
  /// Gradientes por tipo de post
  static const LinearGradient postProductGradient = orangeGradient;
  static const LinearGradient postServiceGradient = serviceGradient;
  static const LinearGradient postOfferGradient = emeraldGradient;
  static const LinearGradient postQuestionGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFF97316), Color(0xFFEA580C)],
  );
  static const LinearGradient postNewsGradient = sapphireGradient;
  static const LinearGradient postPollGradient = LinearGradient(
    colors: [AppColorsUnified.successLight, AppColorsUnified.success, AppColorsUnified.successDark],
  );

  // ============================================
  // 💬 MÓDULO: MENSAJERÍA (Messaging)
  // ============================================
  
  /// Colores para chat y mensajería
  static const Color messagePrimary = AppColorsUnified.messagePrimary;  // Rosa
  static const Color messageBackground = AppColorsUnified.messageBackground;  // Fondo rosa claro
  static const Color messageBubbleUser = orange;  // Burbuja del usuario
  static const Color messageBubbleOther = Color(0xFFF3F4F6);  // Burbuja del otro
  static const Color messageTextUser = Colors.white;
  static const Color messageTextOther = textPrimary;
  static const Color messageTimestamp = textSecondary;
  static const Color messageUnreadBadge = error;
  static const Color messageOnlineIndicator = success;

  // ============================================
  // 👤 MÓDULO: PERFIL (Profile)
  // ============================================
  
  /// Colores para perfil de usuario
  static const Color profileHeaderGradientStart = orange;
  static const Color profileHeaderGradientEnd = gold;
  static const Color profileBadgeGold = gold;
  static const Color profileBadgeSilver = silver;
  static const Color profileBadgeBronze = AppColorsUnified.profileBadgeBronze;
  static const Color profileStatsBackground = surfaceAlt;
  static const Color profileStatsIcon = orange;

  // ============================================
  // 🏢 MÓDULO: EMPRESA (Company)
  // ============================================
  
  /// Colores para sección de empresa
  static const Color companyPrimary = AppColorsUnified.companyPrimary;  // Azul corporativo
  static const Color companySecondary = AppColorsUnified.companySecondary;  // Azul turquesa
  static const Color companyBackground = AppColorsUnified.companyBackground;  // Fondo azul claro
  static const Color companyAccent = gold;  // Oro para elementos premium
  
  /// Cards de empresa
  static const Color companyCardOrange = orange;
  static const Color companyCardPurple = Color(0xFFA78BFA);
  static const Color companyCardPink = AppColorsUnified.companyCardPink;
  static const Color companyCardBlue = companyPrimary;
  
  /// Gradientes de empresa
  static const LinearGradient companyGradient = LinearGradient(
    colors: [AppColorsUnified.infoLight, AppColorsUnified.companyPrimary, AppColorsUnified.sapphire],
  );
  static const LinearGradient companyPremiumGradient = goldGradient;

  // ============================================
  // 👷 MÓDULO: EMPLEADOS (Employees)
  // ============================================
  
  /// Colores para gestión de empleados
  static const Color employeePrimary = companySecondary;  // Azul turquesa
  static const Color employeeBackground = Color(0xFFE0F2F7);
  static const Color employeeActive = success;
  static const Color employeeInactive = AppColorsUnified.employeeInactive;
  static const Color employeeBadgeGreen = AppColorsUnified.successDark;
  static const Color employeeBadgePurple = AppColorsUnified.serviceBadge;
  static const Color employeeBadgePink = AppColorsUnified.employeeBadgePink;

  // ============================================
  // 📊 MÓDULO: MÉTRICAS (Metrics/Dashboard)
  // ============================================
  
  /// Colores para dashboard de métricas
  static const Color metricsIncome = success;  // Verde para ingresos
  static const Color metricsExpense = error;  // Rojo para gastos
  static const Color metricsProfit = emerald;  // Esmeralda para ganancia
  static const Color metricsProjectPlanning = info;  // Azul para planificación
  static const Color metricsProjectInProgress = warning;  // Amarillo para en progreso
  static const Color metricsProjectCompleted = success;  // Verde para completado
  
  /// Cards de métricas
  static const Color metricsCardBackground = surface;
  static const Color metricsCardBorder = outline;
  static const LinearGradient metricsIncomeGradient = emeraldGradient;
  static const LinearGradient metricsExpenseGradient = rubyGradient;

  // ============================================
  // 🔔 MÓDULO: NOTIFICACIONES
  // ============================================
  
  /// Colores para notificaciones
  static const Color notificationUnread = orange;
  static const Color notificationRead = textDisabled;
  static const Color notificationBackground = surfaceAlt;
  static const Color notificationBadge = error;
  static const Color notificationSuccess = success;
  static const Color notificationInfo = info;
  static const Color notificationWarning = warning;

  // ============================================
  // ⭐ MÓDULO: FAVORITOS
  // ============================================
  
  /// Colores para sistema de favoritos
  static const Color favoriteActive = AppColorsUnified.favoriteActive;  // Dorado brillante
  static const Color favoriteInactive = AppColorsUnified.favoriteInactive;  // Gris claro
  static const Color favoriteBackground = Color(0xFFFFF9E6);  // Fondo amarillo muy claro

  // ============================================
  // 🎯 MENÚ RADIAL (Radial Menu)
  // ============================================
  
  /// Colores específicos del menú radial flotante
  static const Color radialButtonGradientStart = AppColorsUnified.orange;  // Naranja oscuro
  static const Color radialButtonGradientMid = AppColorsUnified.orangeMedium;  // Naranja medio
  static const Color radialButtonGradientEnd = AppColorsUnified.orangeLight;  // Naranja dorado
  
  /// Gradiente del botón flotante (3 capas)
  static const LinearGradient radialButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorsUnified.orange,
      AppColorsUnified.orangeMedium,
      AppColorsUnified.orangeLight,
    ],
  );
  
  /// Overlay del menú
  static const Color radialOverlay = Color(0xB3000000);  // Negro 70% opacidad
  
  /// Colores de las opciones del menú
  static const Color radialOptionProducts = orange;
  static const Color radialOptionServices = servicePrimary;
  static const Color radialOptionCommunity = orange;
  static const Color radialOptionGroups = groupPrimary;
  static const Color radialOptionMessages = messagePrimary;
  static const Color radialOptionProfile = gold;
  static const Color radialOptionEmployees = companyPrimary;
  static const Color radialOptionMetrics = success;

  // ============================================
  // 🎨 COLORES POR TIPO DE USUARIO
  // ============================================
  
  /// INDIVIDUAL (Usuario individual)
  static const Color userIndividualPrimary = orange;
  static const Color userIndividualAccent = gold;
  
  /// WORKER (Trabajador)
  static const Color userWorkerPrimary = AppColorsUnified.successDark;  // Verde oscuro
  static const Color userWorkerAccent = emerald;
  static const Color userWorkerBadge = AppColorsUnified.serviceBadge;  // Púrpura
  
  /// COMPANY (Empresa)
  static const Color userCompanyPrimary = companyPrimary;
  static const Color userCompanyAccent = gold;
  static const Color userCompanyBadge = gold;

  // ============================================
  // 🌓 DARK MODE (futuro)
  // ============================================
  
  /// Colores para modo oscuro (preparación futura)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = AppColorsUnified.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // ============================================
  // 🎨 UTILIDADES
  // ============================================
  
  /// Colores utilitarios
  static const Color transparent = Color(0x00000000);
  static const Color white = AppColorsUnified.white;
  static const Color black = AppColorsUnified.black;
  
  /// Overlays con opacidad
  static Color overlay(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Determinar si usar texto blanco o negro sobre un color
  static Color textOnColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.54 ? black : white;
  }
}

/// 🎨 EXTENSIÓN DE CONTEXT PARA ACCESO RÁPIDO
/// 
/// Uso: context.colorOrange, context.colorGold, etc.
extension AppColorsContext on BuildContext {
  // Colores primarios
  Color get colorOrange => AppColorsUnified.orange;
  Color get colorGold => AppColorsUnified.gold;
  Color get colorSilver => AppColorsUnified.silver;
  
  // Gradientes principales
  LinearGradient get gradientOrange => AppColorsUnified.orangeGradient;
  LinearGradient get gradientGold => AppColorsUnified.goldGradient;
  LinearGradient get gradientOrangeFire => AppColorsUnified.orangeFire;
  
  // Estados
  Color get colorSuccess => AppColorsUnified.success;
  Color get colorError => AppColorsUnified.error;
  Color get colorWarning => AppColorsUnified.warning;
  Color get colorInfo => AppColorsUnified.info;
  
  // Backgrounds
  Color get colorBackground => AppColorsUnified.background;
  Color get colorSurface => AppColorsUnified.surface;
  
  // Texto
  Color get colorText => AppColorsUnified.textPrimary;
  Color get colorTextSecondary => AppColorsUnified.textSecondary;
  
  // Módulos
  Color get colorProduct => AppColorsUnified.productPrimary;
  Color get colorService => AppColorsUnified.servicePrimary;
  Color get colorGroup => AppColorsUnified.groupPrimary;
  Color get colorMessage => AppColorsUnified.messagePrimary;
  Color get colorCompany => AppColorsUnified.companyPrimary;
  Color get colorEmployee => AppColorsUnified.employeePrimary;
}

/// 📝 GUÍA DE USO
/// 
/// ```dart
/// // ✅ CORRECTO - Usar tokens definidos
/// Container(
///   color: AppColorsUnified.orange,
///   decoration: BoxDecoration(
///     gradient: AppColorsUnified.orangeGradient,
///   ),
/// )
/// 
/// // ✅ CORRECTO - Usar extensión de context
/// Text('Hola', style: TextStyle(color: context.colorOrange))
/// 
/// // ❌ INCORRECTO - NO usar colores hardcoded
/// Container(color: AppColorsUnified.orange)  // ¡NO HACER ESTO!
/// ```
/// 
/// 📌 REGLAS:
/// 1. SIEMPRE usar AppColorsUnified.xxx
/// 2. NUNCA crear Color(0xFF...) fuera de este archivo
/// 3. Para gradientes, usar los predefinidos
/// 4. Si necesitas un nuevo color, AÑÁDELO AQUÍ primero
/// 5. Usa gradientes multicapa para efectos premium
