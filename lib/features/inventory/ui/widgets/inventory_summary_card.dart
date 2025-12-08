import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import '../../models/inventory_item.dart';

/// Tarjeta de resumen del inventario
class InventorySummaryCard extends StatelessWidget {
  final InventorySummary summary;
  final VoidCallback onTap;

  const InventorySummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColorsUnified.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.insights,
                          color: AppColorsUnified.gold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColorsUnified.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Métricas principales
              Row(
                children: [
                  Expanded(
                    child: _buildMainMetric(
                      icon: Icons.visibility,
                      value: _formatNumber(summary.totalViews),
                      label: 'Vistas',
                      color: AppColorsUnified.companyBlue,
                    ),
                  ),
                  Expanded(
                    child: _buildMainMetric(
                      icon: Icons.favorite,
                      value: _formatNumber(summary.totalLikes),
                      label: 'Likes',
                      color: AppColorsUnified.error,
                    ),
                  ),
                  Expanded(
                    child: _buildMainMetric(
                      icon: Icons.chat,
                      value: _formatNumber(summary.totalChats),
                      label: 'Chats',
                      color: AppColorsUnified.success,
                    ),
                  ),
                  Expanded(
                    child: _buildMainMetric(
                      icon: Icons.trending_up,
                      value: '${summary.avgEngagement.toStringAsFixed(1)}%',
                      label: 'Engagement',
                      color: AppColorsUnified.gold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Distribución de tipos
              _buildTypeDistribution(),
              
              // Si hay ingresos, mostrarlos
              if (summary.totalRevenue > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColorsUnified.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppColorsUnified.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ingresos totales: ',
                        style: TextStyle(
                          color: AppColorsUnified.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '\$${_formatNumber(summary.totalRevenue.toInt())}',
                        style: TextStyle(
                          color: AppColorsUnified.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
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

  Widget _buildTypeDistribution() {
    final types = [
      {'icon': Icons.shopping_bag, 'count': summary.totalProducts, 'color': Colors.orange, 'label': 'Productos'},
      {'icon': Icons.build_circle, 'count': summary.totalServices, 'color': Colors.blue, 'label': 'Servicios'},
      {'icon': Icons.help, 'count': summary.totalQuestions, 'color': Colors.purple, 'label': 'Preguntas'},
      {'icon': Icons.poll, 'count': summary.totalPolls, 'color': Colors.green, 'label': 'Encuestas'},
      {'icon': Icons.article, 'count': summary.totalNews, 'color': Colors.red, 'label': 'Noticias'},
      {'icon': Icons.local_offer, 'count': summary.totalOffers, 'color': Colors.teal, 'label': 'Ofertas'},
    ].where((t) => (t['count'] as int) > 0).toList();

    if (types.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (type['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type['icon'] as IconData,
                size: 14,
                color: type['color'] as Color,
              ),
              const SizedBox(width: 4),
              Text(
                '${type['count']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: type['color'] as Color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
