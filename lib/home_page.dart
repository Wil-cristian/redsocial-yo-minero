import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';

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
  final _supabase = SupabaseService.instance.client;
  int _savedPostsCount = 0;
  
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
    
    _loadSavedPostsCount();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPostsCount() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      final response = await _supabase
          .from('saved_posts')
          .select('id')
          .eq('user_id', currentUser.id);

      if (mounted) {
        setState(() {
          _savedPostsCount = (response as List).length;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando conteo de guardados: $e');
      // Si saved_posts no existe, intentar con saved_offers
      try {
        final currentUser = SupabaseAuthService.instance.currentUser;
        if (currentUser == null) return;
        
        final response = await _supabase
            .from('saved_offers')
            .select('id')
            .eq('user_id', currentUser.id);

        if (mounted) {
          setState(() {
            _savedPostsCount = (response as List).length;
          });
        }
      } catch (e2) {
        debugPrint('❌ Error con saved_offers también: $e2');
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsUnified.background,
              AppColorsUnified.pureWhite,
              AppColorsUnified.orangeLight.withValues(alpha: 0.05),
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
            AppColorsUnified.orangeLight,
            AppColorsUnified.gold,
            AppColorsUnified.orange,
            AppColorsUnified.orangeDark,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColorsUnified.orangeDark.withValues(alpha: 0.3),
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
                        AppColorsUnified.fade(AppColorsUnified.pureWhite, 0),
                        AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3 * (1 - (_shimmerController.value - 0.5).abs() * 2)),
                        AppColorsUnified.fade(AppColorsUnified.pureWhite, 0),
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
                                    AppColorsUnified.orange,
                                    AppColorsUnified.orangeLight,
                                    AppColorsUnified.gold,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColorsUnified.fade(AppColorsUnified.orange, 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.science_outlined, color: AppColorsUnified.pureWhite, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'BETA',
                                    style: TextStyle(
                                      color: AppColorsUnified.pureWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      shadows: [
                                        Shadow(
                                          color: AppColorsUnified.fade(AppColorsUnified.pureBlack, 0.38),
                                          offset: const Offset(0, 1),
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
                                  AppColorsUnified.fade(AppColorsUnified.orange, 0.4),
                                  AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsUnified.orange.withValues(alpha: 0.7 * _pulseController.value),
                                  blurRadius: 25 * _pulseController.value,
                                  spreadRadius: 6 * _pulseController.value,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: AppColorsUnified.pureWhite,
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
                            color: AppColorsUnified.whiteTransparent90,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.pureWhite,
                            shadows: [
                              Shadow(
                                color: AppColorsUnified.black26,
                                offset: const Offset(0, 2),
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
                                AppColorsUnified.fade(AppColorsUnified.orange, 0.9),
                                AppColorsUnified.fade(AppColorsUnified.orange, 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorsUnified.fade(AppColorsUnified.orange, 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            '🔥 Racha de 7 días activa',
                            style: TextStyle(
                              color: AppColorsUnified.pureWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: AppColorsUnified.black26,
                                  offset: const Offset(0, 1),
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
            gradient: const LinearGradient(
              colors: [AppColorsUnified.orange, AppColorsUnified.orange],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: AppColorsUnified.pureWhite, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStats() {
    return Row(
      children: [
        Expanded(child: _buildAnimatedStatCard('Guardados', _savedPostsCount.toString(), Icons.bookmark, AppColorsUnified.orange, 0, '/saved-offers')),
        const SizedBox(width: 12),
        Expanded(child: _buildAnimatedStatCard('Mensajes', '5', Icons.chat_bubble, AppColorsUnified.orangeLight, 100, '/messages')),
        const SizedBox(width: 12),
        Expanded(child: _buildAnimatedStatCard('Grupos', '3', Icons.groups, AppColorsUnified.orange, 200, '/groups')),
      ],
    );
  }

  Widget _buildAnimatedStatCard(String label, String value, IconData icon, Color color, int delay, String route) {
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
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Feedback háptico
                    HapticFeedback.mediumImpact();
                    // Navegación con animación
                    Navigator.pushNamed(context, route);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColorsUnified.whiteTransparent30,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: AppColorsUnified.pureWhite, size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.pureWhite,
                              shadows: [
                                Shadow(
                                  color: AppColorsUnified.black26,
                                  offset: const Offset(0, 2),
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
                              color: AppColorsUnified.whiteTransparent90,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
                AppColorsUnified.fade(AppColorsUnified.orange, 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
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
                      color: AppColorsUnified.fade(AppColorsUnified.orange, 0.4),
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
                      child: Icon(
                        Icons.apps_rounded,
                        color: AppColorsUnified.pureWhite,
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
                        color: AppColorsUnified.charcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toca el botón flotante naranja para acceder a todas las secciones desde cualquier pantalla',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColorsUnified.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.touch_app,
                color: AppColorsUnified.fade(AppColorsUnified.orange, 0.6),
                size: 32,
              ),
            ],
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
          iconColor: AppColorsUnified.orange,
          delay: 0,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          icon: Icons.people_alt,
          title: '3 nuevos mineros se unieron',
          subtitle: 'A tu grupo "Extracción Norte"',
          time: 'Hace 5 horas',
          iconColor: AppColorsUnified.orangeLight,
          delay: 100,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          icon: Icons.shopping_cart_rounded,
          title: 'Nuevo pedido confirmado',
          subtitle: 'Equipo de seguridad - \$1,250',
          time: 'Ayer',
          iconColor: AppColorsUnified.orange,
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
                color: AppColorsUnified.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.1), width: 1.5),
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
                        child: Icon(icon, color: AppColorsUnified.pureWhite, size: 26),
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
                            color: AppColorsUnified.charcoal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColorsUnified.textSecondary,
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
      ..color = AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.15)
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
      ..color = AppColorsUnified.fade(AppColorsUnified.orangeApple, 0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final angle = (animation * math.pi) + (i * math.pi * 0.7);
      final x = size.width * 0.2 + math.sin(angle) * 80;
      final y = size.height * 0.5 + math.cos(angle) * 50;
      canvas.drawCircle(Offset(x, y), 30 + (i * 10), orangePaint);
    }
    
    // Capas madera (rectángulos suaves)
    final woodPaint = Paint()
      ..color = AppColorsUnified.fade(AppColorsUnified.textSecondary, 0.1)
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
      ..color = AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.1)
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
