import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/achievements/achievement_models.dart';
import 'core/achievements/achievements_repository.dart';
import 'core/achievements/gem_color_helper.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// Página de logros y niveles del usuario
class AchievementsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const AchievementsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Datos de ejemplo del usuario actual
  final UserLevel userLevel = UserLevel(
    level: 42,
    currentXP: 3200,
    xpToNextLevel: 5000,
    tier: GemTier.gold,
    tierName: 'Oro',
    perks: AchievementsRepository.getPerksForTier(GemTier.gold),
  );

  late List<Achievement> achievements;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar logros con algunos desbloqueados
    achievements = AchievementsRepository.getAllAchievements().map((a) {
      if (a.requiredXP <= 1000) {
        return a.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now().subtract(Duration(days: 30 - (a.requiredXP ~/ 50))),
        );
      } else if (a.requiredXP <= 3000) {
        return a.copyWith(progress: 0.7);
      } else {
        return a.copyWith(progress: 0.3);
      }
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Achievement> get _displayedAchievements {
    final tab = _tabController.index;
    if (tab == 0) return achievements; // Todos
    if (tab == 1) return achievements.where((a) => a.unlocked).toList(); // Desbloqueados
    return achievements.where((a) => !a.unlocked).toList(); // Bloqueados
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.pureWhite,
        elevation: 1,
        title: Text(
          'Logros y Nivel',
          style: TextStyle(
            color: AppColorsUnified.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColorsUnified.orange,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          indicatorColor: AppColorsUnified.orange,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.grid_view, size: 18),
                  const SizedBox(width: 6),
                  Text('Todos (${achievements.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 6),
                  Text('Desbloqueados (${achievements.where((a) => a.unlocked).length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 18),
                  const SizedBox(width: 6),
                  Text('Bloqueados (${achievements.where((a) => !a.unlocked).length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Card de nivel actual
          _buildLevelCard(),
          
          const SizedBox(height: 16),
          
          // Sección de estadísticas
          _buildStatsSection(),
          
          const SizedBox(height: 16),
          
          // Lista de logros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _tabController.index == 0
                  ? 'Todos los logros'
                  : _tabController.index == 1
                      ? 'Logros desbloqueados'
                      : 'Logros por desbloquear',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          ..._displayedAchievements.map((achievement) => 
            _buildAchievementCard(achievement)
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    final gradient = GemColorHelper.getGradientForTier(userLevel.tier);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GemColorHelper.getShadowsForTier(userLevel.tier, isGlowing: true),
      ),
      child: Stack(
        children: [
          // Patrón de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _GemPatternPainter(
                  color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.1),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícono de nivel
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        GemColorHelper.getIconForTier(userLevel.tier),
                        color: AppColorsUnified.pureWhite,
                        size: 32,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Nivel y tier
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nivel ${userLevel.level}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.pureWhite,
                            ),
                          ),
                          Text(
                            'Rango: ${userLevel.tierName}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Barra de progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso al nivel ${userLevel.level + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.9),
                          ),
                        ),
                        Text(
                          '${userLevel.currentXP} / ${userLevel.xpToNextLevel} XP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.9),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: userLevel.progress,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColorsUnified.pureWhite,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${(userLevel.progress * 100).toStringAsFixed(1)}% completado',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final unlockedCount = achievements.where((a) => a.unlocked).length;
    final totalCount = achievements.length;
    final completionRate = (unlockedCount / totalCount * 100).toStringAsFixed(1);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Logros',
              '$unlockedCount/$totalCount',
              Icons.emoji_events,
              AppColorsUnified.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completado',
              '$completionRate%',
              Icons.percent,
              DashboardColors.emerald,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'XP Total',
              '${userLevel.currentXP + (userLevel.level * 1000)}',
              Icons.stars,
              DashboardColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final color = GemColorHelper.getColorForTier(achievement.gemTier);
    final gradient = GemColorHelper.getGradientForTier(achievement.gemTier);
    final isLocked = !achievement.unlocked;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: achievement.unlocked 
            ? Border.all(color: color.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: achievement.unlocked 
                ? color.withOpacity(0.2)
                : AppColorsUnified.fade(AppColorsUnified.textSecondary, 0.1),
            blurRadius: achievement.unlocked ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícono del logro
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isLocked ? null : gradient,
                color: isLocked ? AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4) : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isLocked ? null : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isLocked ? Icons.lock : achievement.icon,
                color: isLocked ? AppColorsUnified.textSecondary : AppColorsUnified.pureWhite,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información del logro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? AppColorsUnified.textSecondary : AppColorsUnified.charcoal,
                          ),
                        ),
                      ),
                      if (achievement.unlocked)
                        Icon(Icons.check_circle, color: color, size: 20),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColorsUnified.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Barra de progreso o fecha de desbloqueo
                  if (achievement.unlocked && achievement.unlockedAt != null) ...[
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)),
                        const SizedBox(width: 4),
                        Text(
                          'Desbloqueado hace ${DateTime.now().difference(achievement.unlockedAt!).inDays} días',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2),
                          ),
                        ),
                      ],
                    ),
                  ] else if (!achievement.unlocked && achievement.progress > 0) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColorsUnified.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: achievement.progress,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(achievement.progress * 100).toStringAsFixed(0)}% completado',
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para el patrón de gemas en el fondo
class _GemPatternPainter extends CustomPainter {
  final Color color;

  _GemPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;
    
    // Dibujar patrón de diamantes
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 15)
          ..lineTo(x + 15, y)
          ..lineTo(x, y + 15)
          ..lineTo(x - 15, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
