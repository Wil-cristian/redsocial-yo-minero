import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/theme/app_colors_unified.dart';

class RequestsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const RequestsPage({super.key, this.currentUser});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String get _userType => widget.currentUser?['accountType'] ?? 'individual';
  int? _hoveredCardIndex;

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
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
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
              userColor.withOpacity(0.1),
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
            color: AppColors.textSecondary.withOpacity(0.5),
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
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, {required bool isPending}) {
    // ignore: unused_local_variable
    final userColor = _getUserColor();
    final isHovered = _hoveredCardIndex == request['id'].hashCode;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCardIndex = request['id'].hashCode),
      onExit: (_) => setState(() => _hoveredCardIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isHovered ? -6 : 0, 0),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsUnified.pureWhite,
              isHovered ? AppColorsUnified.grey50 : AppColorsUnified.pureWhite,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHovered 
                ? AppColorsUnified.gold.withOpacity(0.4)
                : AppColorsUnified.grey200,
            width: isHovered ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? AppColorsUnified.gold.withOpacity(0.2)
                  : AppColorsUnified.shadowMedium,
              blurRadius: isHovered ? 28 : 12,
              spreadRadius: isHovered ? 3 : 0,
              offset: Offset(0, isHovered ? 10 : 4),
            ),
            if (isHovered)
              BoxShadow(
                color: AppColorsUnified.goldBright.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showRequestDetails(request),
            splashColor: AppColorsUnified.gold.withOpacity(0.1),
            highlightColor: AppColorsUnified.gold.withOpacity(0.05),
            child: Column(
              children: [
                // Header con efecto shimmer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorsUnified.goldHighlight.withOpacity(0.15),
                        AppColorsUnified.grey50,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColorsUnified.gold.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Ícono animado con pulso
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 2000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1.0 + (0.05 * (value % 1)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: isHovered
                                    ? AppColorsUnified.goldRadialGradient
                                    : RadialGradient(
                                        colors: [
                                          AppColorsUnified.gold.withOpacity(0.15),
                                          AppColorsUnified.gold.withOpacity(0.05),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColorsUnified.gold.withOpacity(isHovered ? 0.4 : 0.2),
                                  width: isHovered ? 2 : 1.5,
                                ),
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color: AppColorsUnified.gold.withOpacity(0.3),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                _getRequestIcon(request['type']),
                                color: isHovered ? AppColorsUnified.goldShadow : AppColorsUnified.gold,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: isHovered ? 17 : 16,
                                color: AppColorsUnified.textPrimary,
                                height: 1.3,
                              ),
                              child: Text(request['title']),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 16,
                                  color: AppColorsUnified.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  request['requester'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColorsUnified.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isPending) 
                        _buildInteractivePriorityChip(request['priority'], isHovered)
                      else 
                        _buildInteractiveStatusChip(request['status'], isHovered),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['description'],
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColorsUnified.textSecondary,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColorsUnified.grey100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColorsUnified.grey200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppColorsUnified.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(request['date']),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColorsUnified.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isHovered) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isHovered ? 1.0 : 0.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColorsUnified.goldHighlight,
                                        AppColorsUnified.goldBright.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColorsUnified.gold.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app_rounded,
                                        size: 16,
                                        color: AppColorsUnified.goldShadow,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Ver detalles',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColorsUnified.goldDeep,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions con efectos premium
                if (isPending)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColorsUnified.grey50,
                          AppColorsUnified.pureWhite,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      border: Border(
                        top: BorderSide(
                          color: AppColorsUnified.grey200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInteractiveActionButton(
                            label: 'Rechazar',
                            icon: Icons.close_rounded,
                            color: AppColorsUnified.error,
                            onTap: () => _rejectRequest(request['id']),
                            isSecondary: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInteractiveActionButton(
                            label: 'Aceptar',
                            icon: Icons.check_rounded,
                            color: AppColorsUnified.success,
                            onTap: () => _acceptRequest(request['id']),
                            isSecondary: false,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractivePriorityChip(String priority, bool parentHovered) {
    Color chipColor;
    IconData chipIcon;
    
    switch (priority) {
      case 'high':
        chipColor = AppColorsUnified.error;
        chipIcon = Icons.priority_high_rounded;
        break;
      case 'medium':
        chipColor = AppColorsUnified.warning;
        chipIcon = Icons.remove_rounded;
        break;
      case 'low':
        chipColor = AppColorsUnified.success;
        chipIcon = Icons.arrow_downward_rounded;
        break;
      default:
        chipColor = AppColorsUnified.grey400;
        chipIcon = Icons.help_outline_rounded;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, pulseValue, child) {
        final pulse = (pulseValue * 2 * 3.14159);
        final scale = 1.0 + (0.04 * (1 + (pulse % (2 * 3.14159)) / (2 * 3.14159)));
        
        return Transform.scale(
          scale: parentHovered ? scale : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: parentHovered
                    ? [
                        chipColor.withOpacity(0.25),
                        chipColor.withOpacity(0.15),
                      ]
                    : [
                        chipColor.withOpacity(0.15),
                        chipColor.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: chipColor.withOpacity(parentHovered ? 0.5 : 0.3),
                width: parentHovered ? 2 : 1.5,
              ),
              boxShadow: parentHovered
                  ? [
                      BoxShadow(
                        color: chipColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  chipIcon,
                  size: parentHovered ? 18 : 16,
                  color: chipColor,
                ),
                const SizedBox(width: 6),
                Text(
                  priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: parentHovered ? 13 : 12,
                    fontWeight: FontWeight.w700,
                    color: chipColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveStatusChip(String status, bool parentHovered) {
    Color chipColor;
    IconData chipIcon;
    
    switch (status) {
      case 'accepted':
        chipColor = AppColorsUnified.success;
        chipIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        chipColor = AppColorsUnified.error;
        chipIcon = Icons.cancel_rounded;
        break;
      case 'completed':
        chipColor = AppColorsUnified.gold;
        chipIcon = Icons.verified_rounded;
        break;
      default:
        chipColor = AppColorsUnified.grey400;
        chipIcon = Icons.pending_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: parentHovered
              ? [
                  chipColor.withOpacity(0.25),
                  chipColor.withOpacity(0.15),
                ]
              : [
                  chipColor.withOpacity(0.15),
                  chipColor.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withOpacity(parentHovered ? 0.5 : 0.3),
          width: parentHovered ? 2 : 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: parentHovered ? 18 : 16,
            color: chipColor,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: parentHovered ? 13 : 12,
              fontWeight: FontWeight.w700,
              color: chipColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSecondary,
  }) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setLocalState(() => isHovered = true),
          onExit: (_) => setLocalState(() => isHovered = false),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, pulseValue, child) {
              final pulse = !isSecondary && !isHovered
                  ? (1.0 + 0.06 * (pulseValue % 1))
                  : 1.0;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                transform: Matrix4.identity()
                  ..scale(isHovered ? 1.03 : 1.0)
                  ..scale(pulse),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(14),
                    splashColor: color.withOpacity(0.3),
                    highlightColor: color.withOpacity(0.2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSecondary
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isHovered
                                    ? [
                                        color,
                                        Color.from(
                                          alpha: color.a,
                                          red: (color.r * 0.8).clamp(0.0, 1.0),
                                          green: (color.g * 0.8).clamp(0.0, 1.0),
                                          blue: (color.b * 0.8).clamp(0.0, 1.0),
                                        ),
                                      ]
                                    : [
                                        color.withOpacity(0.9),
                                        color,
                                      ],
                              ),
                        color: isSecondary
                            ? (isHovered ? color.withOpacity(0.1) : Colors.transparent)
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isHovered ? color : color.withOpacity(0.5),
                          width: isSecondary ? (isHovered ? 2.5 : 2) : 0,
                        ),
                        boxShadow: !isSecondary && isHovered
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : !isSecondary
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            transform: Matrix4.identity()
                              ..scale(isHovered ? 1.15 : 1.0),
                            child: Icon(
                              icon,
                              color: isSecondary
                                  ? (isHovered ? color : color.withOpacity(0.8))
                                  : AppColorsUnified.pureWhite,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: isHovered ? 16 : 15,
                              fontWeight: isHovered ? FontWeight.w800 : FontWeight.w700,
                              color: isSecondary
                                  ? (isHovered ? color : color.withOpacity(0.8))
                                  : AppColorsUnified.pureWhite,
                              letterSpacing: 0.6,
                            ),
                            child: Text(label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              _getRequestIcon(request['type']),
              color: AppColorsUnified.gold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                request['title'],
                style: const TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitante:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColorsUnified.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request['requester'],
              style: const TextStyle(
                color: AppColorsUnified.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColorsUnified.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request['description'],
              style: const TextStyle(
                color: AppColorsUnified.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fecha:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColorsUnified.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(request['date']),
              style: const TextStyle(
                color: AppColorsUnified.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: AppColorsUnified.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
                SnackBar(
                  content: const Text('Solicitud aceptada exitosamente'),
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
                SnackBar(
                  content: const Text('Solicitud rechazada'),
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