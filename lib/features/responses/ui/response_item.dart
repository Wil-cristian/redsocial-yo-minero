// lib/features/responses/ui/response_item.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_unified.dart';
import '../../../shared/models/response.dart';

class ResponseItem extends StatelessWidget {
  final Response response;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onMarkBestAnswer;
  final bool canMarkBestAnswer;
  final bool isNested;
  final int nestingLevel;
  final bool showConnectionLine;

  const ResponseItem({
    super.key,
    required this.response,
    this.onLike,
    this.onReply,
    this.onMarkBestAnswer,
    this.canMarkBestAnswer = false,
    this.isNested = false,
    this.nestingLevel = 0,
    this.showConnectionLine = false,
  });

  @override
  Widget build(BuildContext context) {
    // Configuración jerárquica visual
    final double indentationWidth = isNested ? (nestingLevel * 32.0) : 0;
    final double cardWidth = MediaQuery.of(context).size.width - indentationWidth - 32;
    final double containerPadding = isNested ? 12.0 : 16.0;
    final double borderRadius = isNested ? 8.0 : 12.0;
    
    return Container(
      margin: EdgeInsets.only(
        left: indentationWidth,
        bottom: isNested ? 12 : 16,
        right: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea de conexión para respuestas anidadas
          if (showConnectionLine) ..._buildConnectionLine(),
          
          // Contenido principal de la respuesta
          Expanded(
            child: Container(
              width: cardWidth,
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsUnified.backgroundDark.withValues(
                      alpha: isNested ? 0.03 : 0.05
                    ),
                    blurRadius: isNested ? 4 : 8,
                    offset: Offset(0, isNested ? 1 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con información del usuario y mejor respuesta
                  Row(
                    children: [
                      // Avatar del usuario (tamaño jerárquico)
                      CircleAvatar(
                        radius: isNested ? 16 : 20,
                        backgroundColor: AppColorsUnified.gold.withValues(
                          alpha: isNested ? 0.15 : 0.2
                        ),
                        backgroundImage: response.authorProfileImage != null
                            ? NetworkImage(response.authorProfileImage!)
                            : null,
                        child: response.authorProfileImage == null
                            ? Icon(
                                Icons.person,
                                color: AppColorsUnified.gold,
                                size: isNested ? 20 : 24,
                              )
                            : null,
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Información del usuario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  response.authorUsername ?? 'Usuario',
                                  style: TextStyle(
                                    fontSize: isNested ? 14 : 16,
                                    fontWeight: isNested ? FontWeight.w600 : FontWeight.bold,
                                    color: isNested 
                                        ? AppColorsUnified.textPrimary.withValues(alpha: 0.9)
                                        : AppColorsUnified.textPrimary,
                                  ),
                                ),
                                if (response.isBestAnswer) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColorsUnified.orange,
                                          AppColorsUnified.orange.withValues(alpha: 0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Mejor respuesta',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(response.createdAt),
                              style: TextStyle(
                                fontSize: isNested ? 11 : 13,
                                color: AppColorsUnified.textSecondary.withValues(
                                  alpha: isNested ? 0.8 : 1.0
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Indicador de respuesta anidada
                  if (isNested) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.subdirectory_arrow_right,
                          size: 16,
                          color: AppColorsUnified.gold.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Respuesta a comentario',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorsUnified.gold.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    const SizedBox(height: 16),
                  ],
                  
                  // Contenido de la respuesta (tamaño jerárquico)
                  Text(
                    response.content,
                    style: TextStyle(
                      fontSize: isNested ? 14 : 16,
                      color: isNested 
                          ? AppColorsUnified.textPrimary.withValues(alpha: 0.95)
                          : AppColorsUnified.textPrimary,
                      height: 1.5,
                      fontWeight: isNested ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botones de acción
                  Row(
                    children: [
                      // Botón de like
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onLike,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: response.userHasLiked
                                  ? AppColorsUnified.gold.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: response.userHasLiked
                                    ? AppColorsUnified.gold
                                    : AppColorsUnified.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  response.userHasLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 16,
                                  color: response.userHasLiked
                                      ? AppColorsUnified.gold
                                      : AppColorsUnified.textSecondary,
                                ),
                                if (response.likesCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    response.likesCount.toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: response.userHasLiked
                                          ? AppColorsUnified.gold
                                          : AppColorsUnified.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Botón de responder
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onReply,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsUnified.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColorsUnified.gold,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.reply_rounded,
                                  size: 16,
                                  color: AppColorsUnified.gold,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Responder',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColorsUnified.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Botón de marcar/desmarcar mejor respuesta (solo visible para autor del post)
                      if (canMarkBestAnswer)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onMarkBestAnswer,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: response.isBestAnswer
                                    ? LinearGradient(
                                        colors: [
                                          AppColorsUnified.orange.withValues(alpha: 0.1),
                                          AppColorsUnified.orange.withValues(alpha: 0.15),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          AppColorsUnified.gold.withValues(alpha: 0.1),
                                          AppColorsUnified.goldDeep.withValues(alpha: 0.1),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: response.isBestAnswer 
                                      ? AppColorsUnified.orange 
                                      : AppColorsUnified.gold,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    response.isBestAnswer 
                                        ? Icons.cancel_outlined 
                                        : Icons.verified_outlined,
                                    size: 16,
                                    color: response.isBestAnswer 
                                        ? AppColorsUnified.orange 
                                        : AppColorsUnified.gold,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    response.isBestAnswer 
                                        ? 'Quitar mejor respuesta' 
                                        : 'Marcar como mejor',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: response.isBestAnswer 
                                          ? AppColorsUnified.orange 
                                          : AppColorsUnified.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos helper para jerarquía visual
  Color _getBackgroundColor() {
    if (response.isBestAnswer) {
      return AppColorsUnified.orange.withValues(alpha: 0.05);
    }
    if (isNested) {
      return AppColorsUnified.gold.withValues(alpha: 0.02);
    }
    return AppColorsUnified.surface;
  }

  Color _getBorderColor() {
    if (response.isBestAnswer) {
      return AppColorsUnified.orange.withValues(alpha: 0.3);
    }
    if (isNested) {
      return AppColorsUnified.gold.withValues(alpha: 0.2);
    }
    return AppColorsUnified.backgroundDark.withValues(alpha: 0.1);
  }

  double _getBorderWidth() {
    if (response.isBestAnswer) return 2;
    if (isNested) return 1.5;
    return 1;
  }

  // Método para construir la línea de conexión visual mejorada
  List<Widget> _buildConnectionLine() {
    return [
      Container(
        width: 24,
        height: 60,
        child: Stack(
          children: [
            // Línea vertical principal
            Positioned(
              left: 0,
              top: 0,
              bottom: 30,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColorsUnified.gold.withValues(alpha: 0.3),
                      AppColorsUnified.gold.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Línea horizontal
            Positioned(
              left: 0,
              top: 30,
              child: Container(
                width: 16,
                height: 2,
                color: AppColorsUnified.gold.withValues(alpha: 0.5),
              ),
            ),
            // Punto de conexión
            Positioned(
              left: 14,
              top: 26,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColorsUnified.gold.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColorsUnified.gold,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}