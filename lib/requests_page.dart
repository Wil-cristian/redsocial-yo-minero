import 'package:flutter/material.dart';
import 'core/theme/colors.dart';

class RequestsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const RequestsPage({super.key, this.currentUser});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String get _userType => widget.currentUser?['accountType'] ?? 'individual';

  // Datos de ejemplo para solicitudes
  final List<Map<String, dynamic>> _pendingRequests = [
    {
      'id': '1',
      'title': 'Proyecto de Exploración Aurífera',
      'description': 'Solicitud para unirse al proyecto de exploración en la región de Antioquia',
      'requester': 'María González',
      'type': 'project_join',
      'date': '2025-10-18',
      'priority': 'high',
    },
    {
      'id': '2',
      'title': 'Servicio de Análisis Geológico',
      'description': 'Solicitud de cotización para análisis de muestras minerales',
      'requester': 'Carlos Minería S.A.S',
      'type': 'service_quote',
      'date': '2025-10-19',
      'priority': 'medium',
    },
    {
      'id': '3',
      'title': 'Colaboración Técnica',
      'description': 'Propuesta de colaboración para optimización de procesos extractivos',
      'requester': 'Juan Pérez',
      'type': 'collaboration',
      'date': '2025-10-17',
      'priority': 'low',
    },
  ];

  final List<Map<String, dynamic>> _acceptedRequests = [
    {
      'id': '4',
      'title': 'Mantenimiento de Equipos',
      'description': 'Servicio de mantenimiento para maquinaria pesada completado',
      'requester': 'Extractora del Norte',
      'type': 'service_completed',
      'date': '2025-10-15',
      'status': 'completed',
    },
    {
      'id': '5',
      'title': 'Consultoría Ambiental',
      'description': 'Asesoría en cumplimiento de normativas ambientales',
      'requester': 'EcoMinería',
      'type': 'consulting',
      'date': '2025-10-10',
      'status': 'in_progress',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getUserColor() {
    switch (_userType) {
      case 'individual':
        return AppColors.primary;
      case 'worker':
        return AppColors.secondary;
      case 'company':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userColor = _getUserColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        backgroundColor: userColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Pendientes',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Aceptadas',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Historial',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              userColor.withValues(alpha: 0.1),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPendingTab(),
            _buildAcceptedTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewRequestDialog(),
        backgroundColor: userColor,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Solicitud'),
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_actions,
        title: 'No hay solicitudes pendientes',
        subtitle: 'Las nuevas solicitudes aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _buildRequestCard(request, isPending: true);
      },
    );
  }

  Widget _buildAcceptedTab() {
    if (_acceptedRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No hay solicitudes aceptadas',
        subtitle: 'Las solicitudes aceptadas aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _acceptedRequests.length,
      itemBuilder: (context, index) {
        final request = _acceptedRequests[index];
        return _buildRequestCard(request, isPending: false);
      },
    );
  }

  Widget _buildHistoryTab() {
    return _buildEmptyState(
      icon: Icons.history,
      title: 'Historial de solicitudes',
      subtitle: 'Aquí aparecerán todas las solicitudes completadas y archivadas',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, {required bool isPending}) {
    final userColor = _getUserColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: userColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: userColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getRequestIcon(request['type']),
                    color: userColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'De: ${request['requester']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending) _buildPriorityChip(request['priority']),
                if (!isPending) _buildStatusChip(request['status']),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['description'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(request['date']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          if (isPending)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptRequest(request['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    String label;
    
    switch (priority) {
      case 'high':
        color = AppColors.error;
        label = 'Alta';
        break;
      case 'medium':
        color = AppColors.warning;
        label = 'Media';
        break;
      case 'low':
        color = AppColors.info;
        label = 'Baja';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Normal';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'completed':
        color = AppColors.success;
        label = 'Completado';
        break;
      case 'in_progress':
        color = AppColors.info;
        label = 'En progreso';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Desconocido';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getRequestIcon(String type) {
    switch (type) {
      case 'project_join':
        return Icons.group_add;
      case 'service_quote':
        return Icons.request_quote;
      case 'collaboration':
        return Icons.handshake;
      case 'service_completed':
        return Icons.build;
      case 'consulting':
        return Icons.psychology;
      default:
        return Icons.mail;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Hoy';
      } else if (difference == 1) {
        return 'Ayer';
      } else if (difference < 7) {
        return 'Hace $difference días';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _acceptRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aceptar Solicitud'),
        content: const Text('¿Estás seguro de que quieres aceptar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingRequests.removeWhere((req) => req['id'] == requestId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud aceptada exitosamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Solicitud'),
        content: const Text('¿Estás seguro de que quieres rechazar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingRequests.removeWhere((req) => req['id'] == requestId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud rechazada'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _showNewRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Solicitud'),
        content: const Text('Esta funcionalidad estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}