import 'favorite_models.dart';
import 'package:flutter/material.dart';
import '../achievements/achievement_models.dart';

class FavoritesRepository {
  static List<FavoriteItem> getUserFavorites(String userId) {
    // Datos de ejemplo
    return [
      FavoriteItem(
        id: 'p1',
        title: 'Proyecto El Dorado',
        subtitle: 'Oro y cobre en Antioquia',
        icon: Icons.work,
        category: FavoriteCategory.proyectos,
        gemTier: GemTier.gold,
        addedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FavoriteItem(
        id: 's1',
        title: 'Servicio de Topografía',
        subtitle: 'Ofrecido por GeoMinas',
        icon: Icons.engineering,
        category: FavoriteCategory.servicios,
        gemTier: GemTier.emerald,
        addedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      FavoriteItem(
        id: 'g1',
        title: 'Grupo Mineros Colombia',
        subtitle: 'Comunidad activa',
        icon: Icons.groups,
        category: FavoriteCategory.grupos,
        gemTier: GemTier.silver,
        addedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      FavoriteItem(
        id: 'u1',
        title: 'María González',
        subtitle: 'Experta en perforación',
        icon: Icons.person,
        category: FavoriteCategory.usuarios,
        gemTier: GemTier.diamond,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
