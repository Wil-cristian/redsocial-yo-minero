import 'package:flutter/material.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// 🎯 CARD UNIFICADO DE SERVICIOS
/// 
/// Componente reutilizable para mostrar servicios de forma consistente
/// en todas las páginas de la aplicación.
/// 
/// DISEÑO UNIFICADO v2.0:
/// - 90% Blanco perla (#FFFFFF, #FFF5EE)
/// - 8% Negro/gris para texto
/// - 2% Oro (#D4AF37) para acentos premium
/// 
/// CONTEXTOS SOPORTADOS:
/// - 'browse': Navegar servicios disponibles (con contactar)
/// - 'manage': Mis servicios (con editar/eliminar)
/// - 'detail': Vista detallada (sin acciones rápidas)
/// - 'company_request': Servicios pedidos por empresa (con estado)
enum ServiceCardContext {
  browse,
  manage,
  detail,
  companyRequest,
}

class ServiceCard extends StatelessWidget {
  final Service service;
  final ServiceCardContext context;
  final int index;
  
  // Callbacks para acciones contextuales
  final VoidCallback? onTap;
  final VoidCallback? onContact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewStats;
  
  // Para company_request context
  final String? requestStatus;  // 'Pendiente', 'En Progreso', 'Completado', 'Cancelado'
  
  const ServiceCard({
    super.key,
    required this.service,
    required this.context,
    this.index = 0,
    this.onTap,
    this.onContact,
    this.onEdit,
    this.onDelete,
    this.onViewStats,
    this.requestStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColorsUnified.grey300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorsUnified.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono y categoría
            _buildHeader(),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del servicio
                  Text(
                    service.name,
                    style: TextStyle(
                      color: AppColorsUnified.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Categoría con badge oro
                  _buildCategoryBadge(),
                  
                  const SizedBox(height: 12),
                  
                  // Descripción
                  Text(
                    service.description,
                    style: TextStyle(
                      color: AppColorsUnified.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  if (service.tags.isNotEmpty) ...[
                    _buildTags(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Footer con precio, proveedor y acciones
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header con ícono de servicio y badge de precio
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.grey200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColorsUnified.grey300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícono con gradiente oro
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColorsUnified.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(service.category),
              color: AppColorsUnified.textPrimary,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Información básica
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.category,
                  style: TextStyle(
                    color: AppColorsUnified.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Publicado hace ${service.timeAgo}',
                  style: TextStyle(
                    color: AppColorsUnified.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Badge de precio
          _buildPriceBadge(),
        ],
      ),
    );
  }

  /// Badge de categoría
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsUnified.grey200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColorsUnified.grey300,
          width: 1,
        ),
      ),
      child: Text(
        service.category,
        style: TextStyle(
          color: AppColorsUnified.gold,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Badge de precio con gradiente oro
  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColorsUnified.goldGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        service.priceDisplay,
        style: TextStyle(
          color: AppColorsUnified.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Tags del servicio
  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: service.tags.take(4).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColorsUnified.grey300,
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Footer con proveedor y acciones contextuales
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        // Divider
        Container(
          height: 1,
          color: AppColorsUnified.grey300,
          margin: const EdgeInsets.only(bottom: 16),
        ),
        
        Row(
          children: [
            // Avatar del proveedor con gradiente oro
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColorsUnified.goldGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (service.providerName?.substring(0, 1) ?? 'P').toUpperCase(),
                  style: TextStyle(
                    color: AppColorsUnified.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Información del proveedor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.providerName ?? 'Proveedor',
                    style: TextStyle(
                      color: AppColorsUnified.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    service.providerAccountType ?? 'Individual',
                    style: TextStyle(
                      color: AppColorsUnified.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Acciones contextuales
            _buildContextActions(context),
          ],
        ),
        
        // Badge de estado para company_request context
        if (this.context == ServiceCardContext.companyRequest && requestStatus != null) ...[
          const SizedBox(height: 12),
          _buildStatusBadge(),
        ],
      ],
    );
  }

  /// Acciones según el contexto
  Widget _buildContextActions(BuildContext context) {
    switch (this.context) {
      case ServiceCardContext.browse:
        // Botón de contactar
        return Container(
          decoration: BoxDecoration(
            gradient: AppColorsUnified.goldGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onContact,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColorsUnified.textPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Contactar',
                      style: TextStyle(
                        color: AppColorsUnified.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case ServiceCardContext.manage:
        // Botones de editar y eliminar
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Editar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColorsUnified.grey200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColorsUnified.grey300,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColorsUnified.textPrimary,
                  size: 18,
                ),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Eliminar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColorsUnified.grey200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColorsUnified.grey300,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColorsUnified.error,
                  size: 18,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        );

      case ServiceCardContext.detail:
        // Sin acciones (vista detallada)
        return const SizedBox.shrink();

      case ServiceCardContext.companyRequest:
        // Botón de ver detalles
        return IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: AppColorsUnified.textSecondary,
            size: 16,
          ),
          onPressed: onTap,
        );
    }
  }

  /// Badge de estado para servicios solicitados
  Widget _buildStatusBadge() {
    Color statusColor;
    switch (requestStatus) {
      case 'Completado':
        statusColor = AppColorsUnified.success;
        break;
      case 'En Progreso':
        statusColor = AppColorsUnified.companyBlue;
        break;
      case 'Pendiente':
        statusColor = AppColorsUnified.warning;
        break;
      case 'Cancelado':
        statusColor = AppColorsUnified.error;
        break;
      default:
        statusColor = AppColorsUnified.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsUnified.fade(statusColor, 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            requestStatus ?? '',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Ícono según categoría
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mantenimiento':
        return Icons.build_circle_outlined;
      case 'consultoría':
        return Icons.psychology_outlined;
      case 'transporte':
        return Icons.local_shipping_outlined;
      case 'seguridad':
        return Icons.security_outlined;
      case 'capacitación':
        return Icons.school_outlined;
      case 'tecnología':
        return Icons.computer_outlined;
      case 'ambiental':
        return Icons.eco_outlined;
      case 'legal':
        return Icons.gavel_outlined;
      default:
        return Icons.work_outline;
    }
  }
}
