import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import '../../models/inventory_item.dart';

/// Diálogo para mostrar métricas detalladas de un item
class InventoryMetricsDialog extends StatelessWidget {
  final InventoryItem item;

  const InventoryMetricsDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColorsUnified.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // Performance Score
              _buildPerformanceScore(),
              
              const SizedBox(height: 24),
              
              // Métricas de interacción
              _buildInteractionMetrics(),
              
              const SizedBox(height: 20),
              
              // Métricas específicas por tipo
              _buildTypeSpecificMetrics(),
              
              const SizedBox(height: 20),
              
              // Engagement y conversión
              _buildEngagementSection(),
              
              const SizedBox(height: 20),
              
              // Timeline
              _buildTimeline(),
              
              const SizedBox(height: 16),
              
              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsUnified.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Métricas',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceScore() {
    final score = item.metrics.performanceScore;
    Color scoreColor;
    String scoreLabel;
    
    if (score >= 80) {
      scoreColor = AppColorsUnified.success;
      scoreLabel = '¡Excelente!';
    } else if (score >= 60) {
      scoreColor = AppColorsUnified.gold;
      scoreLabel = 'Muy bien';
    } else if (score >= 40) {
      scoreColor = AppColorsUnified.warning;
      scoreLabel = 'Normal';
    } else {
      scoreColor = AppColorsUnified.error;
      scoreLabel = 'Necesita mejora';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.2),
            scoreColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: AppColorsUnified.backgroundDark,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Score',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                Text(
                  scoreLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  'Basado en engagement y conversión',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interacciones',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            _buildMetricTile(
              icon: Icons.visibility,
              value: '${item.metrics.views}',
              label: 'Vistas',
              color: AppColorsUnified.companyBlue,
            ),
            _buildMetricTile(
              icon: Icons.favorite,
              value: '${item.metrics.likes}',
              label: 'Likes',
              color: AppColorsUnified.error,
            ),
            _buildMetricTile(
              icon: Icons.comment,
              value: '${item.metrics.comments}',
              label: 'Comentarios',
              color: Colors.purple,
            ),
            _buildMetricTile(
              icon: Icons.bookmark,
              value: '${item.metrics.saves}',
              label: 'Guardados',
              color: AppColorsUnified.gold,
            ),
            _buildMetricTile(
              icon: Icons.share,
              value: '${item.metrics.shares}',
              label: 'Compartidos',
              color: Colors.teal,
            ),
            _buildMetricTile(
              icon: Icons.chat_bubble,
              value: '${item.metrics.chats}',
              label: 'Chats',
              color: AppColorsUnified.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificMetrics() {
    switch (item.type) {
      case InventoryItemType.product:
        return _buildProductMetrics();
      case InventoryItemType.request:
        return _buildRequestMetrics();
      case InventoryItemType.poll:
        return _buildPollMetrics();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProductMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Métricas de Producto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProductStat(
                  label: 'Ventas',
                  value: '${item.metrics.sales}',
                  icon: Icons.sell,
                ),
              ),
              Expanded(
                child: _buildProductStat(
                  label: 'Ingresos',
                  value: '\$${item.metrics.revenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                ),
              ),
              if (item.stock != null)
                Expanded(
                  child: _buildProductStat(
                    label: 'Stock',
                    value: '${item.stock}',
                    icon: Icons.inventory,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Métricas de Pregunta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${item.metrics.responses}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'Respuestas',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColorsUnified.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColorsUnified.textSecondary.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    item.metrics.responses > 0 ? '✓' : '✗',
                    style: TextStyle(
                      fontSize: 24,
                      color: item.metrics.responses > 0 
                          ? AppColorsUnified.success 
                          : AppColorsUnified.error,
                    ),
                  ),
                  Text(
                    item.metrics.responses > 0 ? 'Resuelta' : 'Sin resolver',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColorsUnified.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollMetrics() {
    final votes = item.metrics.votesByOption ?? {};
    final totalVotes = item.metrics.totalVotes ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resultados de Encuesta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$totalVotes votos',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (votes.isNotEmpty)
            ...votes.entries.map((entry) {
              final percentage = totalVotes > 0 
                  ? (entry.value / totalVotes * 100) 
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColorsUnified.backgroundDark,
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEngagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Engagement & Conversión',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildEngagementBar(
                label: 'Engagement Rate',
                value: item.metrics.engagementRate,
                color: AppColorsUnified.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEngagementBar(
                label: 'Conversión',
                value: item.metrics.conversionRate,
                color: AppColorsUnified.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngagementBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: AppColorsUnified.surface,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimelineStat(
            icon: Icons.calendar_today,
            label: 'Creado',
            value: _formatDate(item.createdAt),
          ),
          if (item.updatedAt != null)
            _buildTimelineStat(
              icon: Icons.update,
              label: 'Actualizado',
              value: _formatDate(item.updatedAt!),
            ),
          _buildTimelineStat(
            icon: Icons.access_time,
            label: 'Días activo',
            value: '${item.daysSinceCreated}',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColorsUnified.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (item.type) {
      case InventoryItemType.product:
        return Colors.orange;
      case InventoryItemType.service:
        return Colors.blue;
      case InventoryItemType.offer:
        return Colors.teal;
      case InventoryItemType.request:
        return Colors.purple;
      case InventoryItemType.news:
        return Colors.red;
      case InventoryItemType.poll:
        return Colors.green;
      case InventoryItemType.community:
        return AppColorsUnified.gold;
    }
  }

  IconData _getTypeIcon() {
    switch (item.type) {
      case InventoryItemType.product:
        return Icons.shopping_bag;
      case InventoryItemType.service:
        return Icons.build_circle;
      case InventoryItemType.offer:
        return Icons.local_offer;
      case InventoryItemType.request:
        return Icons.help;
      case InventoryItemType.news:
        return Icons.article;
      case InventoryItemType.poll:
        return Icons.poll;
      case InventoryItemType.community:
        return Icons.public;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
