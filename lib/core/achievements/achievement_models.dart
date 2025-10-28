import 'package:flutter/material.dart';

/// Tipos de badges disponibles
enum BadgeType {
  mineroNovato,
  explorador,
  experto,
  maestro,
  leyenda,
  // Badges especiales
  primerProyecto,
  cincoProyectos,
  diezProyectos,
  primerServicio,
  servicioPopular,
  colaborador,
  comunicador,
  influyente,
  veterano,
}

/// Modelo de badge/logro
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final BadgeType type;
  final GemTier gemTier;
  final int requiredXP;
  final bool unlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 - 1.0

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.gemTier,
    required this.requiredXP,
    this.unlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      gemTier: gemTier,
      requiredXP: requiredXP,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }
}

/// Niveles de gemas
enum GemTier {
  bronze,
  silver,
  gold,
  emerald,
  diamond,
}

/// Modelo de nivel de usuario
class UserLevel {
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final GemTier tier;
  final String tierName;
  final List<String> perks;

  const UserLevel({
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.tier,
    required this.tierName,
    required this.perks,
  });

  double get progress => currentXP / xpToNextLevel;

  static GemTier getTierForLevel(int level) {
    if (level >= 80) return GemTier.diamond;
    if (level >= 60) return GemTier.emerald;
    if (level >= 40) return GemTier.gold;
    if (level >= 20) return GemTier.silver;
    return GemTier.bronze;
  }

  static String getTierName(GemTier tier) {
    switch (tier) {
      case GemTier.bronze:
        return 'Bronce';
      case GemTier.silver:
        return 'Plata';
      case GemTier.gold:
        return 'Oro';
      case GemTier.emerald:
        return 'Esmeralda';
      case GemTier.diamond:
        return 'Diamante';
    }
  }

  static int calculateXPForLevel(int level) {
    // XP requerido aumenta exponencialmente
    return (100 + (level * 50) + (level * level * 10)).toInt();
  }
}

/// Actividades que otorgan XP
enum XPActivity {
  createPost,
  receiveLike,
  receiveComment,
  completeProject,
  offerService,
  joinGroup,
  dailyLogin,
  profileComplete,
  helpOther,
}

class XPReward {
  static int getXP(XPActivity activity) {
    switch (activity) {
      case XPActivity.createPost:
        return 10;
      case XPActivity.receiveLike:
        return 2;
      case XPActivity.receiveComment:
        return 5;
      case XPActivity.completeProject:
        return 100;
      case XPActivity.offerService:
        return 50;
      case XPActivity.joinGroup:
        return 25;
      case XPActivity.dailyLogin:
        return 5;
      case XPActivity.profileComplete:
        return 50;
      case XPActivity.helpOther:
        return 20;
    }
  }
}
