import 'package:flutter/material.dart';
import '../../core/favorites/favorite_models.dart';
import '../../core/achievements/gem_color_helper.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class FavoriteGemCard extends StatelessWidget {
  final FavoriteItem favorite;
  final VoidCallback? onTap;

  const FavoriteGemCard({
    super.key,
    required this.favorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = GemColorHelper.getGradientForTier(favorite.gemTier);
    final color = GemColorHelper.getColorForTier(favorite.gemTier);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  favorite.icon,
                  color: AppColorsUnified.pureWhite,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      favorite.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  favorite.category.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.pureWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
