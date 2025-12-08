import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:yominero/core/theme/app_colors_unified.dart';

class RadialMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String route;

  RadialMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.route,
  });
}

class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
  final VoidCallback onClose;
  final Offset buttonPosition;

  const RadialMenu({
    super.key,
    required this.items,
    required this.onClose,
    required this.buttonPosition,
  });

  @override
  State<RadialMenu> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late List<AnimationController> _itemControllers;

  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20), // Rotación ultra suave
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500), // Pulso más lento
      vsync: this,
    )..repeat(reverse: true);

    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleItemTap(int index) async {
    for (int i = 0; i < _itemControllers.length; i++) {
      if (i == index) {
        await _itemControllers[i].forward();
        await _itemControllers[i].reverse();
      }
    }

    await _expandController.reverse();
    widget.items[index].onTap();
    widget.onClose();
  }

  void _handleClose() async {
    await _expandController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = widget.buttonPosition;
    
    // Calcular radio máximo que no se salga de la pantalla
    // Los items tienen 70px de tamaño, el centro del item está en el radio
    // entonces necesitamos itemSize/2 (35px) de espacio desde el centro del item hasta su borde
    const itemSize = 70.0;
    const halfItemSize = itemSize / 2; // 35px
    const safeMargin = 10.0; // Margen extra de seguridad
    
    final maxRadiusRight = size.width - center.dx - halfItemSize - safeMargin;
    final maxRadiusLeft = center.dx - halfItemSize - safeMargin;
    final maxRadiusTop = center.dy - halfItemSize - safeMargin;
    final maxRadiusBottom = size.height - center.dy - halfItemSize - safeMargin - 90; // 90px margen para navbar
    
    // Calcular espacio horizontal disponible (determina si usamos círculo o arco)
    final horizontalRadius = math.min(maxRadiusRight, maxRadiusLeft);
    
    // FALLBACK: Si el espacio horizontal es insuficiente (<50px), usar arco superior
    // Esto asegura que desktop/tablet con amplio espacio horizontal use círculo completo
    final useFallbackLayout = horizontalRadius < 50.0;
    
    // Calcular radio según el modo (círculo vs arco)
    final double radius;
    
    if (useFallbackLayout) {
      // FALLBACK (arco superior): Solo considerar espacio horizontal y superior
      final fallbackRadius = math.max(0.0, math.min(
        math.min(maxRadiusRight, maxRadiusLeft),  // Límites horizontales
        maxRadiusTop                               // Solo límite superior
      ));
      radius = fallbackRadius;
    } else {
      // CÍRCULO COMPLETO: Considerar espacio horizontal y vertical disponibles
      // Para el sector inferior, usar maxRadiusBottom solo si es positivo
      // Si es negativo, limitar con otro criterio
      final bottomLimit = maxRadiusBottom > 0 ? maxRadiusBottom : maxRadiusTop;
      final calculatedRadius = math.min(
        math.min(maxRadiusRight, maxRadiusLeft),  // Límites horizontales
        math.min(maxRadiusTop, bottomLimit)        // Límites verticales
      );
      radius = math.min(180.0, math.max(0.0, calculatedRadius));
    }
    
    // Escala de items adaptativa
    final itemScale = useFallbackLayout 
        ? (radius < 20 ? 0.4 : 0.65)  // Super compacto si radius muy pequeño
        : (radius / 80.0).clamp(0.6, 1.0);

    return Stack(
      children: [
        // Overlay oscuro con animación (no cubre la navbar inferior)
        AnimatedBuilder(
          animation: _expandController,
          builder: (context, child) {
            return Positioned.fill(
              bottom: 80, // Dejar espacio para la navbar inferior
              child: GestureDetector(
                onTap: _handleClose,
                child: Container(
                  color: Colors.black.withOpacity((0.7 * _expandController.value).clamp(0.0, 1.0)),
                ),
              ),
            );
          },
        ),

        // Círculos de fondo animados
        AnimatedBuilder(
          animation: Listenable.merge([_expandController, _rotateController]),
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _RadialBackgroundPainter(
                center: center,
                radius: radius * _expandController.value,
                animation: _rotateController.value,
              ),
            );
          },
        ),

        // Botón central con efecto de pulso dorado
        AnimatedBuilder(
          animation: Listenable.merge([_expandController, _pulseController]),
          builder: (context, child) {
            final scale = 1.0 + (0.05 * _pulseController.value); // Respiración sutil
            final glowOpacity = (0.35 + (0.15 * _pulseController.value)).clamp(0.0, 1.0);
            
            return Positioned(
              left: center.dx - 36,
              top: center.dy - 36,
              child: GestureDetector(
                onTap: _handleClose,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColorsUnified.goldRadialGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColorsUnified.gold.withOpacity(glowOpacity),
                          blurRadius: 28,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Transform.rotate(
                        angle: _expandController.value * math.pi / 4,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColorsUnified.goldLayer5,
                          size: 34,
                          shadows: [
                            Shadow(
                              color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.6),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Items del menú en círculo o semicírculo (fallback)
        ...List.generate(widget.items.length, (index) {
          // Layout adaptativo: semicírculo superior si no hay espacio
          // Fallback: de -5π/6 a -π/6 (semicírculo superior evitando bordes laterales)
          final angleStep = useFallbackLayout
              ? (2 * math.pi / 3) / math.max(1, widget.items.length - 1)  // Arco de 120°
              : (2 * math.pi / widget.items.length);                       // Círculo completo
          final startAngle = useFallbackLayout ? -5 * math.pi / 6 : -math.pi / 2;
          final angle = startAngle + (angleStep * index);
          
          final item = widget.items[index];

          return AnimatedBuilder(
            animation: Listenable.merge([
              _expandController,
              _itemControllers[index],
              _pulseController,
            ]),
            builder: (context, child) {
              final distance = radius * _expandController.value;
              final x = center.dx + distance * math.cos(angle);
              final y = center.dy + distance * math.sin(angle);

              // Item size escalado según el radio disponible
              final scaledItemSize = 70.0 * itemScale;
              final halfScaledSize = scaledItemSize / 2;

              final pressScale = 1.0 + (_itemControllers[index].value * 0.3);
              final isHovered = _hoveredIndex == index;
              final hoverScale = isHovered ? 1.15 : 1.0;

              return Positioned(
                left: x - halfScaledSize,
                top: y - halfScaledSize,
                child: Transform.scale(
                  scale: _expandController.value * pressScale * hoverScale,
                  child: Opacity(
                    opacity: _expandController.value,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: GestureDetector(
                        onTap: () => _handleItemTap(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32), // Píldora redondeada
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorsUnified.pureWhite,
                                AppColorsUnified.grey50,
                              ],
                            ),
                            border: Border.all(
                              color: isHovered 
                                  ? AppColorsUnified.gold
                                  : AppColorsUnified.grey200,
                              width: isHovered ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isHovered
                                    ? AppColorsUnified.gold.withOpacity(0.25)
                                    : AppColorsUnified.shadowMedium,
                                blurRadius: isHovered ? 20 : 12,
                                spreadRadius: isHovered ? 2 : 0,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: AppColorsUnified.shadowLight,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono con contenedor circular elegante
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      item.color.withOpacity(0.15),
                                      item.color.withOpacity(0.08),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: item.color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Etiqueta siempre visible
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: isHovered 
                                      ? AppColorsUnified.textPrimary
                                      : AppColorsUnified.textSecondary,
                                  fontSize: 14,
                                  fontWeight: isHovered 
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _RadialBackgroundPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double animation;

  _RadialBackgroundPainter({
    required this.center,
    required this.radius,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Círculos concéntricos animados con oro sutil
    final paint1 = Paint()
      ..color = AppColorsUnified.gold.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint2 = Paint()
      ..color = AppColorsUnified.goldBright.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint3 = Paint()
      ..color = AppColorsUnified.grey300.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Dibujar círculos con rotación
    final offset = animation * 20;
    canvas.drawCircle(center, radius * 0.3 + offset, paint1);
    canvas.drawCircle(center, radius * 0.6 - offset, paint2);
    canvas.drawCircle(center, radius * 0.9 + offset / 2, paint3);

    // Líneas radiales
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (2 * math.pi / 12) * i + (animation * 2 * math.pi);
      final start = Offset(
        center.dx + (radius * 0.2) * math.cos(angle),
        center.dy + (radius * 0.2) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(_RadialBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.radius != radius ||
        oldDelegate.center != center;
  }
}
