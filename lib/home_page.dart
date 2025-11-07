import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'core/theme/dashboard_colors.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const HomePage({super.key, this.currentUser});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final accountType = (widget.currentUser?['accountType'] as String?) ?? 'individual';
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DashboardColors.gray50,
              DashboardColors.white,
              DashboardColors.primaryLight.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Header ÉPICO con animaciones
            SliverToBoxAdapter(
              child: _buildEpicHeader(),
            ),
            
            // Estadísticas animadas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildAnimatedStats(),
              ),
            ),
            
            // Sección de acceso rápido compacta
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Acceso Rápido', Icons.explore),
                    const SizedBox(height: 16),
                    _buildQuickAccessMessage(),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Actividad reciente mejorada
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Actividad Reciente', Icons.history),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpicHeader() {
    final userName = widget.currentUser?['name'] ?? 'Usuario';
    
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardColors.primaryLight,
            DashboardColors.accent,
            DashboardColors.primary,
            DashboardColors.primaryDark,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: DashboardAppColorsUnified.orangeShadow,
            blurRadius: 30,
            offset: Offset(0, 10),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: DashboardColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Patrón animado de fondo
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GoldPatternPainter(
                    animation: _rotateController.value,
                  ),
                );
              },
            ),
          ),
          
          // Shimmer effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.3 * (1 - (_shimmerController.value - 0.5).abs() * 2)),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Contenido del header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge BETA con rotación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedBuilder(
                        animation: _rotateController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: math.sin(_rotateController.value * 2 * math.pi) * 0.1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    DashboardColors.wood,
                                    DashboardColors.woodLight,
                                    DashboardColors.woodGolden,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: DashboardColors.wood.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.science_outlined, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'BETA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Icono pulsante naranja
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  DashboardAppColorsUnified.orangeGlow.withValues(alpha: 0.4),
                                  DashboardAppColorsUnified.orange.withValues(alpha: 0.3),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: DashboardAppColorsUnified.orangeGlow.withValues(alpha: 0.7 * _pulseController.value),
                                  blurRadius: 25 * _pulseController.value,
                                  spreadRadius: 6 * _pulseController.value,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Saludo con efecto
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()} 👋',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                DashboardAppColorsUnified.orangeBright.withValues(alpha: 0.9),
                                DashboardAppColorsUnified.orange.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: DashboardAppColorsUnified.orangeGlow.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Text(
                            '🔥 Racha de 7 días activa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [DashboardAppColorsUnified.orange, DashboardAppColorsUnified.orangeGlow],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: DashboardAppColorsUnified.orangeShadow,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: DashboardColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStats() {
    return Row(
      children: [
        Expanded(child: _buildAnimatedStatCard('Ofertas', '12', Icons.local_offer, DashboardAppColorsUnified.orange, 0)),
        const SizedBox(width: 12),
        Expanded(child: _buildAnimatedStatCard('Mensajes', '5', Icons.chat_bubble, DashboardColors.woodLight, 100)),
        const SizedBox(width: 12),
        Expanded(child: _buildAnimatedStatCard('Grupos', '3', Icons.groups, DashboardAppColorsUnified.orangeBright, 200)),
      ],
    );
  }

  Widget _buildAnimatedStatCard(String label, String value, IconData icon, Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.9), color],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.2 * _pulseController.value),
                      blurRadius: 25 * _pulseController.value,
                      spreadRadius: 3 * _pulseController.value,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessMessage() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardAppColorsUnified.orange.withOpacity(0.1),
                DashboardAppColorsUnified.orangeGlow.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DashboardAppColorsUnified.orange.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: DashboardAppColorsUnified.orange.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorsUnified.orange,
                      AppColorsUnified.orangeMedium,
                      AppColorsUnified.orangeLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: DashboardAppColorsUnified.orange.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _shimmerController.value * 2 * math.pi * 0.5,
                      child: const Icon(
                        Icons.apps_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ Menú Rápido Disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DashboardColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toca el botón flotante naranja para acceder a todas las secciones desde cualquier pantalla',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.touch_app,
                color: DashboardAppColorsUnified.orange.withOpacity(0.6),
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withValues(alpha: 0.85), color, color.withValues(alpha: 0.9)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1 * math.sin(_shimmerController.value * math.pi)),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Brillo animado
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.2 * math.sin(_shimmerController.value * 2 * math.pi).abs()),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Contenido
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(icon, size: 36, color: Colors.white),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActivityCard(
          icon: Icons.local_fire_department,
          title: 'Nueva oportunidad disponible',
          subtitle: 'Servicio de Perforación -50%',
          time: 'Hace 2 horas',
          iconColor: DashboardAppColorsUnified.orange,
          delay: 0,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          icon: Icons.people_alt,
          title: '3 nuevos mineros se unieron',
          subtitle: 'A tu grupo "Extracción Norte"',
          time: 'Hace 5 horas',
          iconColor: DashboardColors.woodLight,
          delay: 100,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          icon: Icons.shopping_cart_rounded,
          title: 'Nuevo pedido confirmado',
          subtitle: 'Equipo de seguridad - \$1,250',
          time: 'Ayer',
          iconColor: DashboardAppColorsUnified.orangeBright,
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(50 * (1 - value), 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: DashboardColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DashboardColors.gray200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [iconColor.withValues(alpha: 0.9), iconColor],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withValues(alpha: 0.4 * _pulseController.value),
                              blurRadius: 12 * _pulseController.value,
                              spreadRadius: 3 * _pulseController.value,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: DashboardColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: DashboardColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter para el patrón dorado animado
class _GoldPatternPainter extends CustomPainter {
  final double animation;

  _GoldPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Círculos dorados rotando
    final goldPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final angle = (animation * 2 * math.pi) + (i * math.pi / 2.5);
      final x = size.width * 0.8 + math.cos(angle) * 60;
      final y = size.height * 0.3 + math.sin(angle) * 60;
      canvas.drawCircle(Offset(x, y), 40 - (i * 5), goldPaint);
    }
    
    // Capas naranja flotantes
    final orangePaint = Paint()
      ..color = AppColorsUnified.orangeApple.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final angle = (animation * math.pi) + (i * math.pi * 0.7);
      final x = size.width * 0.2 + math.sin(angle) * 80;
      final y = size.height * 0.5 + math.cos(angle) * 50;
      canvas.drawCircle(Offset(x, y), 30 + (i * 10), orangePaint);
    }
    
    // Capas madera (rectángulos suaves)
    final woodPaint = Paint()
      ..color = AppColorsUnified.textSecondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 2; i++) {
      final offset = animation * 100 + (i * 150);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (offset % size.width) - 50,
          size.height * 0.6 + (i * 30),
          120,
          20,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, woodPaint);
    }

    // Líneas onduladas doradas
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final path = Path();
    for (double x = 0; x < size.width; x += 5) {
      final y = size.height * 0.5 + math.sin((x / size.width + animation) * 4 * math.pi) * 20;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_GoldPatternPainter oldDelegate) => true;
}
