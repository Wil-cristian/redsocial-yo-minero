import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/dashboard_colors.dart';
import '../../core/achievements/achievement_models.dart';
import '../../core/achievements/gem_color_helper.dart';

/// Widget animado que muestra cuando se desbloquea un logro
class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementUnlockedDialog> createState() => _AchievementUnlockedDialogState();

  static Future<void> show(BuildContext context, Achievement achievement) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AchievementUnlockedDialog(
        achievement: achievement,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _particlesController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación de escala (badge aparece)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    // Animación de rotación (badge gira)
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    // Animación de partículas
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Iniciar animaciones
    _scaleController.forward();
    _rotationController.repeat(reverse: true);
    _particlesController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = GemColorHelper.getGradientForTier(widget.achievement.gemTier);
    final color = GemColorHelper.getColorForTier(widget.achievement.gemTier);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Partículas de confetti
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 400),
                painter: _ConfettiPainter(
                  progress: _particlesController.value,
                  color: color,
                ),
              );
            },
          ),
          
          // Contenedor principal
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  const Text(
                    '🎉 ¡LOGRO DESBLOQUEADO! 🎉',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Badge animado
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            shape: BoxShape.circle,
                            boxShadow: GemColorHelper.getShadowsForTier(
                              widget.achievement.gemTier,
                              isGlowing: true,
                            ),
                          ),
                          child: Icon(
                            widget.achievement.icon,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Nombre del logro
                  Text(
                    widget.achievement.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Descripción
                  Text(
                    widget.achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Badge del tier
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          GemColorHelper.getIconForTier(widget.achievement.gemTier),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          UserLevel.getTierName(widget.achievement.gemTier),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón de cerrar
                  ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '¡Genial!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para el efecto de confetti
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ConfettiPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Seed fijo para consistencia
    
    for (int i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      const startY = -20.0;
      
      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = size.height + 20;
      
      final currentY = startY + (endY - startY) * progress;
      final currentX = startX + (endX - startX) * progress;
      
      final rotation = progress * math.pi * 4 + random.nextDouble() * math.pi;
      
      final paint = Paint()
        ..color = _getConfettiColor(i, color).withValues(alpha: 1.0 - progress * 0.3)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);
      
      // Dibujar rectángulo pequeño
      canvas.drawRect(
        const Rect.fromLTWH(-3, -6, 6, 12),
        paint,
      );
      
      canvas.restore();
    }
  }

  Color _getConfettiColor(int index, Color baseColor) {
    final colors = [
      baseColor,
      DashboardColors.primary,
      DashboardColors.emerald,
      DashboardColors.accent,
      AppColorsUnified.companyBlue,
      AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget compacto para mostrar logro desbloqueado (SnackBar style)
class AchievementToast extends StatelessWidget {
  final Achievement achievement;

  const AchievementToast({
    super.key,
    required this.achievement,
  });

  static void show(BuildContext context, Achievement achievement) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: AchievementToast(achievement: achievement),
      ),
    );
    
    overlay.insert(entry);
    
    // Auto-remover después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = GemColorHelper.getGradientForTier(achievement.gemTier);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * -50),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: GemColorHelper.getShadowsForTier(
            achievement.gemTier,
            isGlowing: true,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                achievement.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Logro desbloqueado!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.stars,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
