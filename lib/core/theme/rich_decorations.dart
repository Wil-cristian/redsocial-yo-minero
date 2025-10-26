import 'package:flutter/material.dart';
import 'dashboard_colors.dart';

/// 🎨 DECORACIONES RICAS CON MÚLTIPLES CAPAS
/// Inspirado en diseños premium con texturas, sombras y bordes complejos
class RichDecorations {
  RichDecorations._();

  // ============================================
  // 🥇 DECORACIONES CON ESQUEMA NARANJA-ORO-MADERA
  // ============================================
  
  /// Card premium con borde doble, sombra interior y exterior
  static BoxDecoration goldCardRich({bool isElevated = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DashboardColors.primaryLight.withOpacity(0.3), // Highlight
          DashboardColors.primaryLight, // Naranja glow
          DashboardColors.accent, // Dorado
          DashboardColors.primaryDark, // Naranja oscuro
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 3,
        color: DashboardColors.accentLight, // Borde dorado brillante
      ),
      boxShadow: [
        // Sombra exterior profunda
        BoxShadow(
          color: DashboardColors.primaryDark.withOpacity(0.4),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        // Sombra exterior suave
        BoxShadow(
          color: DashboardColors.primary.withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        // Highlight superior (brillo)
        if (isElevated)
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            offset: const Offset(0, -2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
      ],
    );
  }

  /// Card de oro con textura metálica (múltiples gradientes superpuestos)
  static BoxDecoration goldCardTextured() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 2,
        color: const Color(0xFFFFE680),
      ),
      boxShadow: [
        // Sombra profunda
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: -5,
        ),
        // Sombra media
        BoxShadow(
          color: DashboardColors.primaryDark.withOpacity(0.3),
          offset: const Offset(0, 6),
          blurRadius: 12,
          spreadRadius: 0,
        ),
        // Brillo superior
        BoxShadow(
          color: DashboardColors.primaryLight.withOpacity(0.5),
          offset: const Offset(0, -1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.9), // Casi blanco
          DashboardColors.accentLight, // Dorado claro
          DashboardColors.primaryLight, // Naranja glow
          DashboardColors.accent, // Dorado
          DashboardColors.primary, // Naranja
          DashboardColors.primaryDark, // Naranja oscuro
        ],
        stops: [0.0, 0.15, 0.35, 0.55, 0.75, 1.0],
      ),
    );
  }

  /// Botón premium con efecto 3D (naranja-oro)
  static BoxDecoration goldButton3D({bool isPressed = false}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isPressed
            ? [
                DashboardColors.primaryDark,
                DashboardColors.accent,
                DashboardColors.accentLight,
              ]
            : [
                DashboardColors.accentLight,
                DashboardColors.accent,
                DashboardColors.primaryDark,
              ],
      ),
      border: Border.all(
        width: 2,
        color: isPressed
            ? DashboardColors.woodDark
            : Colors.white.withOpacity(0.9),
      ),
      boxShadow: isPressed
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ]
          : [
              // Sombra profunda
              BoxShadow(
                color: DashboardColors.primaryDark.withOpacity(0.5),
                offset: const Offset(0, 6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              // Sombra media
              BoxShadow(
                color: DashboardColors.primary.withOpacity(0.3),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
              // Highlight
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ],
    );
  }

  // ============================================
  // 💎 DECORACIONES DE ESMERALDA
  // ============================================
  
  static BoxDecoration emeraldCardRich() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFD1FAE5), // Verde muy claro
          Color(0xFF6EE7B7), // Verde claro
          Color(0xFF10B981), // Esmeralda
          Color(0xFF059669), // Verde oscuro
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 3,
        color: const Color(0xFF6EE7B7),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF059669).withOpacity(0.4),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF10B981).withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.4),
          offset: const Offset(0, -2),
          blurRadius: 4,
        ),
      ],
    );
  }

  // ============================================
  // 🔷 DECORACIONES DE ZAFIRO (AZUL)
  // ============================================
  
  static BoxDecoration sapphireCardRich() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFDBEAFE), // Azul muy claro
          Color(0xFF93C5FD), // Azul claro
          Color(0xFF3B82F6), // Azul brillante
          Color(0xFF2563EB), // Azul oscuro
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 3,
        color: const Color(0xFF93C5FD),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2563EB).withOpacity(0.4),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.4),
          offset: const Offset(0, -2),
          blurRadius: 4,
        ),
      ],
    );
  }

  // ============================================
  // 🟣 DECORACIONES DE AMATISTA (MORADO)
  // ============================================
  
  static BoxDecoration amethystCardRich() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF3EBFF), // Morado muy claro
          Color(0xFFDDD6FE), // Morado claro
          Color(0xFF9F7AEA), // Morado medio
          Color(0xFF7C3AED), // Morado oscuro
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 3,
        color: const Color(0xFFDDD6FE),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7C3AED).withOpacity(0.4),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF9F7AEA).withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.4),
          offset: const Offset(0, -2),
          blurRadius: 4,
        ),
      ],
    );
  }

  // ============================================
  // 🧡 DECORACIONES DE ÁMBAR (NARANJA)
  // ============================================
  
  static BoxDecoration amberCardRich() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF7ED), // Naranja muy claro
          Color(0xFFFED7AA), // Naranja claro
          Color(0xFFFB923C), // Naranja brillante
          Color(0xFFEA580C), // Naranja oscuro
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 3,
        color: const Color(0xFFFED7AA),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFEA580C).withOpacity(0.4),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFFFB923C).withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.4),
          offset: const Offset(0, -2),
          blurRadius: 4,
        ),
      ],
    );
  }

  // ============================================
  // 🎯 DECORACIONES CON BORDE DOBLE
  // ============================================
  
  /// Card con borde doble (inner + outer)
  static Widget doubleBorderCard({
    required Widget child,
    required Color outerColor,
    required Color innerColor,
    required Gradient gradient,
    double borderRadius = 16,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: outerColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3), // Grosor del borde exterior
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: innerColor,
          ),
          borderRadius: BorderRadius.circular(borderRadius - 3),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ============================================
  // ✨ DECORACIONES CON BRILLO INTERIOR
  // ============================================
  
  /// Card con brillo interior (inner glow)
  static BoxDecoration glowingCard({
    required Color glowColor,
    required Gradient backgroundGradient,
  }) {
    return BoxDecoration(
      gradient: backgroundGradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 2,
        color: glowColor.withOpacity(0.6),
      ),
      boxShadow: [
        // Sombra exterior
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: -5,
        ),
        // Brillo exterior
        BoxShadow(
          color: glowColor.withOpacity(0.4),
          offset: const Offset(0, 0),
          blurRadius: 12,
          spreadRadius: 2,
        ),
        // Brillo superior
        BoxShadow(
          color: Colors.white.withOpacity(0.5),
          offset: const Offset(0, -2),
          blurRadius: 4,
        ),
      ],
    );
  }

  // ============================================
  // 🏗️ DECORACIONES CON TEXTURA DE RELIEVE
  // ============================================
  
  /// Card con efecto de relieve 3D
  static BoxDecoration embossedCard({
    required Color baseColor,
    required Color highlightColor,
    required Color shadowColor,
  }) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 1,
        color: highlightColor,
      ),
      boxShadow: [
        // Sombra inferior derecha (profundidad)
        BoxShadow(
          color: shadowColor.withOpacity(0.6),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        // Brillo superior izquierdo (relieve)
        BoxShadow(
          color: highlightColor.withOpacity(0.5),
          offset: const Offset(-2, -2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
        // Sombra exterior general
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ],
    );
  }

  // ============================================
  // 🎨 DECORACIONES ESPECÍFICAS POR TIPO DE POST
  // ============================================
  
  /// Producto - Oro con múltiples capas
  static BoxDecoration productCard() => goldCardTextured();
  
  /// Servicio - Morado amatista rico
  static BoxDecoration serviceCard() => amethystCardRich();
  
  /// Oferta - Verde esmeralda brillante
  static BoxDecoration offerCard() => emeraldCardRich();
  
  /// Pregunta - Naranja ámbar con textura
  static BoxDecoration questionCard() => amberCardRich();
  
  /// Noticia - Azul zafiro profundo
  static BoxDecoration newsCard() => sapphireCardRich();
  
  /// Encuesta - Turquesa con brillo
  static BoxDecoration pollCard() {
    return glowingCard(
      glowColor: const Color(0xFF14B8A6),
      backgroundGradient: const LinearGradient(
        colors: [
          Color(0xFFCCFBF1),
          Color(0xFF5EEAD4),
          Color(0xFF14B8A6),
          Color(0xFF0F766E),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  // ============================================
  // 🔘 DECORACIONES PARA BOTONES ESPECIALES
  // ============================================
  
  /// Botón flotante premium (naranja-oro)
  static BoxDecoration fabGold() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          DashboardColors.accentLight, // Centro brillante
          DashboardColors.primaryLight, // Medio brillante
          DashboardColors.accent, // Dorado
          DashboardColors.primaryDark, // Borde oscuro
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ),
      boxShadow: [
        // Sombra profunda
        BoxShadow(
          color: DashboardColors.primaryDark.withOpacity(0.6),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        // Sombra media
        BoxShadow(
          color: DashboardColors.primary.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
        // Brillo superior
        BoxShadow(
          color: Colors.white.withOpacity(0.5),
          offset: const Offset(0, -2),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Chip con borde y sombra
  static BoxDecoration chip({
    required Color color,
    bool isSelected = false,
  }) {
    return BoxDecoration(
      color: isSelected ? color : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        width: 2,
        color: isSelected ? color : color.withOpacity(0.3),
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ]
          : null,
    );
  }
}
