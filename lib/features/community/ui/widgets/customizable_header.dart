import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/dashboard_colors.dart';
import '../../../../core/di/locator.dart';
import '../../../../features/posts/domain/post_repository.dart';

/// 🎨 Header personalizable con widgets dinámicos, videos y efectos premium
class CustomizableHeader extends StatefulWidget {
  const CustomizableHeader({super.key});

  @override
  State<CustomizableHeader> createState() => _CustomizableHeaderState();
}

class _CustomizableHeaderState extends State<CustomizableHeader>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _rotationController;
  
  // Widgets activos (personalizables por usuario)
  List<HeaderWidgetType> activeWidgets = [
    HeaderWidgetType.liveStats,
    HeaderWidgetType.dailyStreak,
    HeaderWidgetType.hotOpportunity,
  ];

  int currentWidgetIndex = 0;
  late PageController _pageController;
  
  // Datos reales
  int activeUsersCount = 0;
  int todayOffersCount = 0;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Cargar preferencias y datos
    _loadUserPreferences();
    _loadRealTimeData();
    
    // Animación de destellos
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Animación de rotación suave
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Auto-rotación cada 5 segundos
    _startAutoRotation();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetIndices = prefs.getStringList('header_widgets');
      
      if (widgetIndices != null && widgetIndices.isNotEmpty) {
        setState(() {
          activeWidgets = widgetIndices
              .map((index) => HeaderWidgetType.values[int.parse(index)])
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error cargando preferencias: $e');
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetIndices = activeWidgets
          .map((widget) => widget.index.toString())
          .toList();
      await prefs.setStringList('header_widgets', widgetIndices);
      debugPrint('✅ Preferencias guardadas: ${activeWidgets.length} widgets');
    } catch (e) {
      debugPrint('Error guardando preferencias: $e');
    }
  }

  Future<void> _loadRealTimeData() async {
    try {
      final repo = sl<PostRepository>();
      final posts = await repo.getAll();
      
      // Calcular estadísticas reales
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final todayPosts = posts.where((p) {
        final postDate = DateTime(
          p.createdAt.year,
          p.createdAt.month,
          p.createdAt.day,
        );
        return postDate == todayStart;
      }).toList();
      
      setState(() {
        todayOffersCount = todayPosts.length;
        activeUsersCount = posts
            .map((p) => p.authorId)
            .toSet()
            .length; // Usuarios únicos
        isLoadingData = false;
      });
      
      debugPrint('📊 Datos cargados: $activeUsersCount usuarios, $todayOffersCount ofertas hoy');
    } catch (e) {
      debugPrint('Error cargando datos: $e');
      setState(() => isLoadingData = false);
    }
  }

  void _startAutoRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && activeWidgets.length > 1) {
        final nextIndex = (currentWidgetIndex + 1) % activeWidgets.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        setState(() => currentWidgetIndex = nextIndex);
        _startAutoRotation();
      }
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _rotationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardColors.cardOrange,
            DashboardColors.cardOrange.withValues(alpha: 0.9),
            DashboardColors.gold.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Fondo animado con destellos
          _buildAnimatedBackground(),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header principal
                _buildMainHeader(),
                
                // Widgets personalizables con PageView
                SizedBox(
                  height: 100,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => currentWidgetIndex = index);
                    },
                    itemCount: activeWidgets.length,
                    itemBuilder: (context, index) {
                      return _buildWidget(activeWidgets[index]);
                    },
                  ),
                ),
                
                // Indicadores + Botón de configuración
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return CustomPaint(
          painter: SparklePainter(
            animation: _sparkleController,
            color: DashboardColors.gold,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icono con efecto de resplandor
          _buildGlowingIcon(),
          const SizedBox(width: 12),
          
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comunidad',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: DashboardColors.gold.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conecta, comparte y descubre oportunidades',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Badge BETA con efecto
          _buildBetaBadge(),
        ],
      ),
    );
  }

  Widget _buildGlowingIcon() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: DashboardColors.gold.withValues(alpha: 
                  0.3 + (_sparkleController.value * 0.4),
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.groups,
            color: Colors.white,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildBetaBadge() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_rotationController.value * 2 * math.pi) * 0.1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  DashboardColors.gold,
                  DashboardColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DashboardColors.gold.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: DashboardColors.charcoal,
                ),
                SizedBox(width: 4),
                Text(
                  'BETA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: DashboardColors.charcoal,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWidget(HeaderWidgetType type) {
    switch (type) {
      case HeaderWidgetType.liveStats:
        return _LiveStatsWidget(
          sparkleController: _sparkleController,
          activeUsers: activeUsersCount,
          todayOffers: todayOffersCount,
          isLoading: isLoadingData,
        );
      case HeaderWidgetType.dailyStreak:
        return _DailyStreakWidget(sparkleController: _sparkleController);
      case HeaderWidgetType.hotOpportunity:
        return _HotOpportunityWidget(sparkleController: _sparkleController);
      case HeaderWidgetType.weatherAlert:
        return _WeatherAlertWidget();
      case HeaderWidgetType.aiSuggestion:
        return _AISuggestionWidget(sparkleController: _sparkleController);
      case HeaderWidgetType.weeklyMission:
        return _WeeklyMissionWidget();
      case HeaderWidgetType.communityFeed:
        return _CommunityFeedWidget(sparkleController: _sparkleController);
      case HeaderWidgetType.videoHighlight:
        return _VideoHighlightWidget();
    }
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicadores de página
          Row(
            children: List.generate(
              activeWidgets.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentWidgetIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentWidgetIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: currentWidgetIndex == index
                      ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
          
          // Botón de configuración
          _buildConfigButton(),
        ],
      ),
    );
  }

  Widget _buildConfigButton() {
    return GestureDetector(
      onTap: _showWidgetSelector,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'Personalizar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWidgetSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => WidgetSelectorSheet(
        activeWidgets: activeWidgets,
        onWidgetsChanged: (newWidgets) {
          setState(() {
            activeWidgets = newWidgets;
            currentWidgetIndex = 0;
            _pageController.jumpToPage(0);
          });
          _saveUserPreferences(); // Guardar automáticamente
        },
      ),
    );
  }
}

// ============================================
// 📊 WIDGETS INDIVIDUALES
// ============================================

class _LiveStatsWidget extends StatelessWidget {
  final AnimationController sparkleController;
  final int activeUsers;
  final int todayOffers;
  final bool isLoading;
  
  const _LiveStatsWidget({
    required this.sparkleController,
    required this.activeUsers,
    required this.todayOffers,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: CircularProgressIndicator(
            color: DashboardColors.gold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatBubble(
            icon: Icons.people,
            value: '$activeUsers',
            label: 'Usuarios',
            color: DashboardColors.emerald,
            sparkleController: sparkleController,
          ),
          const SizedBox(width: 12),
          _StatBubble(
            icon: Icons.local_fire_department,
            value: '+$todayOffers',
            label: 'Posts hoy',
            color: DashboardColors.error,
            sparkleController: sparkleController,
          ),
          const SizedBox(width: 12),
          _StatBubble(
            icon: Icons.diamond,
            value: '\$1,842',
            label: 'Oro/oz ↑2.3%',
            color: DashboardColors.gold,
            sparkleController: sparkleController,
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final AnimationController sparkleController;

  const _StatBubble({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.sparkleController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: sparkleController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3 + (sparkleController.value * 0.3)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2 + (sparkleController.value * 0.2)),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyStreakWidget extends StatelessWidget {
  final AnimationController sparkleController;
  
  const _DailyStreakWidget({required this.sparkleController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DashboardColors.gold.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: sparkleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (math.sin(sparkleController.value * 2 * math.pi) * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          DashboardColors.gold,
                          DashboardColors.primaryLight,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DashboardColors.gold.withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '⛏️ Tu veta activa: ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        '3 días',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.8,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(DashboardColors.gold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '80% a "Buscador de Oro" 🏆',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotOpportunityWidget extends StatelessWidget {
  final AnimationController sparkleController;
  
  const _HotOpportunityWidget({required this.sparkleController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: sparkleController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.error.withValues(alpha: 0.3),
                  DashboardColors.cardOrange.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DashboardColors.error.withValues(alpha: 
                  0.5 + (sparkleController.value * 0.3),
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: DashboardColors.error.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: sparkleController.value * 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: DashboardColors.error,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🌟 Oportunidad de hoy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Servicio de Perforación -50%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expira en: 4h 23m ⏰',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeatherAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.wb_sunny, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '⛅ Clima en tu zona minera',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Ideal para trabajo de campo hoy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AISuggestionWidget extends StatelessWidget {
  final AnimationController sparkleController;
  
  const _AISuggestionWidget({required this.sparkleController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DashboardColors.minerBlue.withValues(alpha: 0.3),
              DashboardColors.cardBlue.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DashboardColors.minerBlue.withValues(alpha: 0.4)),
        ),
        child: const Row(
          children: [
            Icon(Icons.psychology, color: DashboardColors.minerBlue, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '💡 Basado en tu actividad:',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Text(
                    '3 mineros cerca buscan tu servicio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Ver →',
              style: TextStyle(
                color: DashboardColors.minerBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyMissionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DashboardColors.cardPurple.withValues(alpha: 0.3),
              DashboardColors.cardPurple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.flag, color: DashboardColors.cardPurple, size: 20),
                SizedBox(width: 8),
                Text(
                  '🎯 Misión de la semana',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Conecta con 5 nuevos mineros',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.4,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(DashboardColors.cardPurple),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '2/5 completado',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityFeedWidget extends StatelessWidget {
  final AnimationController sparkleController;
  
  const _CommunityFeedWidget({required this.sparkleController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎊 ¡Carlos cerró su 1er negocio!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '⚡ 127 transacciones esta semana',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoHighlightWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Stack(
          children: [
            // Placeholder para video
            Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 48,
              ),
            ),
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Text(
                '🎥 Destacado: Nueva técnica de extracción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ✨ CUSTOM PAINTER PARA DESTELLOS
// ============================================

class SparklePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  SparklePainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Generar destellos en posiciones aleatorias
    final random = math.Random(42); // Seed fijo para consistencia
    
    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      // Animación de opacidad pulsante
      final opacity = (math.sin((animation.value + (i * 0.1)) * 2 * math.pi) + 1) / 2;
      final sparklePaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      // Dibujar destello
      canvas.drawCircle(
        Offset(x, y),
        2 + (opacity * 3),
        sparklePaint,
      );
      
      // Estrella de 4 puntas
      final starPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(x - 6, y),
        Offset(x + 6, y),
        starPaint,
      );
      canvas.drawLine(
        Offset(x, y - 6),
        Offset(x, y + 6),
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) => false;
}

// ============================================
// ⚙️ SELECTOR DE WIDGETS
// ============================================

enum HeaderWidgetType {
  liveStats,
  dailyStreak,
  hotOpportunity,
  weatherAlert,
  aiSuggestion,
  weeklyMission,
  communityFeed,
  videoHighlight,
}

class WidgetSelectorSheet extends StatefulWidget {
  final List<HeaderWidgetType> activeWidgets;
  final Function(List<HeaderWidgetType>) onWidgetsChanged;

  const WidgetSelectorSheet({
    super.key,
    required this.activeWidgets,
    required this.onWidgetsChanged,
  });

  @override
  State<WidgetSelectorSheet> createState() => _WidgetSelectorSheetState();
}

class _WidgetSelectorSheetState extends State<WidgetSelectorSheet> {
  late List<HeaderWidgetType> selectedWidgets;

  @override
  void initState() {
    super.initState();
    selectedWidgets = List.from(widget.activeWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DashboardColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DashboardColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Título
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.widgets, color: DashboardColors.gold),
                SizedBox(width: 12),
                Text(
                  'Personaliza tu header',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DashboardColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de widgets disponibles
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: HeaderWidgetType.values.map((type) {
                final isSelected = selectedWidgets.contains(type);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedWidgets.add(type);
                      } else {
                        selectedWidgets.remove(type);
                      }
                    });
                  },
                  title: Text(_getWidgetName(type)),
                  subtitle: Text(_getWidgetDescription(type)),
                  secondary: Icon(
                    _getWidgetIcon(type),
                    color: isSelected ? DashboardColors.gold : DashboardColors.gray400,
                  ),
                  activeColor: DashboardColors.gold,
                );
              }).toList(),
            ),
          ),
          
          // Botón guardar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onWidgetsChanged(selectedWidgets);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar configuración',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DashboardColors.charcoal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWidgetName(HeaderWidgetType type) {
    switch (type) {
      case HeaderWidgetType.liveStats:
        return 'Estadísticas en vivo';
      case HeaderWidgetType.dailyStreak:
        return 'Racha diaria';
      case HeaderWidgetType.hotOpportunity:
        return 'Oportunidad destacada';
      case HeaderWidgetType.weatherAlert:
        return 'Clima minero';
      case HeaderWidgetType.aiSuggestion:
        return 'Sugerencia IA';
      case HeaderWidgetType.weeklyMission:
        return 'Misión semanal';
      case HeaderWidgetType.communityFeed:
        return 'Feed comunitario';
      case HeaderWidgetType.videoHighlight:
        return 'Video destacado';
    }
  }

  String _getWidgetDescription(HeaderWidgetType type) {
    switch (type) {
      case HeaderWidgetType.liveStats:
        return 'Usuarios activos, ofertas y precio del oro';
      case HeaderWidgetType.dailyStreak:
        return 'Tu progreso y gamificación';
      case HeaderWidgetType.hotOpportunity:
        return 'Ofertas urgentes con temporizador';
      case HeaderWidgetType.weatherAlert:
        return 'Condiciones climáticas para minería';
      case HeaderWidgetType.aiSuggestion:
        return 'Recomendaciones personalizadas';
      case HeaderWidgetType.weeklyMission:
        return 'Objetivo semanal y recompensas';
      case HeaderWidgetType.communityFeed:
        return 'Logros de otros usuarios';
      case HeaderWidgetType.videoHighlight:
        return 'Videos cortos destacados';
    }
  }

  IconData _getWidgetIcon(HeaderWidgetType type) {
    switch (type) {
      case HeaderWidgetType.liveStats:
        return Icons.analytics;
      case HeaderWidgetType.dailyStreak:
        return Icons.local_fire_department;
      case HeaderWidgetType.hotOpportunity:
        return Icons.flash_on;
      case HeaderWidgetType.weatherAlert:
        return Icons.wb_sunny;
      case HeaderWidgetType.aiSuggestion:
        return Icons.psychology;
      case HeaderWidgetType.weeklyMission:
        return Icons.flag;
      case HeaderWidgetType.communityFeed:
        return Icons.celebration;
      case HeaderWidgetType.videoHighlight:
        return Icons.play_circle;
    }
  }
}
