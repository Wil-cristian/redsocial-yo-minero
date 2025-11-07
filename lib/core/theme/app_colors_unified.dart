import 'package:flutter/material.dart';

/// 🎨 SISTEMA UNIFIC ADO DE COLORES - YoMinero
/// 
/// Basado en TEORÍA DE COLORES profesional:
/// - Regla 60-30-10 (Dominante-Secundario-Acento)
/// - ORO como base de identidad (#D4AF37)
/// - NARANJA como acción (#FF6B35)
/// - Gradientes multicapa (5-7 capas) para profundidad
/// 
/// 📐 PROPORCIONES:
/// - 60% Neutral cálido (cream/beige) - DOMINANTE
/// - 30% Oro metalizado - SECUNDARIO (identidad)
/// - 10% Naranja vibrante - ACENTO (acción)
/// 
/// ⚠️ NO crear colores hardcoded fuera de este archivo
/// ⚠️ SIEMPRE referencia AppColorsUnified.xxx
/// 
/// Fecha: 2025-01-07
/// Ver: YOMINERO_COLOR_THEORY.md para fundamentos
/// 
class AppColorsUnified {
  AppColorsUnified._();

  // ============================================
  // 🥇 ORO - COLOR BASE (30% - SECUNDARIO)
  // ============================================
  
  /// ORO METALIZADO - Identidad de marca YoMinero
  /// Psicología: Prestigio, confianza, éxito, calidad premium
  /// Industria: Minería de oro, riqueza, logros
  
  // Oro base - ⚡ CAMBIADO A ORO BRILLANTE PARA PRUEBA
  static const Color gold = Color(0xFFFFD700);  // Oro puro 24K BRILLANTE (BASE) ⭐
  static const Color goldLight = Color(0xFFFFE873);  // Oro super brillante (highlights)
  static const Color goldDark = Color(0xFFD4AF37);  // Oro metalizado (sombras)
  static const Color goldPure = Color(0xFFFFEA00);  // Oro amarillo puro (premiums)
  static const Color goldWarm = Color(0xFFFFB300);  // Goldenrod brillante
  
  /// Gradiente ORO (5 capas) - Efecto BRILLANTE 3D ⚡
  /// Uso: Badges premium, headers especiales, productos destacados
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFF0),  // Highlight blanco puro
      Color(0xFFFFE873),  // Oro super brillante
      Color(0xFFFFD700),  // Oro puro 24K (base) ⭐
      Color(0xFFD4AF37),  // Oro metalizado (medio)
      Color(0xFFB8941E),  // Oro oscuro
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente ORO Vertical (para headers)
  static const LinearGradient goldVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFAF0),
      Color(0xFFF4E4C1),
      Color(0xFFD4AF37),
      Color(0xFFB8941E),
      Color(0xFFAA8C3A),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente ORO Radial (para badges circulares)
  static const RadialGradient goldRadial = RadialGradient(
    center: Alignment(0.3, -0.4),
    radius: 1.2,
    colors: [
      Color(0xFFFFFAF0),
      Color(0xFFF4E4C1),
      Color(0xFFD4AF37),
      Color(0xFFB8941E),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // ============================================
  // 🧡 NARANJA - COLOR ACENTO (10% - ACCIÓN)
  // ============================================
  
  /// NARANJA VIBRANTE - Call to action, energía
  /// Psicología: Energía, optimismo, innovación, acción
  /// Industria: Seguridad (cascos, equipo), modernidad
  
  // Naranja base (#FF6B35 - EL FAVORITO del botón radial)
  static const Color orange = Color(0xFFFF6B35);  // Naranja vibrante (BASE)
  static const Color orangeLight = Color(0xFFFFB84D);  // Naranja brillante
  static const Color orangeDark = Color(0xFFE06800);  // Naranja oscuro
  static const Color orangeMedium = Color(0xFFF7931E);  // Naranja medio
  static const Color orangeApple = Color(0xFFFF9500);  // Naranja Apple style
  static const Color orangeBright = Color(0xFFFFAA33);  // Naranja muy brillante
  
  /// Gradiente NARANJA Principal (5 capas) - Efecto 3D premium
  /// Uso: Botones CTA, menú radial, acciones principales (10% del diseño)
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB84D),  // Highlight brillante
      Color(0xFFFF9500),  // Capa clara
      Color(0xFFFF6B35),  // Naranja principal (centro)
      Color(0xFFF7931E),  // Capa media
      Color(0xFFE06800),  // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente NARANJA Vertical
  static const LinearGradient orangeVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFB84D),
      Color(0xFFFF9500),
      Color(0xFFFF6B35),
      Color(0xFFF7931E),
      Color(0xFFE06800),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente NARANJA Fuego (7 capas) - Ultra dramático
  /// Uso: Splash screens, elementos hero, promociones especiales
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
    center: Alignment(0.3, -0.5),
    radius: 1.5,
    colors: [
      Color(0xFFFFFAF0),  // Centro brillante
      Color(0xFFFFB84D),  // Highlight
      Color(0xFFFF6B35),  // Naranja base
      Color(0xFFE06800),  // Borde oscuro
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Sombra y glow de naranja
  static const Color orangeShadow = Color(0x50FF6B35);  // 50% opacidad
  static const Color orangeGlow = Color(0x40FFB84D);  // Glow suave

  // ============================================
  // 🎨 NEUTRAL CÁLIDO - COLOR DOMINANTE (60%)
  // ============================================
  
  /// Fondos, backgrounds, áreas grandes
  /// Propósito: Permitir que oro y naranja brillen sin competencia
  
  static const Color background = Color(0xFFF8F5EF);  // Cream cálido principal
  static const Color backgroundAlt = Color(0xFFF2EEE7);  // Beige suave alternativo
  static const Color surface = Color(0xFFFFFFFF);  // Blanco puro (cards)
  static const Color surfaceAlt = Color(0xFFFAF7F2);  // Blanco cálido
  static const Color surfaceWarm = Color(0xFFFFFBF5);  // Blanco muy cálido
  static const Color cardBackground = Color(0xFFFFFFFF);  // Fondo de cards
  static const Color divider = Color(0xFFE5E7EB);  // Divisores
  static const Color outline = Color(0xFFD5CBBF);  // Bordes

  // ============================================
  // 🥈 PLATA - Color Secundario Alternativo
  // ============================================
  
  /// Para badges silver, elementos secundarios
  static const Color silver = Color(0xFFC0C0C0);  // Plata base
  static const Color silverLight = Color(0xFFE8E8E8);  // Plata clara
  static const Color silverDark = Color(0xFFA8A8A8);  // Plata oscura
  
  /// Gradiente PLATA (5 capas)
  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),  // Highlight blanco
      Color(0xFFF5F5F5),  // Plata muy clara
      Color(0xFFE8E8E8),  // Plata brillante
      Color(0xFFC0C0C0),  // Plata media
      Color(0xFF9E9E9E),  // Plata oscura
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// Gradiente ORO + PLATA épico (premium máximo)
  static const LinearGradient goldSilverEpic = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF4E4C1),  // Oro claro
      Color(0xFFD4AF37),  // Oro base
      Color(0xFFE8E8E8),  // Plata clara
      Color(0xFFC0C0C0),  // Plata base
      Color(0xFFD4AF37),  // Oro final
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// Gradiente ORO → NARANJA (transición identidad → acción)
  static const LinearGradient goldOrangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4E4C1),  // Oro brillante
      Color(0xFFD4AF37),  // Oro base
      Color(0xFFFFB84D),  // Transición dorada-naranja
      Color(0xFFFF9500),  // Naranja-oro
      Color(0xFFFF6B35),  // Naranja vibrante
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // ✍️ TEXTO
  // ============================================
  
  static const Color textPrimary = Color(0xFF282523);  // Texto principal (casi negro)
  static const Color textSecondary = Color(0xFF5E574F);  // Texto secundario
  static const Color textDisabled = Color(0xFF9E948B);  // Texto deshabilitado
  static const Color textOnOrange = Color(0xFFFFFFFF);  // Texto sobre naranja
  static const Color textOnGold = Color(0xFF000000);  // Texto sobre oro
  static const Color textOnDark = Color(0xFFFFFFFF);  // Texto sobre oscuros

  // ============================================
  // ✅ ESTADOS (Success, Error, Warning, Info)
  // ============================================
  
  /// Verde ÉXITO - Gama esmeralda
  static const Color success = Color(0xFF10B981);  // Verde esmeralda base
  static const Color successLight = Color(0xFF34D399);  // Verde claro
  static const Color successDark = Color(0xFF059669);  // Verde oscuro
  static const Color successContainer = Color(0xFFE4F3E5);  // Fondo verde claro
  
  /// Rojo ERROR - Gama rubí
  static const Color error = Color(0xFFDC2626);  // Rojo rubí base
  static const Color errorLight = Color(0xFFF87171);  // Rojo claro
  static const Color errorDark = Color(0xFFB91C1C);  // Rojo oscuro
  static const Color errorContainer = Color(0xFFFCE4E4);  // Fondo rojo claro
  
  /// Amarillo WARNING - Gama ámbar
  static const Color warning = Color(0xFFFBBF24);  // Amarillo ámbar
  static const Color warningLight = Color(0xFFFDE68A);  // Amarillo claro
  static const Color warningDark = Color(0xFFF59E0B);  // Amarillo oscuro
  static const Color warningContainer = Color(0xFFFFF6DA);  // Fondo amarillo
  
  /// Azul INFO - Gama zafiro
  static const Color info = Color(0xFF3B82F6);  // Azul zafiro base
  static const Color infoLight = Color(0xFF60A5FA);  // Azul claro
  static const Color infoDark = Color(0xFF2563EB);  // Azul oscuro
  static const Color infoContainer = Color(0xFFE0F0FA);  // Fondo azul

  // ============================================
  // 💎 GEMAS PREMIUM (Badges, Categorías)
  // ============================================
  
  /// ESMERALDA (Verde premium)
  static const Color emerald = Color(0xFF00D084);
  static const Color emeraldLight = Color(0xFF4ADE80);
  static const Color emeraldDark = Color(0xFF00875A);
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF6EE7B7), Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// RUBÍ (Rojo premium)
  static const Color ruby = Color(0xFFDC2626);
  static const Color rubyLight = Color(0xFFF87171);
  static const Color rubyDark = Color(0xFF7F1D1D);
  static const LinearGradient rubyGradient = LinearGradient(
    colors: [Color(0xFFFDA4AF), Color(0xFFF87171), Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFFB91C1C)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// ZAFIRO (Azul premium)
  static const Color sapphire = Color(0xFF2563EB);
  static const Color sapphireLight = Color(0xFF60A5FA);
  static const Color sapphireDark = Color(0xFF1E3A8A);
  static const LinearGradient sapphireGradient = LinearGradient(
    colors: [Color(0xFF93C5FD), Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// AMATISTA (Púrpura premium)
  static const Color amethyst = Color(0xFF9333EA);
  static const Color amethystLight = Color(0xFFC084FC);
  static const Color amethystDark = Color(0xFF6B21A8);
  static const LinearGradient amethystGradient = LinearGradient(
    colors: [Color(0xFFE9D5FF), Color(0xFFC084FC), Color(0xFF9333EA), Color(0xFF7C3AED), Color(0xFF6B21A8)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// DIAMANTE/CRISTAL (Neutral premium)
  static const Color diamond = Color(0xFFE2E8F0);
  static const Color diamondLight = Color(0xFFF1F5F9);
  static const Color diamondDark = Color(0xFF64748B);
  
  /// BRONCE (Medalla bronce)
  static const Color bronze = Color(0xFFCD7F32);
  static const Color bronzeLight = Color(0xFFE5A66D);
  static const Color bronzeDark = Color(0xFFB87333);

  // ============================================
  // 🏠 MÓDULO: HOME PAGE
  // ============================================
  
  static const Color homeWelcomeStart = gold;
  static const Color homeWelcomeEnd = orange;
  static const Color homeCardBackground = surface;
  static const Color homeIconTint = orange;
  static const LinearGradient homeHeroGradient = goldOrangeGradient;

  // ============================================
  // 🛒 MÓDULO: PRODUCTOS
  // ============================================
  
  static const Color productPrimary = gold;  // Oro para productos
  static const Color productBackground = Color(0xFFFAF6ED);  // Fondo cálido oro
  static const LinearGradient productGradient = goldGradient;
  static const Color productBadge = gold;
  static const Color productPrice = orange;
  static const Color productDiscount = error;

  // ============================================
  // 🔧 MÓDULO: SERVICIOS
  // ============================================
  
  static const Color servicePrimary = Color(0xFF9F7AEA);  // Púrpura
  static const Color serviceBackground = Color(0xFFF3EBFF);
  static const LinearGradient serviceGradient = LinearGradient(
    colors: [Color(0xFFB794F6), Color(0xFF9F7AEA), Color(0xFF7C3AED)],
  );
  static const Color serviceBadge = Color(0xFF8B5CF6);

  // ============================================
  // 👥 MÓDULO: GRUPOS
  // ============================================
  
  static const Color groupPrimary = success;  // Verde esmeralda
  static const Color groupBackground = Color(0xFFE6F9F3);
  static const LinearGradient groupGradient = emeraldGradient;
  static const Color groupBadge = emerald;

  // ============================================
  // 📝 MÓDULO: POSTS / COMUNIDAD
  // ============================================
  
  static const Color postPrimary = orange;
  static const Color postBackground = surface;
  static const Color postLikeActive = error;
  static const Color postLikeInactive = Color(0xFFCBD5E1);
  
  static const LinearGradient postProductGradient = goldGradient;
  static const LinearGradient postServiceGradient = serviceGradient;
  static const LinearGradient postOfferGradient = emeraldGradient;
  static const LinearGradient postQuestionGradient = orangeGradient;
  static const LinearGradient postNewsGradient = sapphireGradient;

  // ============================================
  // 💬 MÓDULO: MENSAJERÍA
  // ============================================
  
  static const Color messagePrimary = Color(0xFFEC4899);  // Rosa
  static const Color messageBackground = Color(0xFFFCE7F3);
  static const Color messageBubbleUser = orange;
  static const Color messageBubbleOther = Color(0xFFF3F4F6);
  static const Color messageUnreadBadge = error;

  // ============================================
  // 👤 MÓDULO: PERFIL
  // ============================================
  
  static const Color profileHeaderStart = orange;
  static const Color profileHeaderEnd = gold;
  static const LinearGradient profileHeaderGradient = goldOrangeGradient;
  static const Color profileBadgeGold = gold;
  static const Color profileBadgeSilver = silver;
  static const Color profileBadgeBronze = bronze;

  // ============================================
  // 🏢 MÓDULO: EMPRESA (Complementario AZUL)
  // ============================================
  
  /// AZUL CORPORATIVO - Complementario del oro (teoría de color)
  /// Psicología: Confianza, profesionalismo, estabilidad
  
  static const Color companyPrimary = Color(0xFF3B82F6);  // Azul corporativo
  static const Color companySecondary = Color(0xFF45B7D1);  // Azul turquesa (el que usas)
  static const Color companyBackground = Color(0xFFEBF5FF);
  static const Color companyAccent = gold;  // Oro para premium
  
  static const LinearGradient companyGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
  );
  
  static const Color companyCardOrange = orange;
  static const Color companyCardPurple = Color(0xFFA78BFA);
  static const Color companyCardPink = Color(0xFFF472B6);
  static const Color companyCardBlue = companyPrimary;

  // ============================================
  // 👷 MÓDULO: EMPLEADOS
  // ============================================
  
  static const Color employeePrimary = companySecondary;
  static const Color employeeBackground = Color(0xFFE0F2F7);
  static const Color employeeActive = success;
  static const Color employeeInactive = Color(0xFF9CA3AF);
  static const Color employeeBadgeGreen = Color(0xFF059669);
  static const Color employeeBadgePurple = Color(0xFF8B5CF6);
  static const Color employeeBadgePink = Color(0xFFDB2777);

  // ============================================
  // 📊 MÓDULO: MÉTRICAS
  // ============================================
  
  static const Color metricsIncome = success;
  static const Color metricsExpense = error;
  static const Color metricsProfit = emerald;
  static const LinearGradient metricsIncomeGradient = emeraldGradient;
  static const LinearGradient metricsExpenseGradient = rubyGradient;

  // ============================================
  // 🔔 MÓDULO: NOTIFICACIONES
  // ============================================
  
  static const Color notificationUnread = orange;
  static const Color notificationRead = textDisabled;
  static const Color notificationBadge = error;

  // ============================================
  // ⭐ MÓDULO: FAVORITOS
  // ============================================
  
  static const Color favoriteActive = goldWarm;  // Goldenrod brillante
  static const Color favoriteInactive = Color(0xFFCBD5E1);

  // ============================================
  // 🎯 MENÚ RADIAL
  // ============================================
  
  /// Gradiente del botón principal (3 capas - tu favorito)
  static const LinearGradient radialButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeMedium, orangeLight],
  );
  
  static const Color radialOverlay = Color(0xB3000000);
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
  
  static const Color userIndividualPrimary = orange;
  static const Color userIndividualAccent = gold;
  static const Color userWorkerPrimary = Color(0xFF059669);
  static const Color userWorkerAccent = emerald;
  static const Color userCompanyPrimary = companyPrimary;
  static const Color userCompanyAccent = gold;

  // ============================================
  // 🌓 DARK MODE (Preparación Futura)
  // ============================================
  
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // ============================================
  // 🎨 UTILIDADES
  // ============================================
  
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  static Color overlay(Color color, double opacity) =>
      color.withOpacity(opacity);
  
  static Color textOnColor(Color backgroundColor) =>
      backgroundColor.computeLuminance() > 0.54 ? black : white;
}

/// 🎨 EXTENSIÓN DE CONTEXT PARA ACCESO RÁPIDO
extension AppColorsContext on BuildContext {
  // BASE: Oro + Naranja
  Color get colorGold => AppColorsUnified.gold;
  Color get colorOrange => AppColorsUnified.orange;
  Color get colorSilver => AppColorsUnified.silver;
  
  // Gradientes principales
  LinearGradient get gradientGold => AppColorsUnified.goldGradient;
  LinearGradient get gradientOrange => AppColorsUnified.orangeGradient;
  LinearGradient get gradientGoldOrange => AppColorsUnified.goldOrangeGradient;
  LinearGradient get gradientOrangeFire => AppColorsUnified.orangeFire;
  
  // Estados
  Color get colorSuccess => AppColorsUnified.success;
  Color get colorError => AppColorsUnified.error;
  Color get colorWarning => AppColorsUnified.warning;
  Color get colorInfo => AppColorsUnified.info;
  
  // Backgrounds (60%)
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
}

/// 📝 GUÍA DE USO RÁPIDA
/// 
/// ```dart
/// // ✅ CORRECTO - Color plano
/// Container(color: AppColorsUnified.gold)
/// 
/// // ✅ CORRECTO - Gradiente multicapa
/// Container(
///   decoration: BoxDecoration(
///     gradient: AppColorsUnified.goldGradient,  // 5 capas!
///   ),
/// )
/// 
/// // ✅ CORRECTO - Con context extension
/// Text('Hola', style: TextStyle(color: context.colorGold))
/// 
/// // ✅ CORRECTO - Gradiente oro → naranja
/// Container(
///   decoration: BoxDecoration(
///     gradient: AppColorsUnified.goldOrangeGradient,
///   ),
/// )
/// 
/// // ❌ INCORRECTO - NO hardcodear
/// Container(color: Color(0xFFD4AF37))  // ¡NO!
/// ```
/// 
/// 📐 PROPORCIONES RECOMENDADAS (Regla 60-30-10):
/// - 60% Fondos neutros (background, surface)
/// - 30% Oro (headers, cards premium, badges)
/// - 10% Naranja (botones CTA, acciones, menú radial)
/// 
/// Ver YOMINERO_COLOR_THEORY.md para fundamentos completos
