import 'package:flutter/material.dart';
import 'dart:ui';

/// 💎 COLORES METÁLICOS REALISTAS
/// Inspirados en piedras preciosas y metales reales
/// Usa gradientes multicapa para simular brillo y profundidad
class MetallicColors {
  MetallicColors._();

  // ============================================
  // 🥇 ORO BRILLANTE - Como oro real 24K
  // ============================================
  
  /// Gradiente de oro con brillo realista (5 capas)
  static const LinearGradient goldShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFAF0), // Highlight blanco dorado
      Color(0xFFFFE55C), // Oro brillante
      Color(0xFFFFD700), // Oro puro
      Color(0xFFFFB300), // Oro medio
      Color(0xFFCC9900), // Oro oscuro (sombra)
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Gradiente de oro con efecto metálico
  static const LinearGradient goldMetallic = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE873), // Top highlight
      Color(0xFFFFD700), // Oro medio
      Color(0xFFD4AF37), // Oro antiguo
      Color(0xFFAA8C3A), // Base oscura
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );
  
  /// Oro con reflejo diagonal (para botones)
  static const LinearGradient goldButton = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [
      Color(0xFFFFF9E6), // Reflejo brillante
      Color(0xFFFFE55C),
      Color(0xFFFFD700),
      Color(0xFFFFB300),
      Color(0xFFD4AF37),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  // ============================================
  // 💎 ESMERALDA - Verde piedra preciosa
  // ============================================
  
  /// Gradiente esmeralda brillante (como la foto)
  static const LinearGradient emeraldShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6EE7B7), // Highlight claro
      Color(0xFF34D399), // Verde brillante
      Color(0xFF10B981), // Esmeralda puro
      Color(0xFF059669), // Verde profundo
      Color(0xFF047857), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  /// Esmeralda con brillo cristalino
  static const LinearGradient emeraldCrystal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFA7F3D0), // Brillo superior
      Color(0xFF6EE7B7),
      Color(0xFF34D399),
      Color(0xFF10B981),
      Color(0xFF065F46), // Base oscura
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  // ============================================
  // 🪙 PLATINO/PLATA - Metal brillante
  // ============================================
  
  /// Gradiente de platino realista
  static const LinearGradient platinumShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF), // Highlight puro
      Color(0xFFF5F5F5),
      Color(0xFFE8E8E8), // Plata brillante
      Color(0xFFC0C0C0), // Plata media
      Color(0xFF9E9E9E), // Sombra
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );
  
  /// Plata metálica con reflejo
  static const LinearGradient silverMetallic = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFAFA), // Top shine
      Color(0xFFE8E8E8),
      Color(0xFFC0C0C0),
      Color(0xFFA8A8A8),
      Color(0xFF7C7C7C), // Base oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 🟤 BRONCE - Metal cálido
  // ============================================
  
  /// Gradiente de bronce pulido
  static const LinearGradient bronzeShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4C584), // Highlight dorado
      Color(0xFFE5A66D), // Bronce claro
      Color(0xFFCD7F32), // Bronce puro
      Color(0xFFB87333), // Bronce medio
      Color(0xFF8B5A2B), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 🔷 ZAFIRO - Azul piedra preciosa
  // ============================================
  
  /// Gradiente zafiro brillante
  static const LinearGradient sapphireShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF93C5FD), // Highlight azul claro
      Color(0xFF60A5FA), // Azul brillante
      Color(0xFF3B82F6), // Zafiro puro
      Color(0xFF2563EB), // Azul profundo
      Color(0xFF1E40AF), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 🔮 AMATISTA - Púrpura cristalino
  // ============================================
  
  /// Gradiente amatista brillante
  static const LinearGradient amethystShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE9D5FF), // Highlight lavanda
      Color(0xFFC084FC), // Púrpura claro
      Color(0xFF9333EA), // Amatista puro
      Color(0xFF7C3AED), // Púrpura profundo
      Color(0xFF6B21A8), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 🍊 ÁMBAR - Naranja cálido
  // ============================================
  
  /// Gradiente ámbar brillante
  static const LinearGradient amberShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFEF3C7), // Highlight amarillo
      Color(0xFFFDE68A), // Ámbar claro
      Color(0xFFFBBF24), // Ámbar puro
      Color(0xFFF59E0B), // Naranja medio
      Color(0xFFD97706), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 💗 RUBÍ - Rojo piedra preciosa
  // ============================================
  
  /// Gradiente rubí brillante
  static const LinearGradient rubyShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDA4AF), // Highlight rosa
      Color(0xFFF87171), // Rojo brillante
      Color(0xFFEF4444), // Rubí puro
      Color(0xFFDC2626), // Rojo profundo
      Color(0xFFB91C1C), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 🌊 AGUAMARINA - Azul turquesa
  // ============================================
  
  /// Gradiente aguamarina brillante
  static const LinearGradient aquamarineShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCCFBF1), // Highlight claro
      Color(0xFF5EEAD4), // Turquesa brillante
      Color(0xFF2DD4BF), // Aguamarina puro
      Color(0xFF14B8A6), // Turquesa profundo
      Color(0xFF0D9488), // Sombra oscura
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================
  // 🎨 GRADIENTES RADIALES (para efectos circulares)
  // ============================================
  
  /// Oro radial (para FABs, avatares)
  static const RadialGradient goldRadial = RadialGradient(
    center: Alignment(0.3, -0.5), // Offset para simular luz
    radius: 1.5,
    colors: [
      Color(0xFFFFFAF0), // Centro brillante
      Color(0xFFFFE55C),
      Color(0xFFFFD700),
      Color(0xFFCC9900),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Esmeralda radial
  static const RadialGradient emeraldRadial = RadialGradient(
    center: Alignment(0.3, -0.5),
    radius: 1.5,
    colors: [
      Color(0xFFA7F3D0),
      Color(0xFF34D399),
      Color(0xFF10B981),
      Color(0xFF047857),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // ============================================
  // ✨ EFECTOS ESPECIALES
  // ============================================
  
  /// Shimmer dorado (para efectos de carga)
  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0x00FFD700), // Transparente
      Color(0x44FFE55C), // Semi-transparente brillante
      Color(0x88FFFAF0), // Brillante
      Color(0x44FFE55C), // Semi-transparente brillante
      Color(0x00FFD700), // Transparente
    ],
    stops: [0.0, 0.35, 0.5, 0.65, 1.0],
  );
  
  /// Overlay metálico suave (para hover effects)
  static const Color goldOverlay = Color(0x1AFFD700);
  static const Color emeraldOverlay = Color(0x1A10B981);
  static const Color silverOverlay = Color(0x1AC0C0C0);
}

/// 🎨 HELPER: Crear BoxDecoration con gradiente metálico
class MetallicDecoration {
  /// Caja con gradiente de oro brillante
  static BoxDecoration gold({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.goldShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFFFE55C).withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  /// Caja con gradiente de esmeralda brillante
  static BoxDecoration emerald({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.emeraldShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  /// Caja con gradiente de platino
  static BoxDecoration platinum({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.platinumShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  /// Caja con gradiente de zafiro
  static BoxDecoration sapphire({
    double borderRadius = 12,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: MetallicColors.sapphireShine,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
