import 'dart:ui';

/// Extensión SAFE para Color que previene painting.dart:116 assertions
extension SafeColorExtensions on Color {
  /// Versión SEGURA de withOpacity que GARANTIZA valores válidos
  Color safeWithOpacity(double opacity) {
    // Clampear opacity entre 0.0 y 1.0
    final safeOpacity = opacity.clamp(0.0, 1.0);
    
    // Convertir a alpha (0-255)
    final alphaValue = (safeOpacity * 255).round().clamp(0, 255);
    
    // Crear color con valores garantizados en rango
    return Color.fromARGB(
      alphaValue,
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
    );
  }
}
