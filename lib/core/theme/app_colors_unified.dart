import 'package:flutter/material.dart';

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
  static const Color orange = Color(0xFFFF6B35);  // Naranja vibrante principal
  static const Color orangeLight = Color(0xFFFFB84D);  // Naranja claro brillante
  static const Color orangeDark = Color(0xFFE06800);  // Naranja oscuro profundo
  static const Color orangeMedium = Color(0xFFF7931E);  // Naranja medio
  static const Color orangeApple = Color(0xFFFF9500);  // Naranja Apple style
  static const Color orangeBright = Color(0xFFFFAA33);  // Naranja muy brillante
  
  /// Gradiente NARANJA Principal (5 capas) - Efecto 3D
  /// Usar para botones principales, headers, FAB
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB84D),  // Highlight superior brillante
      Color(0xFFFF9500),  // Capa clara
      Color(0xFFFF6B35),  // Naranja principal (centro)
      Color(0xFFF7931E),  // Capa media-oscura
      Color(0xFFE06800),  // Sombra profunda
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente NARANJA Vertical (para headers)
  static const LinearGradient orangeVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFB84D),  // Top highlight
      Color(0xFFFF9500),
      Color(0xFFFF6B35),  // Centro
      Color(0xFFF7931E),
      Color(0xFFE06800),  // Bottom shadow
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
      Color(0xFFFFB84D),  // Amarillo-naranja brillante
      Color(0xFFFFAA33),  // Naranja muy claro
      Color(0xFFFF9500),  // Naranja medio-claro
      Color(0xFFFF6B35),  // Naranja principal
      Color(0xFFF7931E),  // Naranja medio-oscuro
      Color(0xFFE06800),  // Naranja profundo
    ],
    stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.8, 1.0],
  );
  
  /// Gradiente NARANJA Radial (para FAB circulares)
  static const RadialGradient orangeRadial = RadialGradient(
    center: Alignment(0.3, -0.5),  // Offset para simular luz
    radius: 1.5,
    colors: [
      Color(0xFFFFFAF0),  // Centro brillante
      Color(0xFFFFB84D),
      Color(0xFFFF6B35),  // Naranja principal
      Color(0xFFE06800),  // Borde oscuro
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
  static const Color gold = Color(0xFFD4AF37);  // Oro clásico
  static const Color goldLight = Color(0xFFF4E4C1);  // Oro claro brillante
  static const Color goldDark = Color(0xFFB8941E);  // Oro oscuro
  static const Color goldPure = Color(0xFFFFD700);  // Oro puro 24K
  
  /// PLATA - Para elementos secundarios, badges plateados
  static const Color silver = Color(0xFFC0C0C0);  // Plata base
  static const Color silverLight = Color(0xFFE8E8E8);  // Plata clara
  static const Color silverDark = Color(0xFFA8A8A8);  // Plata oscura
  
  /// Gradiente ORO (5 capas)
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFAF0),  // Highlight blanco dorado
      Color(0xFFF4E4C1),  // Oro brillante
      Color(0xFFD4AF37),  // Oro puro
      Color(0xFFB8941E),  // Oro medio
      Color(0xFFAA8C3A),  // Oro oscuro
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente PLATA (5 capas)
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),  // Highlight blanco
      Color(0xFFF5F5F5),
      Color(0xFFE8E8E8),  // Plata brillante
      Color(0xFFC0C0C0),  // Plata media
      Color(0xFF9E9E9E),  // Plata oscura
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// Gradiente ORO + PLATA épico (premium)
  static const LinearGradient goldSilverEpic = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF4E4C1),  // Oro claro
      Color(0xFFD4AF37),  // Oro base
      Color(0xFFE8E8E8),  // Plata clara
      Color(0xFFC0C0C0),  // Plata base
      Color(0xFFD4AF37),  // Oro base final
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  // ============================================
  // 🎨 FONDOS Y SUPERFICIES
  // ============================================
  
  static const Color background = Color(0xFFF8F5EF);  // Fondo principal cálido
  static const Color backgroundAlt = Color(0xFFF2EEE7);  // Fondo alternativo
  static const Color surface = Color(0xFFFFFFFF);  // Superficie blanca
  static const Color surfaceAlt = Color(0xFFFAF7F2);  // Superficie cálida
  static const Color cardBackground = Color(0xFFFFFFFF);  // Fondo de cards
  static const Color divider = Color(0xFFE5E7EB);  // Divisores
  static const Color outline = Color(0xFFD5CBBF);  // Bordes

  // ============================================
  // ✍️ TEXTO
  // ============================================
  
  static const Color textPrimary = Color(0xFF282523);  // Texto principal
  static const Color textSecondary = Color(0xFF5E574F);  // Texto secundario
  static const Color textDisabled = Color(0xFF9E948B);  // Texto deshabilitado
  static const Color textOnOrange = Color(0xFFFFFFFF);  // Texto sobre naranja
  static const Color textOnGold = Color(0xFF000000);  // Texto sobre oro

  // ============================================
  // ✅ ESTADOS (Success, Error, Warning, Info)
  // ============================================
  
  /// Verde ÉXITO
  static const Color success = Color(0xFF10B981);  // Verde esmeralda
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successContainer = Color(0xFFE4F3E5);  // Fondo verde claro
  
  /// Rojo ERROR
  static const Color error = Color(0xFFDC2626);  // Rojo rubí
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFFFCE4E4);  // Fondo rojo claro
  
  /// Amarillo WARNING
  static const Color warning = Color(0xFFFBBF24);  // Amarillo ámbar
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFFF6DA);  // Fondo amarillo claro
  
  /// Azul INFO
  static const Color info = Color(0xFF3B82F6);  // Azul zafiro
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFE0F0FA);  // Fondo azul claro

  // ============================================
  // 💎 GEMAS PRECIOSAS (para badges premium)
  // ============================================
  
  /// ESMERALDA (Verde premium)
  static const Color emerald = Color(0xFF00D084);
  static const Color emeraldLight = Color(0xFF4ADE80);
  static const Color emeraldDark = Color(0xFF00875A);
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6EE7B7), Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// RUBÍ (Rojo premium)
  static const Color ruby = Color(0xFFDC2626);
  static const Color rubyLight = Color(0xFFF87171);
  static const Color rubyDark = Color(0xFF7F1D1D);
  static const LinearGradient rubyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDA4AF), Color(0xFFF87171), Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFFB91C1C)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// ZAFIRO (Azul premium)
  static const Color sapphire = Color(0xFF2563EB);
  static const Color sapphireLight = Color(0xFF60A5FA);
  static const Color sapphireDark = Color(0xFF1E3A8A);
  static const LinearGradient sapphireGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF93C5FD), Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// AMATISTA (Púrpura premium)
  static const Color amethyst = Color(0xFF9333EA);
  static const Color amethystLight = Color(0xFFC084FC);
  static const Color amethystDark = Color(0xFF6B21A8);
  static const LinearGradient amethystGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE9D5FF), Color(0xFFC084FC), Color(0xFF9333EA), Color(0xFF7C3AED), Color(0xFF6B21A8)],
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
  static const Color productBackground = Color(0xFFFAF6ED);  // Fondo cálido oro
  static const LinearGradient productGradient = goldGradient;  // Usar gradiente oro
  static const Color productBadge = gold;
  static const Color productPrice = orange;
  static const Color productDiscount = error;

  // ============================================
  // 🔧 MÓDULO: SERVICIOS (Services)
  // ============================================
  
  /// Colores para cards de servicios
  static const Color servicePrimary = Color(0xFF9F7AEA);  // Púrpura
  static const Color serviceBackground = Color(0xFFF3EBFF);  // Fondo púrpura claro
  static const LinearGradient serviceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB794F6), Color(0xFF9F7AEA), Color(0xFF7C3AED)],
  );
  static const Color serviceBadge = Color(0xFF8B5CF6);
  static const Color servicePrice = servicePrimary;

  // ============================================
  // 👥 MÓDULO: GRUPOS (Groups)
  // ============================================
  
  /// Colores para grupos
  static const Color groupPrimary = Color(0xFF10B981);  // Verde
  static const Color groupBackground = Color(0xFFE6F9F3);  // Fondo verde claro
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
  static const Color postLikeInactive = Color(0xFFCBD5E1);
  static const Color postCommentIcon = Color(0xFF3B82F6);
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
    colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)],
  );

  // ============================================
  // 💬 MÓDULO: MENSAJERÍA (Messaging)
  // ============================================
  
  /// Colores para chat y mensajería
  static const Color messagePrimary = Color(0xFFEC4899);  // Rosa
  static const Color messageBackground = Color(0xFFFCE7F3);  // Fondo rosa claro
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
  static const Color profileBadgeBronze = Color(0xFFCD7F32);
  static const Color profileStatsBackground = surfaceAlt;
  static const Color profileStatsIcon = orange;

  // ============================================
  // 🏢 MÓDULO: EMPRESA (Company)
  // ============================================
  
  /// Colores para sección de empresa
  static const Color companyPrimary = Color(0xFF3B82F6);  // Azul corporativo
  static const Color companySecondary = Color(0xFF45B7D1);  // Azul turquesa
  static const Color companyBackground = Color(0xFFEBF5FF);  // Fondo azul claro
  static const Color companyAccent = gold;  // Oro para elementos premium
  
  /// Cards de empresa
  static const Color companyCardOrange = orange;
  static const Color companyCardPurple = Color(0xFFA78BFA);
  static const Color companyCardPink = Color(0xFFF472B6);
  static const Color companyCardBlue = companyPrimary;
  
  /// Gradientes de empresa
  static const LinearGradient companyGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
  );
  static const LinearGradient companyPremiumGradient = goldGradient;

  // ============================================
  // 👷 MÓDULO: EMPLEADOS (Employees)
  // ============================================
  
  /// Colores para gestión de empleados
  static const Color employeePrimary = companySecondary;  // Azul turquesa
  static const Color employeeBackground = Color(0xFFE0F2F7);
  static const Color employeeActive = success;
  static const Color employeeInactive = Color(0xFF9CA3AF);
  static const Color employeeBadgeGreen = Color(0xFF059669);
  static const Color employeeBadgePurple = Color(0xFF8B5CF6);
  static const Color employeeBadgePink = Color(0xFFDB2777);

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
  static const Color favoriteActive = Color(0xFFFFB800);  // Dorado brillante
  static const Color favoriteInactive = Color(0xFFCBD5E1);  // Gris claro
  static const Color favoriteBackground = Color(0xFFFFF9E6);  // Fondo amarillo muy claro

  // ============================================
  // 🎯 MENÚ RADIAL (Radial Menu)
  // ============================================
  
  /// Colores específicos del menú radial flotante
  static const Color radialButtonGradientStart = Color(0xFFFF6B35);  // Naranja oscuro
  static const Color radialButtonGradientMid = Color(0xFFF7931E);  // Naranja medio
  static const Color radialButtonGradientEnd = Color(0xFFFFB84D);  // Naranja dorado
  
  /// Gradiente del botón flotante (3 capas)
  static const LinearGradient radialButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFF7931E),
      Color(0xFFFFB84D),
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
  static const Color userWorkerPrimary = Color(0xFF059669);  // Verde oscuro
  static const Color userWorkerAccent = emerald;
  static const Color userWorkerBadge = Color(0xFF8B5CF6);  // Púrpura
  
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
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // ============================================
  // 🎨 UTILIDADES
  // ============================================
  
  /// Colores utilitarios
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
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
/// Container(color: Color(0xFFFF6B35))  // ¡NO HACER ESTO!
/// ```
/// 
/// 📌 REGLAS:
/// 1. SIEMPRE usar AppColorsUnified.xxx
/// 2. NUNCA crear Color(0xFF...) fuera de este archivo
/// 3. Para gradientes, usar los predefinidos
/// 4. Si necesitas un nuevo color, AÑÁDELO AQUÍ primero
/// 5. Usa gradientes multicapa para efectos premium
