import 'package:flutter/material.dart';

/// 🏆 PALETA DE COLORES PREMIUM VIBRANTE - YOMINERO
/// Colores saturados, gradientes intensos, look premium moderno
class DashboardColors {
  DashboardColors._();

  // ============================================
  // ORO BRILLANTE - Color Principal
  // ============================================
  
  static const Color gold = Color(0xFFFFB800);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldDark = Color(0xFFD4A017);
  static const Color goldMetallic = Color(0xFFFFC947);
  static const Color goldAntique = Color(0xFFB8860B);
  static const Color goldShadow = Color(0x50FFB800);

  // ============================================
  // GRADIENTES DE ORO INTENSOS
  // ============================================
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD54F), Color(0xFFFFB800), Color(0xFFD4A017)],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient goldShine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBE6),
      Color(0xFFFFD54F),
      Color(0xFFFFB800),
      Color(0xFFFF9500),
      Color(0xFFD4A017),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  // ============================================
  // PALETA DE SOPORTE VIBRANTE
  // ============================================
  
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color silver = Color(0xFFE8E8E8);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color minerBlue = Color(0xFF2196F3);
  static const Color emerald = Color(0xFF00D084);
  static const Color emeraldLight = Color(0xFF4ADE80);
  
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
  // ALIAS PARA COMPATIBILIDAD
  // ============================================
  
  /// Color primario principal (alias de gold)
  static const Color primary = gold;
  
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
}
