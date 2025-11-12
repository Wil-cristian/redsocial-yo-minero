import 'package:flutter/material.dart';

/// 🎨 SISTEMA CENTRALIZADO DE COLORES - YoMinero v2.0
/// 
/// ⚡ NUEVO ESTILO: Blanco + Gris + Oro Premium
/// 
/// Filosofía de diseño:
/// - 90% BLANCO Y GRIS (limpio, minimalista, profesional)
/// - 8% NEGRO/GRIS OSCURO (texto con alto contraste)
/// - 2% ORO BRILLANTE (acentos premium en CTAs y destacados)
/// 
/// Si cambias UN color aquí → se actualiza en TODA la app automáticamente
/// 
/// Los 10 colores BASE redefinidos:
/// 1. orange - DEPRECATED → Redirigido a gris neutro (legacy compatibility)
/// 2. gold - ORO PREMIUM (único acento de color, úsalo con moderación)
/// 3. background - BLANCO PURO (#FFFFFF)
/// 4. surface - BLANCO PURO (#FFFFFF)
/// 5. textPrimary - NEGRO PURO (#000000)
/// 6. textSecondary - GRIS 60% (#666666)
/// 7. success - Verde (semántica de éxito)
/// 8. error - Rojo (semántica de error)
/// 9. warning - Ámbar suave (desaturado para no competir con gold)
/// 10. companyBlue - Azul corporativo (solo para contextos empresariales)
/// 
/// ⚠️ NO crear colores hardcoded fuera de este archivo
/// ⚠️ SIEMPRE referencia AppColorsUnified.xxx
/// 
class AppColorsUnified {
  AppColorsUnified._();

  // ============================================
  // 🎨 LOS 10 COLORES BASE (REDEFINIDOS v2.0)
  // ============================================
  
  /// 1️⃣ (DEPRECATED) ORANGE → Ahora apunta a gris neutro
  /// ⚠️ LEGACY: Mantiene compatibilidad pero ya NO se usa en nuevo diseño
  /// Si código antiguo lo referencia, no "grita" naranja sino que se integra.
  static const Color orange = Color(0xFFBDBDBD);  // Gris medio neutral (antes: #FF8C00)
  
  /// 2️⃣ ORO PREMIUM → El ÚNICO acento de color en toda la app
  /// 💎 ORO METÁLICO REALISTA - Tono base equilibrado
  /// 💎 Úsalo SOLO en: botones CTA principales, badges premium, favoritos activos
  /// 📊 Debe aparecer en 2-5% de la pantalla (no más)
  static const Color gold = Color(0xFFD4AF37);  // 🌟 Oro metálico clásico - TONO BASE
  
  // ============================================
  // ⭐ SISTEMA DE ORO METÁLICO DE 5 CAPAS
  // Simula metal pulido con iluminación superior izquierda
  // ============================================
  
  /// CAPA 1️⃣: BRILLO MÁXIMO - Donde la luz incide directamente
  /// Reflejo especular más intenso, punto focal de iluminación
  static const Color goldHighlight = Color(0xFFFFF9E6);  // Amarillo perlado muy claro
  
  /// CAPA 2️⃣: REFLEJO CLARO - Transición luminosa
  /// Reflejo brillante que conecta el punto de luz con el oro base
  static const Color goldBright = Color(0xFFFFE55C);  // Amarillo dorado brillante
  
  /// CAPA 3️⃣: ORO BASE - Tono principal metálico (el gold original)
  /// Equilibrado y cálido, la referencia visual del oro
  static const Color goldBase = gold;  // #D4AF37 - Oro metálico clásico
  
  /// CAPA 4️⃣: SOMBRA CÁLIDA - Zonas menos iluminadas
  /// Oro oscuro profundo que añade volumen y profundidad
  static const Color goldShadow = Color(0xFFAA8C3A);  // Oro oscuro cálido
  
  /// CAPA 5️⃣: CONTRASTE ESTRUCTURAL - Bordes y profundidad máxima
  /// Bronce oscuro para definir estructura y forma
  static const Color goldDeep = Color(0xFF6E4B18);  // Bronce oscuro marrón
  
  /// 3️⃣ BACKGROUND → Blanco puro (base de toda la app)
  /// 🏔️ Limpio, luminoso, profesional
  static const Color background = Color(0xFFFFFFFF);  // Blanco puro
  
  /// 4️⃣ SURFACE → Blanco puro para cards/sheets
  /// 📄 Mismo tono que background para máxima limpieza visual
  static const Color surface = Color(0xFFFFFFFF);  // Blanco puro
  
  /// 5️⃣ TEXTO PRINCIPAL → Negro puro (máximo contraste)
  /// 📝 Títulos, contenido importante, iconografía principal
  static const Color textPrimary = Color(0xFF000000);  // Negro puro
  
  /// 6️⃣ TEXTO SECUNDARIO → Gris 60%
  /// 💬 Subtítulos, descripciones, placeholders, iconografía secundaria
  static const Color textSecondary = Color(0xFF666666);  // Gris medio
  
  /// 7️⃣ SUCCESS → Verde (semántica universal)
  static const Color success = Color(0xFF10B981);  // Verde esmeralda
  
  /// 8️⃣ ERROR → Rojo (semántica universal)
  static const Color error = Color(0xFFEF4444);  // Rojo alerta
  
  /// 9️⃣ WARNING → Ámbar suave (desaturado)
  /// ⚠️ Tono más suave para no competir con el oro
  static const Color warning = Color(0xFFE3B341);  // Ámbar desaturado
  
  /// 🔟 COMPANY BLUE → Azul corporativo
  /// 🏢 Solo para contextos empresariales específicos
  static const Color companyBlue = Color(0xFF2563EB);  // Azul royal

  // ============================================
  // 🎨 GRADIENTES (Sistema minimalista v2.0)
  // ============================================
  
  /// Gradiente BLANCO PERLA SUAVE (principal para fondos amplios)
  /// 🏔️ Blanco puro → Blanco perla cálido
  /// Uso: Fondos de pantallas completas, headers, scroll containers
  static LinearGradient get greySoftGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),  // Blanco puro
      Color(0xFFFFF9F5),  // Blanco perla cálido (antes: #F5F5F5)
    ],
  );
  
  /// Gradiente BLANCO PERLA SECCIÓN (para áreas destacadas)
  /// 📦 Blanco perla → Blanco perla medio
  /// Uso: Secciones que necesitan separarse del fondo sin color
  static LinearGradient get greySectionGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFAF6),  // Blanco perla claro (antes: #EDEDED)
      Color(0xFFFFF5EE),  // Blanco perla medio (antes: #DDDDDD)
    ],
  );
  
  /// 🌟 GRADIENTE ORO METÁLICO REALISTA - 5 CAPAS
  /// Simula metal pulido con iluminación superior izquierda
  /// ⚠️ USO: SOLO en botones CTA principales, badges premium, elementos destacados
  /// 📊 No debe cubrir más del 2-5% de la pantalla
  /// 
  /// Estructura de capas:
  /// 1. Brillo máximo (#FFF9E6) - Punto de luz directa
  /// 2. Reflejo claro (#FFE55C) - Transición luminosa
  /// 3. Oro base (#D4AF37) - Tono principal metálico
  /// 4. Sombra cálida (#AA8C3A) - Zonas menos iluminadas
  /// 5. Contraste estructural (#6E4B18) - Bordes y profundidad
  static LinearGradient get goldGradient => const LinearGradient(
    begin: Alignment.topLeft,      // Iluminación superior izquierda
    end: Alignment.bottomRight,     // Sombra inferior derecha
    colors: [
      goldHighlight,  // CAPA 1: Brillo máximo (#FFF9E6)
      goldBright,     // CAPA 2: Reflejo claro (#FFE55C)
      goldBase,       // CAPA 3: Oro base (#D4AF37)
      goldShadow,     // CAPA 4: Sombra cálida (#AA8C3A)
      goldDeep,       // CAPA 5: Contraste estructural (#6E4B18)
    ],
    stops: [0.0, 0.25, 0.50, 0.75, 1.0],  // Transiciones suaves equidistantes
  );
  
  /// 🌟 GRADIENTE ORO RADIAL (para efectos circulares/botones redondos)
  /// Centro brillante que se oscurece hacia los bordes
  /// Simula reflejo especular difuso en superficie convexa
  static RadialGradient get goldRadialGradient => const RadialGradient(
    center: Alignment(-0.3, -0.3),  // Desplazado arriba-izquierda (fuente de luz)
    radius: 1.2,                     // Radio amplio para transición suave
    colors: [
      goldHighlight,  // Centro: Brillo máximo
      goldBright,     // Transición luminosa
      goldBase,       // Oro medio
      goldShadow,     // Sombra cálida
      goldDeep,       // Borde oscuro
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// 🌟 GRADIENTE ORO SUTIL (para fondos de cards premium)
  /// Versión más suave del oro para no saturar
  /// Solo 3 capas para efecto discreto
  static LinearGradient get goldSubtleGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      goldHighlight.withValues(alpha: 0.3),  // Brillo muy sutil
      goldBase.withValues(alpha: 0.2),       // Oro base transparente
      goldShadow.withValues(alpha: 0.1),     // Sombra apenas visible
    ],
  );
  
  /// 🌟 GRADIENTE ORO SHIMMER (para animaciones y efectos hover)
  /// Efecto de "barrido" de luz sobre superficie metálica
  /// Útil para TweenAnimationBuilder o AnimatedContainer
  static LinearGradient get goldShimmerGradient => const LinearGradient(
    begin: Alignment(-1.0, -1.0),   // Inicia fuera del componente (arriba-izquierda)
    end: Alignment(1.0, 1.0),        // Termina fuera del componente (abajo-derecha)
    colors: [
      goldDeep,       // Inicio oscuro
      goldShadow,     // Transición cálida
      goldHighlight,  // ⭐ Brillo máximo (punto focal del shimmer)
      goldShadow,     // Transición cálida de salida
      goldDeep,       // Final oscuro
    ],
    stops: [0.0, 0.35, 0.5, 0.65, 1.0],  // Brillo concentrado en el centro
  );
  
  /// (LEGACY) Gradiente NARANJA → Redirigido a gris neutro
  /// 🔄 Mantiene compatibilidad con código antiguo sin "gritar" naranja
  static LinearGradient get orangeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lighten(orange, 0.15),  // Gris claro
      orange,                   // Gris medio
      darken(orange, 0.15),   // Gris oscuro
    ],
  );
  
  /// Gradiente AZUL EMPRESA (contextos corporativos)
  /// 🏢 Solo para módulos empresariales específicos
  static LinearGradient get companyGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lighten(companyBlue, 0.12),  // Azul claro
      companyBlue,                   // Base azul
      darken(companyBlue, 0.12),   // Azul oscuro
    ],
  );
  
  /// (LEGACY) Gradiente ÉPICO → Redirigido a blanco perla + oro sutil
  /// 🔄 Versión compatible del antiguo gradiente premium
  static LinearGradient get epicGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFFFFBF8),  // Blanco perla ultra claro (antes: #EEEEEE)
      const Color(0xFFFFF9F5),  // Blanco perla cálido (antes: #DDDDDD)
      gold.withValues(alpha: 0.3),  // Oro transparente
      gold,                       // Oro final
    ],
    stops: const [0.0, 0.3, 0.6, 1.0],
  );

  // ============================================
  // 🎨 COLORES DERIVADOS (Sistema v2.0)
  // ============================================
  
  // FONDOS (blanco perla suave - sin grises oscuros)
  static Color get backgroundDark => const Color(0xFFFFF9F5);  // Blanco perla cálido (antes: #F5F5F5)
  static Color get backgroundLight => const Color(0xFFFFFFFF);  // Blanco puro
  static Color get backgroundLighter => const Color(0xFFFFFBF8);  // Blanco perla ultra claro
  
  // SUPERFICIES (todas blancas o blanco perla muy claro)
  static Color get surfaceElevated => surface;  // Blanco puro
  static Color get surfaceTinted => const Color(0xFFFFFBF8);  // Blanco perla ultra claro (antes: #FAFAFA)
  static Color get surfaceLight => surface;  // Blanco puro
  
  // DIVISORES Y SEPARADORES (sutiles)
  static Color get divider => fade(textPrimary, 0.08);  // Línea muy sutil
  
  // TEXTO SOBRE COLORES
  static Color get textOnOrange => textPrimary;  // Negro (orange ahora es gris)
  static Color get textOnGold => textPrimary;  // Negro sobre oro (alto contraste)
  static Color get textOnCompanyBlue => surface;  // Blanco sobre azul
  static Color get textDisabled => fade(textSecondary, 0.4);  // Gris muy claro

  // ============================================
  // 🎨 COLORES ESPECÍFICOS PARA UI v2.0
  // (Reemplazan Colors.xxx con escala de grises neutral)
  // ============================================
  
  // BLANCOS (todos derivan de surface = #FFFFFF)
  static Color get pureWhite => surface;  // Blanco puro
  static Color get whiteTransparent05 => fade(surface, 0.05);
  static Color get whiteTransparent10 => fade(surface, 0.1);
  static Color get whiteTransparent15 => fade(surface, 0.15);
  static Color get whiteTransparent20 => fade(surface, 0.2);
  static Color get whiteTransparent30 => fade(surface, 0.3);
  static Color get whiteTransparent70 => fade(surface, 0.7);
  static Color get whiteTransparent80 => fade(surface, 0.8);
  static Color get whiteTransparent90 => fade(surface, 0.9);
  // Aliases para compatibilidad
  static Color get whiteA05 => whiteTransparent05;
  static Color get whiteA10 => whiteTransparent10;
  
  // NEGROS (todos derivan de textPrimary = #000000)
  static Color get pureBlack => textPrimary;  // Negro puro
  static Color get blackTransparent05 => fade(textPrimary, 0.05);
  static Color get blackTransparent08 => fade(textPrimary, 0.08);
  static Color get blackTransparent10 => fade(textPrimary, 0.1);
  static Color get blackTransparent20 => fade(textPrimary, 0.2);
  static Color get blackTransparent30 => fade(textPrimary, 0.3);
  static Color get blackTransparent70 => fade(textPrimary, 0.7);
  static Color get black87 => fade(textPrimary, 0.87);
  static Color get black26 => fade(textPrimary, 0.26);
  // Aliases para compatibilidad
  static Color get blackA05 => blackTransparent05;
  static Color get blackA10 => blackTransparent10;
  static Color get blackA20 => blackTransparent20;
  static Color get blackA70 => blackTransparent70;
  
  // GRISES (escala neutral centrada en #666 - tonos más claros)
  /// 🎨 Escala de grises redefinida - Blanco perla a gris suave
  static Color get grey50 => const Color(0xFFFFFBF8);   // Blanco perla ultra claro (antes: #FAFAFA)
  static Color get grey100 => const Color(0xFFFFF9F5);  // Blanco perla cálido (antes: #F5F5F5)
  static Color get grey200 => const Color(0xFFFFF5EE);  // Blanco perla medio (antes: #EEEEEE)
  static Color get grey300 => const Color(0xFFE0E0E0);  // Gris claro medio (sin cambios)
  static Color get grey400 => const Color(0xFFBDBDBD);  // Gris medio (sin cambios)
  static Color get grey500 => const Color(0xFF9E9E9E);  // Gris (sin cambios)
  static Color get grey600 => const Color(0xFF757575);  // Gris oscuro (sin cambios)
  static Color get grey700 => const Color(0xFF616161);  // Gris muy oscuro (sin cambios)
  
  // BORDERS Y OUTLINES
  static Color get borderLight => grey200;  // Bordes muy sutiles
  static Color get borderMedium => grey300;  // Bordes normales
  static Color get borderDark => grey400;  // Bordes destacados
  static Color get border => grey300;  // Alias para borderMedium
  static Color get borderStrong => grey400;  // Alias para borderDark
  static Color get outline => grey300;  // Outlines de inputs normales
  static Color get outlineFocus => gold;  // ⭐ Outline en foco = ORO (no naranja)
  
  // OVERLAYS (para modales y diálogos)
  static Color get overlayDark => blackTransparent70;  // Overlay oscuro
  static Color get overlayMedium => blackTransparent30;  // Overlay medio
  static Color get overlayLight => blackTransparent10;  // Overlay sutil
  static Color get overlay => overlayMedium;  // Alias para medio
  
  // SHADOWS (sombras sutiles en gris)
  static Color get shadowLight => blackTransparent05;  // Sombra muy sutil
  static Color get shadowMedium => blackTransparent10;  // Sombra normal
  static Color get shadowDark => blackTransparent20;  // Sombra destacada
  static Color get shadow => shadowMedium;  // Alias para normal
  
  // ICONOS (negro/gris)
  static Color get iconPrimary => textPrimary;  // Iconos principales (negro)
  static Color get iconSecondary => textSecondary;  // Iconos secundarios (gris)
  static Color get iconDisabled => fade(textSecondary, 0.3);  // Iconos deshabilitados
  static Color get iconOnColor => surface;  // Iconos sobre fondos de color (blanco)
  
  // INPUTS Y FIELDS
  static Color get inputFill => surface;  // Fondo blanco puro
  static Color get inputBorder => grey300;  // Borde gris claro
  static Color get inputBorderFocus => gold;  // ⭐ Borde en foco = ORO
  static Color get inputHint => grey500;  // Texto hint gris medio
  static Color get inputDisabled => grey100;  // Input deshabilitado blanco perla
  
  // CHIPS Y TAGS
  static Color get chipBackground => grey200;  // Chip normal blanco perla medio
  static Color get chipBackgroundSelected => gold;  // ⭐ Chip seleccionado = ORO
  static Color get chipText => textPrimary;  // Texto negro
  static Color get chipTextSelected => surface;  // Texto blanco sobre oro
  
  // ============================================
  // 🔄 HELPERS DE COMPATIBILIDAD v2.0 (para código legacy)
  // ============================================
  
  // Variaciones de NARANJA (LEGACY - ahora mapean a grises neutros)
  /// ⚠️ DEPRECATED: orange ahora es gris neutro (#BDBDBD)
  static Color get orangeLight => lighten(orange, 0.15);  // Gris claro
  static Color get orangeMedium => darken(orange, 0.05);  // Gris medio
  static Color get orangeDark => darken(orange, 0.15);  // Gris oscuro
  static Color get orangeApple => lighten(orange, 0.08);  // Gris claro (legacy)
  
  // ============================================
  // 🌟 VARIACIONES DEL ORO METÁLICO (5 capas)
  // Sistema completo para diferentes intensidades
  // ============================================
  
  /// ACCESO DIRECTO A LAS 5 CAPAS DEL ORO METÁLICO
  
  /// CAPA 1: Brillo máximo - Reflejo especular más intenso
  /// Usar en: Puntos de luz, gloss effects, highlights
  static Color get goldLayer1 => goldHighlight;  // #FFF9E6
  
  /// CAPA 2: Reflejo claro - Transición luminosa brillante
  /// Usar en: Áreas iluminadas, transiciones de luz
  static Color get goldLayer2 => goldBright;  // #FFE55C
  
  /// CAPA 3: Oro base - Tono principal equilibrado
  /// Usar en: Color sólido principal, sin gradiente
  static Color get goldLayer3 => goldBase;  // #D4AF37 (el gold original)
  
  /// CAPA 4: Sombra cálida - Oro oscuro profundo
  /// Usar en: Bordes, sombras internas, profundidad
  static Color get goldLayer4 => goldShadow;  // #AA8C3A
  
  /// CAPA 5: Contraste estructural - Bronce oscuro
  /// Usar en: Bordes definitivos, estructura, contraste máximo
  static Color get goldLayer5 => goldDeep;  // #6E4B18
  
  /// VARIACIONES DE INTENSIDAD (ajustes rápidos)
  
  /// Oro ultra claro (para fondos sutiles)
  static Color get goldLightest => goldHighlight;  // #FFF9E6
  
  /// Oro muy claro (para hover states suaves)
  static Color get goldLighter => goldBright;  // #FFE55C
  
  /// Oro claro (transición entre brillante y base)
  static Color get goldLight => lighten(goldBase, 0.12);  // #D4AF37 más claro
  
  /// Oro oscuro (para sombras y profundidad)
  static Color get goldDark => goldShadow;  // #AA8C3A
  
  /// Oro muy oscuro (para contraste fuerte)
  static Color get goldDarker => goldDeep;  // #6E4B18
  
  /// Oro ultra oscuro (para bordes extremos)
  static Color get goldDarkest => darken(goldDeep, 0.15);  // Aún más oscuro que #6E4B18
  
  // Variaciones de PLATA (grises metálicos)
  static Color get silver => grey400;  // Gris medio metalizado
  static Color get silverLight => grey300;  // Gris claro metalizado
  
  // Variaciones de AZUL EMPRESA
  static Color get companyBlueDark => darken(companyBlue, 0.2);
  static Color get companyBlueDarker => darken(companyBlue, 0.3);
  static Color get companyBlueLight => lighten(companyBlue, 0.2);
  static Color get companyBlueLighter => lighten(companyBlue, 0.3);
  static Color get companyBlueLightest => lighten(companyBlue, 0.4);
  
  // Variaciones de SUCCESS
  static Color get successDark => darken(success, 0.1);
  static Color get successLight => lighten(success, 0.2);
  static Color get successLighter => lighten(success, 0.3);
  
  // COLORES LEGACY (mantenidos para compatibilidad pero desaconsejados)
  /// ⚠️ DEPRECATED: No usar en código nuevo
  static Color get wood => grey700;  // Redirigido a gris oscuro
  static Color get copperDark => grey600;  // Redirigido a gris medio oscuro
  static Color get bronzeDark => darken(gold, 0.25);  // Oro muy oscuro
  static Color get charcoal => textPrimary;  // Negro puro

  // ============================================
  // 🎨 ALIASES SEMÁNTICOS v2.0 (Blanco + Gris + Oro)
  // ============================================
  
  // HOME (fondo blanco perla con gradiente suave)
  static Color get homeBackground => background;  // Blanco puro
  static Color get homeAccent => gold;  // ⭐ Acento oro (no naranja)
  static LinearGradient get homeGradient => greySoftGradient;  // Gradiente blanco perla suave
  
  // CTAs Y BOTONES (sistema centralizado)
  static Color get ctaPrimary => gold;  // ⭐ Botón principal = ORO
  static Color get ctaPrimaryText => textPrimary;  // Texto negro sobre oro (alto contraste)
  static Color get ctaSecondary => grey100;  // Botón secundario = blanco perla cálido
  static Color get ctaSecondaryText => textPrimary;  // Texto negro
  
  // PRODUCTOS (oro premium)
  static Color get productPrimary => gold;  // ⭐ Oro para productos
  static Color get productBackground => background;  // Fondo blanco
  static LinearGradient get productGradient => goldGradient;  // Gradiente oro
  
  // SERVICIOS (azul corporativo mantiene identidad)
  static Color get servicePrimary => companyBlue;  // Azul empresa
  static Color get serviceBackground => background;  // Fondo blanco
  
  // GRUPOS (success mantiene semántica)
  static Color get groupPrimary => success;  // Verde
  static Color get groupBackground => background;  // Fondo blanco
  
  // POSTS (oro para destacar)
  static Color get postPrimary => gold;  // ⭐ Oro
  
  // MENSAJERÍA (burbujas neutras)
  static Color get messagePrimary => gold;  // ⭐ Acento oro en headers
  static Color get messageBubbleUser => grey100;  // Burbuja propia blanco perla cálido
  static Color get messageBubbleOther => grey200;  // Burbuja ajena blanco perla medio
  
  // PERFIL (badges premium)
  static Color get profileBadgeGold => gold;  // ⭐ Badge oro
  static Color get profileBadgeSilver => silver;  // Badge plata (gris metalizado)
  static Color get profileBadgeBronze => darken(gold, 0.3);  // Badge bronce (oro oscuro)
  
  // EMPRESA (azul mantiene identidad corporativa)
  static Color get companyPrimary => companyBlue;  // Azul empresa
  static Color get companySecondary => companyBlue;  // Azul empresa
  static LinearGradient get companyHeaderGradient => companyGradient;  // Gradiente azul
  
  // EMPLEADOS (azul corporativo)
  static Color get employeePrimary => companyBlue;  // Azul empresa
  
  // MÉTRICAS (semántica de colores)
  static Color get metricsIncome => success;  // Verde = ingresos
  static Color get metricsExpense => error;  // Rojo = gastos
  static Color get metricsPlanning => warning;  // Ámbar = planificación
  static Color get metricsInProgress => companyBlue;  // Azul = en progreso
  static Color get metricsCompleted => success;  // Verde = completado
  
  // NOTIFICACIONES (oro para destacar)
  static Color get notificationBadge => error;  // Rojo para badge de notificaciones nuevas
  static Color get notificationUnread => gold;  // ⭐ Oro para notificaciones no leídas
  
  // FAVORITOS (oro activo)
  static Color get favoriteActive => gold;  // ⭐ Favorito activo = oro
  static Color get favoriteInactive => fade(textSecondary, 0.3);  // Inactivo = gris muy claro
  
  // MENÚ RADIAL (oro para botón principal)
  static Color get radialButton => gold;  // ⭐ Botón radial = oro
  static LinearGradient get radialButtonGradient => goldGradient;  // Gradiente oro
  
  // ESTADOS GENERALES
  static Color get stateSuccess => success;  // Verde
  static Color get stateError => error;  // Rojo
  static Color get stateWarning => warning;  // Ámbar suave
  
  // BADGES GENERALES
  static Color get badgeGold => gold;  // ⭐ Badge premium

  // DARK MODE (placeholder para implementación futura)
  /// 🌙 Modo oscuro: fondos oscuros, texto claro, oro mantiene identidad
  static Color get darkBackground => const Color(0xFF111111);  // Negro profundo
  static Color get darkSurface => const Color(0xFF1A1A1A);  // Gris muy oscuro
  static Color get darkTextPrimary => const Color(0xFFF2F2F2);  // Blanco cálido
  static Color get darkTextSecondary => const Color(0xFFB8B8B8);  // Gris claro

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
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

// ============================================
// 🎨 EXTENSIÓN DE CONTEXT v2.0 (acceso rápido)
// ============================================

extension AppColorsContext on BuildContext {
  // Los 10 colores base redefinidos
  Color get colorOrange => AppColorsUnified.orange;  // LEGACY: ahora gris neutro
  Color get colorGold => AppColorsUnified.gold;  // ⭐ El oro metálico base
  Color get colorBackground => AppColorsUnified.background;  // Blanco puro
  Color get colorSurface => AppColorsUnified.surface;  // Blanco puro
  Color get colorTextPrimary => AppColorsUnified.textPrimary;  // Negro puro
  Color get colorTextSecondary => AppColorsUnified.textSecondary;  // Gris 60%
  Color get colorSuccess => AppColorsUnified.success;  // Verde
  Color get colorError => AppColorsUnified.error;  // Rojo
  Color get colorWarning => AppColorsUnified.warning;  // Ámbar suave
  Color get colorCompanyBlue => AppColorsUnified.companyBlue;  // Azul empresa
  
  // 🌟 LAS 5 CAPAS DEL ORO METÁLICO (acceso directo)
  Color get goldHighlight => AppColorsUnified.goldHighlight;     // CAPA 1: #FFF9E6
  Color get goldBright => AppColorsUnified.goldBright;           // CAPA 2: #FFE55C
  Color get goldBase => AppColorsUnified.goldBase;               // CAPA 3: #D4AF37
  Color get goldShadow => AppColorsUnified.goldShadow;           // CAPA 4: #AA8C3A
  Color get goldDeep => AppColorsUnified.goldDeep;               // CAPA 5: #6E4B18
  
  // Gradientes del nuevo sistema
  LinearGradient get gradientGreySoft => AppColorsUnified.greySoftGradient;  // Gris sutil
  LinearGradient get gradientGreySection => AppColorsUnified.greySectionGradient;  // Gris sección
  
  // 🌟 GRADIENTES DE ORO METÁLICO (4 variantes)
  LinearGradient get gradientGold => AppColorsUnified.goldGradient;  // ⭐ Oro completo 5 capas
  RadialGradient get gradientGoldRadial => AppColorsUnified.goldRadialGradient;  // Oro radial (botones redondos)
  LinearGradient get gradientGoldSubtle => AppColorsUnified.goldSubtleGradient;  // Oro sutil (fondos)
  LinearGradient get gradientGoldShimmer => AppColorsUnified.goldShimmerGradient;  // Oro shimmer (animaciones)
  
  // Legacy
  LinearGradient get gradientOrange => AppColorsUnified.orangeGradient;  // LEGACY: gris
  LinearGradient get gradientCompany => AppColorsUnified.companyGradient;  // Azul empresa
  
  // CTAs y botones
  Color get colorCtaPrimary => AppColorsUnified.ctaPrimary;  // ⭐ Oro
  Color get colorCtaPrimaryText => AppColorsUnified.ctaPrimaryText;  // Negro
  Color get colorCtaSecondary => AppColorsUnified.ctaSecondary;  // Gris claro
  Color get colorCtaSecondaryText => AppColorsUnified.ctaSecondaryText;  // Negro
  
  // Módulos (acceso semántico)
  Color get colorProduct => AppColorsUnified.productPrimary;  // ⭐ Oro
  Color get colorService => AppColorsUnified.servicePrimary;  // Azul
  Color get colorGroup => AppColorsUnified.groupPrimary;  // Verde
  Color get colorMessage => AppColorsUnified.messagePrimary;  // ⭐ Oro
  Color get colorCompany => AppColorsUnified.companyPrimary;  // Azul
  
  // Home
  LinearGradient get gradientHome => AppColorsUnified.homeGradient;  // Gris sutil
}
