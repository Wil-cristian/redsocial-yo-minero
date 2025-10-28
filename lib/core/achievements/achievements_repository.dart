import 'package:flutter/material.dart';
import 'achievement_models.dart';

/// Repositorio de logros predefinidos
class AchievementsRepository {
  static List<Achievement> getAllAchievements() {
    return [
      // Badges de nivel
      const Achievement(
        id: 'minero_novato',
        title: 'Minero Novato',
        description: 'Completa tu primer proyecto minero',
        icon: Icons.person,
        type: BadgeType.mineroNovato,
        gemTier: GemTier.bronze,
        requiredXP: 0,
      ),
      const Achievement(
        id: 'explorador',
        title: 'Explorador',
        description: 'Alcanza el nivel 20',
        icon: Icons.explore,
        type: BadgeType.explorador,
        gemTier: GemTier.silver,
        requiredXP: 1000,
      ),
      const Achievement(
        id: 'experto',
        title: 'Experto Minero',
        description: 'Alcanza el nivel 40',
        icon: Icons.military_tech,
        type: BadgeType.experto,
        gemTier: GemTier.gold,
        requiredXP: 5000,
      ),
      const Achievement(
        id: 'maestro',
        title: 'Maestro de la Minería',
        description: 'Alcanza el nivel 60',
        icon: Icons.workspace_premium,
        type: BadgeType.maestro,
        gemTier: GemTier.emerald,
        requiredXP: 15000,
      ),
      const Achievement(
        id: 'leyenda',
        title: 'Leyenda Minera',
        description: 'Alcanza el nivel 80',
        icon: Icons.diamond,
        type: BadgeType.leyenda,
        gemTier: GemTier.diamond,
        requiredXP: 40000,
      ),
      
      // Badges de proyectos
      const Achievement(
        id: 'primer_proyecto',
        title: 'Primer Proyecto',
        description: 'Completa tu primer proyecto',
        icon: Icons.rocket_launch,
        type: BadgeType.primerProyecto,
        gemTier: GemTier.bronze,
        requiredXP: 100,
      ),
      const Achievement(
        id: 'cinco_proyectos',
        title: 'Constructor',
        description: 'Completa 5 proyectos',
        icon: Icons.construction,
        type: BadgeType.cincoProyectos,
        gemTier: GemTier.silver,
        requiredXP: 500,
      ),
      const Achievement(
        id: 'diez_proyectos',
        title: 'Magnate',
        description: 'Completa 10 proyectos',
        icon: Icons.account_balance,
        type: BadgeType.diezProyectos,
        gemTier: GemTier.gold,
        requiredXP: 1000,
      ),
      
      // Badges de servicios
      const Achievement(
        id: 'primer_servicio',
        title: 'Primer Servicio',
        description: 'Ofrece tu primer servicio',
        icon: Icons.handshake,
        type: BadgeType.primerServicio,
        gemTier: GemTier.bronze,
        requiredXP: 50,
      ),
      const Achievement(
        id: 'servicio_popular',
        title: 'Servicio Popular',
        description: 'Recibe 10 solicitudes de servicio',
        icon: Icons.trending_up,
        type: BadgeType.servicioPopular,
        gemTier: GemTier.gold,
        requiredXP: 500,
      ),
      
      // Badges sociales
      const Achievement(
        id: 'colaborador',
        title: 'Colaborador',
        description: 'Únete a 5 grupos',
        icon: Icons.groups,
        type: BadgeType.colaborador,
        gemTier: GemTier.silver,
        requiredXP: 250,
      ),
      const Achievement(
        id: 'comunicador',
        title: 'Comunicador',
        description: 'Recibe 50 likes en tus publicaciones',
        icon: Icons.thumb_up,
        type: BadgeType.comunicador,
        gemTier: GemTier.gold,
        requiredXP: 300,
      ),
      const Achievement(
        id: 'influyente',
        title: 'Influyente',
        description: 'Recibe 100 comentarios en tus publicaciones',
        icon: Icons.stars,
        type: BadgeType.influyente,
        gemTier: GemTier.emerald,
        requiredXP: 800,
      ),
      const Achievement(
        id: 'veterano',
        title: 'Veterano',
        description: 'Inicia sesión durante 30 días consecutivos',
        icon: Icons.calendar_today,
        type: BadgeType.veterano,
        gemTier: GemTier.diamond,
        requiredXP: 1500,
      ),
    ];
  }

  static List<String> getPerksForTier(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        return [
          'Acceso a proyectos básicos',
          'Perfil personalizable',
          'Hasta 3 servicios activos',
        ];
      case GemTier.silver:
        return [
          'Acceso a proyectos intermedios',
          'Badge de plata en perfil',
          'Hasta 5 servicios activos',
          'Prioridad en búsquedas',
        ];
      case GemTier.gold:
        return [
          'Acceso a proyectos premium',
          'Badge de oro destacado',
          'Hasta 10 servicios activos',
          'Destacado en búsquedas',
          'Análisis de rendimiento',
        ];
      case GemTier.emerald:
        return [
          'Acceso a proyectos exclusivos',
          'Badge de esmeralda brillante',
          'Servicios ilimitados',
          'Máxima prioridad',
          'Panel de estadísticas avanzadas',
          'Soporte prioritario',
        ];
      case GemTier.diamond:
        return [
          'Acceso VIP a todo',
          'Badge de diamante legendario',
          'Servicios y proyectos ilimitados',
          'Prioridad absoluta',
          'Dashboard ejecutivo completo',
          'Soporte 24/7',
          'Acceso anticipado a nuevas funciones',
          'Consultoría personalizada',
        ];
    }
  }
}
