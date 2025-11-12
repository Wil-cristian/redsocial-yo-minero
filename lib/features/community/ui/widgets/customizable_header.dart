import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// Widget unificado optimizado que reemplaza 8 widgets similares
class UnifiedHeaderWidget extends StatelessWidget {
  final HeaderWidgetType type;
  final Map<String, dynamic> data;

  const UnifiedHeaderWidget({
    super.key,
    required this.type,
    this.data = const {},
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: config.gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: config.shadowColor, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildIcon(config),
          const SizedBox(width: 16),
          Expanded(child: _buildContent(config)),
        ],
      ),
    );
  }

  Widget _buildIcon(_WidgetConfig config) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(config.icon, size: 32, color: AppColorsUnified.pureWhite),
    );
  }

  Widget _buildContent(_WidgetConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(config.title, style: TextStyle(color: AppColorsUnified.pureWhite, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(config.subtitle, style: TextStyle(color: AppColorsUnified.pureWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        if (config.description != null) ...[
          const SizedBox(height: 4),
          Text(config.description!, style: TextStyle(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.8), fontSize: 12)),
        ],
      ],
    );
  }

  _WidgetConfig _getConfig() {
    switch (type) {
      case HeaderWidgetType.liveStats:
        return _WidgetConfig(
          icon: Icons.trending_up,
          title: 'En vivo ahora',
          subtitle: '${data['activeUsers'] ?? 0} activos',
          description: '${data['todayOffers'] ?? 0} ofertas hoy',
          gradientColors: [AppColorsUnified.orangeLight, AppColorsUnified.orange],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
        );
      case HeaderWidgetType.dailyStreak:
        return _WidgetConfig(
          icon: Icons.local_fire_department,
          title: 'Racha diaria',
          subtitle: '${data['streak'] ?? 0} días',
          description: '¡Sigue así!',
          gradientColors: [AppColorsUnified.orange, AppColorsUnified.darken(AppColorsUnified.orange, 0.2)],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
        );
      case HeaderWidgetType.hotOpportunity:
        return _WidgetConfig(
          icon: Icons.whatshot,
          title: 'Oportunidad caliente',
          subtitle: data['title'] ?? 'Sin ofertas',
          description: '\$${data['price'] ?? 0}',
          gradientColors: [AppColorsUnified.error, AppColorsUnified.error],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.error, 0.3),
        );
      case HeaderWidgetType.weatherAlert:
        return _WidgetConfig(
          icon: Icons.wb_sunny,
          title: 'Clima',
          subtitle: '${data['temp'] ?? 22}°C',
          description: data['condition'] ?? 'Soleado',
          gradientColors: [AppColorsUnified.warning, AppColorsUnified.orange],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.warning, 0.3),
        );
      case HeaderWidgetType.aiSuggestion:
        return _WidgetConfig(
          icon: Icons.psychology,
          title: 'Sugerencia IA',
          subtitle: data['suggestion'] ?? 'Explora nuevas ofertas',
          description: 'Basado en tu actividad',
          gradientColors: [AppColorsUnified.companyBlueDark, AppColorsUnified.companyBlueDarker],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.companyBlueDark, 0.3),
        );
      case HeaderWidgetType.weeklyMission:
        return _WidgetConfig(
          icon: Icons.emoji_events,
          title: 'Misión semanal',
          subtitle: '${data['progress'] ?? 0}%',
          description: 'Completa 5 tareas',
          gradientColors: [AppColorsUnified.success, AppColorsUnified.success],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.success, 0.3),
        );
      case HeaderWidgetType.communityFeed:
        return _WidgetConfig(
          icon: Icons.people,
          title: 'Comunidad',
          subtitle: '${data['newPosts'] ?? 0} nuevos',
          description: 'Últimas 24h',
          gradientColors: [AppColorsUnified.companyBlue, AppColorsUnified.companyBlue],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.companyBlue, 0.3),
        );
      case HeaderWidgetType.videoHighlight:
        return _WidgetConfig(
          icon: Icons.play_circle_filled,
          title: 'Video destacado',
          subtitle: data['videoTitle'] ?? 'Sin video',
          description: '${data['views'] ?? 0} vistas',
          gradientColors: [AppColorsUnified.companyBlue, AppColorsUnified.companyBlue],
          shadowColor: AppColorsUnified.fade(AppColorsUnified.companyBlue, 0.3),
        );
    }
  }
}

class _WidgetConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? description;
  final List<Color> gradientColors;
  final Color shadowColor;

  _WidgetConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.description,
    required this.gradientColors,
    required this.shadowColor,
  });
}

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
