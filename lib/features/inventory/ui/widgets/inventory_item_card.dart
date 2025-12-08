import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import '../../models/inventory_item.dart';

/// Tarjeta para mostrar un item del inventario
class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onMetricsTap;
  final Function(InventoryItemStatus) onStatusChange;
  final VoidCallback onDelete;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMetricsTap,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColorsUnified.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getTypeColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen o tipo
            _buildHeader(),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y estado
                  _buildTitleSection(),
                  
                  const SizedBox(height: 8),
                  
                  // Descripción corta
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Métricas rápidas
                  _buildQuickMetrics(),
                  
                  const SizedBox(height: 12),
                  
                  // Acciones
                  _buildActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (item.images.isNotEmpty) {
      return Stack(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              item.images.first,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildTypeBanner(),
            ),
          ),
          
          // Badge de tipo
          Positioned(
            top: 12,
            left: 12,
            child: _buildTypeBadge(),
          ),
          
          // Badge de precio si aplica
          if (item.price != null)
            Positioned(
              top: 12,
              right: 12,
              child: _buildPriceBadge(),
            ),
            
          // Indicador de múltiples imágenes
          if (item.images.length > 1)
            Positioned(
              bottom: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${item.images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    
    return _buildTypeBanner();
  }

  Widget _buildTypeBanner() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor().withOpacity(0.8),
            _getTypeColor().withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getTypeColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            item.typeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorsUnified.success,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '\$${item.price!.toStringAsFixed(item.price! % 1 == 0 ? 0 : 2)} ${item.currency ?? ''}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColorsUnified.textSecondary,
                    ),
                  ),
                  if (item.stock != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.inventory_2,
                      size: 12,
                      color: item.stock! > 0 
                          ? AppColorsUnified.success 
                          : AppColorsUnified.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${item.stock}',
                      style: TextStyle(
                        fontSize: 11,
                        color: item.stock! > 0 
                            ? AppColorsUnified.success 
                            : AppColorsUnified.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;
    
    switch (item.status) {
      case InventoryItemStatus.active:
        color = AppColorsUnified.success;
        icon = Icons.check_circle;
        break;
      case InventoryItemStatus.sold:
        color = AppColorsUnified.gold;
        icon = Icons.sell;
        break;
      case InventoryItemStatus.expired:
        color = AppColorsUnified.error;
        icon = Icons.timer_off;
        break;
      case InventoryItemStatus.paused:
        color = AppColorsUnified.warning;
        icon = Icons.pause_circle;
        break;
      case InventoryItemStatus.archived:
        color = AppColorsUnified.textSecondary;
        icon = Icons.archive;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            item.statusLabel,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetrics() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.visibility,
            value: '${item.metrics.views}',
            label: 'Vistas',
          ),
          _buildMetricItem(
            icon: Icons.favorite,
            value: '${item.metrics.likes}',
            label: 'Likes',
            color: AppColorsUnified.error,
          ),
          _buildMetricItem(
            icon: Icons.comment,
            value: '${item.metrics.comments}',
            label: 'Comentarios',
            color: AppColorsUnified.companyBlue,
          ),
          _buildMetricItem(
            icon: Icons.chat_bubble,
            value: '${item.metrics.chats}',
            label: 'Chats',
            color: AppColorsUnified.success,
          ),
          if (item.type == InventoryItemType.request)
            _buildMetricItem(
              icon: Icons.question_answer,
              value: '${item.metrics.responses}',
              label: 'Respuestas',
              color: Colors.purple,
            ),
          if (item.type == InventoryItemType.poll && item.metrics.totalVotes != null)
            _buildMetricItem(
              icon: Icons.how_to_vote,
              value: '${item.metrics.totalVotes}',
              label: 'Votos',
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? AppColorsUnified.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
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

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // Engagement indicator
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: _getEngagementColor(),
              ),
              const SizedBox(width: 4),
              Text(
                '${item.metrics.engagementRate.toStringAsFixed(1)}% engagement',
                style: TextStyle(
                  fontSize: 12,
                  color: _getEngagementColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Botón de métricas
        IconButton(
          onPressed: onMetricsTap,
          icon: Icon(
            Icons.bar_chart,
            color: AppColorsUnified.gold,
            size: 20,
          ),
          tooltip: 'Ver métricas',
        ),
        
        // Menú de acciones
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppColorsUnified.textSecondary,
          ),
          color: AppColorsUnified.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: _buildMenuItem(Icons.edit, 'Editar'),
            ),
            if (item.status == InventoryItemStatus.active)
              PopupMenuItem(
                value: 'pause',
                child: _buildMenuItem(Icons.pause, 'Pausar'),
              ),
            if (item.status == InventoryItemStatus.paused)
              PopupMenuItem(
                value: 'activate',
                child: _buildMenuItem(Icons.play_arrow, 'Activar'),
              ),
            if (item.isSellable && item.status != InventoryItemStatus.sold)
              PopupMenuItem(
                value: 'sold',
                child: _buildMenuItem(Icons.sell, 'Marcar vendido'),
              ),
            PopupMenuItem(
              value: 'share',
              child: _buildMenuItem(Icons.share, 'Compartir'),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'archive',
              child: _buildMenuItem(Icons.archive, 'Archivar', isDestructive: true),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'pause':
                onStatusChange(InventoryItemStatus.paused);
                break;
              case 'activate':
                onStatusChange(InventoryItemStatus.active);
                break;
              case 'sold':
                onStatusChange(InventoryItemStatus.sold);
                break;
              case 'archive':
                onDelete();
                break;
              case 'edit':
                // TODO: Navegar a edición
                break;
              case 'share':
                // TODO: Compartir
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isDestructive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDestructive ? AppColorsUnified.error : AppColorsUnified.textPrimary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDestructive ? AppColorsUnified.error : AppColorsUnified.textPrimary,
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

  Color _getEngagementColor() {
    final rate = item.metrics.engagementRate;
    if (rate >= 10) return AppColorsUnified.success;
    if (rate >= 5) return AppColorsUnified.gold;
    if (rate >= 2) return AppColorsUnified.warning;
    return AppColorsUnified.textSecondary;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Hace ${diff.inMinutes} min';
      }
      return 'Hace ${diff.inHours}h';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} sem';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
