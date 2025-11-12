import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColorsUnified.background,
            borderRadius: borderRadius,
          ),
          child: Icon(
            Icons.image_outlined,
            size: 40,
            color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColorsUnified.background,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: 40,
        color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2),
      ),
    );
  }
}

class CircularCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? placeholder;

  const CircularCachedImage({
    super.key,
    required this.imageUrl,
    this.radius = 28,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColorsUnified.background,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (error, stackTrace) {},
      child: null,
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
          child: Icon(
            Icons.person,
            size: radius * 1.2,
            color: AppColorsUnified.textSecondary,
          ),
        );
  }
}
