import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';

/// Página de notificaciones mejorada con categorías, filtros y animaciones
class NotificationsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const NotificationsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'title': 'Nueva oportunidad de proyecto',
      'description': 'Un nuevo proyecto minero está disponible en tu área',
      'icon': Icons.work,
      'category': 'proyectos',
      'time': 'Hace 2 horas',
      'read': false,
    },
    {
      'id': 2,
      'title': 'Proyecto aceptado',
      'description': 'Tu propuesta para "Extracción Norte" ha sido aceptada',
      'icon': Icons.check_circle,
      'category': 'proyectos',
      'time': 'Hace 3 horas',
      'read': false,
    },
    {
      'id': 3,
      'title': 'Miembro nuevo en tu grupo',
      'description': 'Juan Pérez se ha unido al grupo "Minería en Antioquia"',
      'icon': Icons.person_add,
      'category': 'sistema',
      'time': 'Hace 4 horas',
      'read': false,
    },
    {
      'id': 4,
      'title': 'Mensaje en tu chat',
      'description': 'Carlos Morales: ¿Estás disponible para el proyecto?',
      'icon': Icons.message,
      'category': 'mensajes',
      'time': 'Hace 6 horas',
      'read': true,
    },
    {
      'id': 5,
      'title': 'Servicio solicitado',
      'description': 'Tu servicio de perforación ha sido solicitado',
      'icon': Icons.engineering,
      'category': 'servicios',
      'time': 'Hace 8 horas',
      'read': false,
    },
    {
      'id': 6,
      'title': 'Nuevo mensaje de María González',
      'description': 'Necesito cotización para servicio de topografía',
      'icon': Icons.chat_bubble,
      'category': 'mensajes',
      'time': 'Hace 10 horas',
      'read': true,
    },
    {
      'id': 7,
      'title': 'Actualización de perfil',
      'description': 'Tu perfil ha sido verificado correctamente',
      'icon': Icons.verified_user,
      'category': 'sistema',
      'time': 'Hace 1 día',
      'read': true,
    },
    {
      'id': 8,
      'title': 'Servicio completado',
      'description': 'El cliente marcó tu servicio como completado. Calificación: 5 estrellas',
      'icon': Icons.star,
      'category': 'servicios',
      'time': 'Hace 2 días',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    var filtered = notifications;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) =>
        n['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n['description'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    final currentTab = _tabController.index;
    if (currentTab == 1) filtered = filtered.where((n) => n['category'] == 'proyectos').toList();
    if (currentTab == 2) filtered = filtered.where((n) => n['category'] == 'mensajes').toList();
    if (currentTab == 3) filtered = filtered.where((n) => n['category'] == 'servicios').toList();
    if (currentTab == 4) filtered = filtered.where((n) => n['category'] == 'sistema').toList();
    
    return filtered;
  }

  int _getUnreadCount(String? category) {
    if (category == null) return notifications.where((n) => !n['read']).length;
    return notifications.where((n) => n['category'] == category && !n['read']).length;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'proyectos':
        return DashboardColors.primary;
      case 'servicios':
        return DashboardColors.emerald;
      case 'mensajes':
        return DashboardColors.accent;
      case 'sistema':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                setState(() {
                  for (var notif in notifications) {
                    notif['read'] = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
                );
              } else if (value == 'clear_all') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpiar notificaciones'),
                    content: const Text('¿Estás seguro de que deseas eliminar todas las notificaciones?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            notifications.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 12),
                    Text('Marcar todo como leído'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Limpiar todo', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar notificaciones...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              // Tabs con badges
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: DashboardColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: DashboardColors.primary,
                indicatorWeight: 3,
                onTap: (_) => setState(() {}),
                tabs: [
                  _buildTab('Todas', Icons.notifications, _getUnreadCount(null)),
                  _buildTab('Proyectos', Icons.work, _getUnreadCount('proyectos')),
                  _buildTab('Mensajes', Icons.message, _getUnreadCount('mensajes')),
                  _buildTab('Servicios', Icons.engineering, _getUnreadCount('servicios')),
                  _buildTab('Sistema', Icons.settings, _getUnreadCount('sistema')),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _filteredNotifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeOut,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildNotificationItem(_filteredNotifications[index], index),
                );
              },
            ),
    );
  }

  Widget _buildTab(String label, IconData icon, int unreadCount) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
          if (unreadCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    DashboardColors.emerald,
                    DashboardColors.emeraldLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final bool isImportant = !notification['read'];
    final String category = notification['category'];
    final categoryColor = _getCategoryColor(category);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isImportant 
            ? Border.all(
                color: categoryColor.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isImportant
                ? categoryColor.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: isImportant ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              notification['read'] = true;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: isImportant
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor.withValues(alpha: 0.8),
                                  categoryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            )
                          : BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: isImportant ? Colors.white : categoryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isImportant ? Colors.black : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              if (isImportant)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: categoryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                notification['time'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const Spacer(),
                              _buildCategoryChip(category),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Acciones rápidas
                if (isImportant) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Responder',
                          Icons.reply,
                          categoryColor,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Responder a: ${notification['title']}')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Guardar',
                          Icons.bookmark_outline,
                          Colors.grey,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notificación guardada')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            final originalIndex = notifications.indexOf(notification);
                            if (originalIndex != -1) {
                              notifications.removeAt(originalIndex);
                            }
                          });
                        },
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final categoryColor = _getCategoryColor(category);
    String label = category[0].toUpperCase() + category.substring(1);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: categoryColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando tengas nuevas notificaciones\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
