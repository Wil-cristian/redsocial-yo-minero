import 'package:flutter/material.dart';
import 'dart:ui';
import 'rich_decorations.dart';
import 'dashboard_colors.dart';

/// 🎨 PREMIUM WIDGETS LIBRARY
/// Sistema de widgets premium reutilizables con efectos brillantes
/// Uso simple: PremiumWidgets.productCard(), PremiumWidgets.goldButton(), etc.

class PremiumWidgets {
  PremiumWidgets._();

  // ============================================
  // 🏆 CARDS PREMIUM POR TIPO
  // ============================================

  /// Card para productos (tema dorado)
  static Widget productCard({required Widget child}) {
    return RichDecorations.doubleBorderCard(
      child: child,
      outerColor: DashboardColors.gold,
      innerColor: const Color(0xFFFFFFFF),
      gradient: LinearGradient(
        colors: [
          DashboardColors.white,
          const Color(0xFFFFFBF0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Card para servicios (tema morado)
  static Widget serviceCard({required Widget child}) {
    return RichDecorations.doubleBorderCard(
      child: child,
      outerColor: DashboardColors.cardPurple,
      innerColor: const Color(0xFFF5F3FF),
      gradient: LinearGradient(
        colors: [
          DashboardColors.white,
          const Color(0xFFF9F5FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Card para ofertas (tema verde esmeralda)
  static Widget offerCard({required Widget child}) {
    return RichDecorations.doubleBorderCard(
      child: child,
      outerColor: DashboardColors.emerald,
      innerColor: const Color(0xFFECFDF5),
      gradient: LinearGradient(
        colors: [
          DashboardColors.white,
          const Color(0xFFF0FDF4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // ============================================
  // 🏷️ BADGES Y ETIQUETAS
  // ============================================

  /// Badge premium con icono y gradiente
  static Widget premiumBadge({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de condición (Nuevo/Usado)
  static Widget conditionBadge({required String condition}) {
    final isNew = condition.toLowerCase() == 'nuevo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFF10B981) : const Color(0xFF6B7280),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: (isNew ? const Color(0xFF10B981) : const Color(0xFF6B7280)).withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        condition.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Badge de stock
  static Widget stockBadge({required int stock}) {
    final hasStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasStock ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: (hasStock ? const Color(0xFF3B82F6) : const Color(0xFFEF4444)).withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasStock ? Icons.inventory_2 : Icons.error_outline,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            hasStock ? 'Stock: $stock' : 'Agotado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 💰 CONTENEDOR DE PRECIO
  // ============================================

  /// Contenedor de precio con gradiente dorado
  static Widget priceContainer({
    required String price,
    required String currency,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB800),
            Color(0xFFFFD54F),
            Color(0xFFD4A017),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FFD54F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x33D4A017),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$currency $price',
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ============================================
  // 🔘 BOTONES PREMIUM
  // ============================================

  /// Botón dorado con efecto 3D
  static Widget goldButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DashboardColors.gold,
        foregroundColor: DashboardColors.charcoal,
        elevation: 8,
        shadowColor: DashboardColors.gold.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón con borde (outline)
  static Widget outlineButton({
    required String label,
    required VoidCallback onPressed,
    Color color = const Color(0xFFFFB800),
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón circular con icono
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = const Color(0xFFFFB800),
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  // ============================================
  // ✨ EFECTOS BRILLANTES ANIMADOS
  // ============================================

  /// Efecto de brillo animado (shimmer)
  static Widget shimmerEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return _ShimmerWidget(duration: duration, child: child);
  }

  /// Efecto de pulso en el borde
  static Widget pulsingBorder({
    required Widget child,
    Color color = const Color(0xFFFFD54F),
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _PulsingBorderWidget(color: color, duration: duration, child: child);
  }

  /// Efecto de vidrio (glassmorphism)
  static Widget glassEffect({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Brillo superior (top shine overlay)
  static Widget topShine({required Widget child}) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // 🎯 COMBINACIONES PRE-HECHAS
  // ============================================

  /// Card de producto ULTRA PREMIUM - Con todos los efectos
  static Widget ultraPremiumProductCard({
    required Widget child,
  }) {
    return shimmerEffect(
      child: pulsingBorder(
        color: const Color(0xFFFFD54F),
        child: topShine(
          child: productCard(child: child),
        ),
      ),
    );
  }

  /// Card de oferta con efecto de urgencia (pulso rojo/verde)
  static Widget urgentOfferCard({
    required Widget child,
    bool isUrgent = false,
  }) {
    return pulsingBorder(
      color: isUrgent ? const Color(0xFFFF6B00) : const Color(0xFF10B981),
      duration: isUrgent
          ? const Duration(milliseconds: 800)
          : const Duration(milliseconds: 1500),
      child: offerCard(child: child),
    );
  }
}

// ============================================
// 🎭 WIDGETS ANIMADOS INTERNOS
// ============================================

/// Widget interno para efecto shimmer con animación infinita
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _ShimmerWidget({required this.child, required this.duration});

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Transform.translate(
                  offset: Offset((_controller.value * 4 - 2) * 200, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget interno para borde pulsante con animación infinita
class _PulsingBorderWidget extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;

  const _PulsingBorderWidget({
    required this.child,
    required this.color,
    required this.duration,
  });

  @override
  State<_PulsingBorderWidget> createState() => _PulsingBorderWidgetState();
}

class _PulsingBorderWidgetState extends State<_PulsingBorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.6),
                blurRadius: 12 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
