import 'package:flutter/material.dart';
import '../achievements/achievement_models.dart';

/// Categorías de favoritos con gemas
enum FavoriteCategory {
  proyectos,
  servicios,
  grupos,
  publicaciones,
  usuarios,
}

class FavoriteItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final FavoriteCategory category;
  final GemTier gemTier;
  final DateTime addedAt;

  const FavoriteItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.gemTier,
    required this.addedAt,
  });
}
