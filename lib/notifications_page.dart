import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/shared/models/notification_model.dart';
import 'package:yominero/features/notifications/data/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  
  final NotificationsRepository _repository = NotificationsRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  RealtimeChannel? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadNotifications();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _realtimeSubscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final notifications = await _repository.getUserNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error al cargar notificaciones: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupRealtimeSubscription() {
    _realtimeSubscription = _repository.subscribeToNotifications((notification) {
      setState(() {
        _notifications.insert(0, notification);
      });
    });
  }

  List<NotificationModel> get _filteredNotifications {
    var filtered = _notifications;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) =>
        n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n.body.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    final currentTab = _tabController.index;
    final typeMap = {
      1: NotificationType.serviceRequest,
      2: NotificationType.message,
      3: NotificationType.serviceRequest,
      4: null, // sistema - no hay tipo específico, usar notificaciones generales
    };
    
    if (currentTab > 0 && typeMap[currentTab] != null) {
      filtered = filtered.where((n) => n.type == typeMap[currentTab]).toList();
    }
    
    return filtered;
  }

  int _getUnreadCount(NotificationType? type) {
    if (type == null) return _notifications.where((n) => !n.isRead).length;
    return _notifications.where((n) => n.type == type && !n.isRead).length;
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.serviceRequest:
        return AppColorsUnified.orangeMedium;
      case NotificationType.message:
        return AppColorsUnified.gold;
      case NotificationType.groupInvite:
        return AppColorsUnified.orange;
      case NotificationType.productLiked:
        return AppColorsUnified.gold;
      case NotificationType.newFollower:
        return AppColorsUnified.companyBlue;
      case NotificationType.comment:
        return AppColorsUnified.orangeLight;
      case NotificationType.mention:
        return AppColorsUnified.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.pureWhite,
        elevation: 1,
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color: AppColorsUnified.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'mark_all_read') {
                final success = await _repository.markAllAsRead();
                if (success) {
                  await _loadNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
                    );
                  }
                }
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
                        onPressed: () async {
                          // Eliminar todas las notificaciones
                          for (var notif in _notifications) {
                            await _repository.deleteNotification(notif.id);
                          }
                          await _loadNotifications();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Limpiar', style: TextStyle(color: AppColorsUnified.error)),
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
                    Icon(Icons.delete_outline, size: 20, color: AppColorsUnified.error),
                    SizedBox(width: 12),
                    Text('Limpiar todo', style: TextStyle(color: AppColorsUnified.error)),
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
                    fillColor: AppColorsUnified.background,
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
                labelColor: AppColorsUnified.orange,
                unselectedLabelColor: AppColorsUnified.textSecondary,
                indicatorColor: AppColorsUnified.orange,
                indicatorWeight: 3,
                onTap: (_) => setState(() {}),
                tabs: [
                  _buildTab('Todas', Icons.notifications, _getUnreadCount(null)),
                  _buildTab('Proyectos', Icons.work, 0),
                  _buildTab('Mensajes', Icons.message, _getUnreadCount(NotificationType.message)),
                  _buildTab('Servicios', Icons.engineering, _getUnreadCount(NotificationType.serviceRequest)),
                  _buildTab('Sistema', Icons.settings, 0),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotifications.isEmpty
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
                gradient: LinearGradient(
                  colors: [
                    AppColorsUnified.orange,
                    AppColorsUnified.orangeLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: TextStyle(
                  color: AppColorsUnified.pureWhite,
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

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    final bool isImportant = !notification.isRead;
    final categoryColor = _getNotificationColor(notification.type);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
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
                : AppColorsUnified.fade(AppColorsUnified.textSecondary, 0.1),
            blurRadius: isImportant ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await _repository.markAsRead(notification.id);
            await _loadNotifications();
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
                        notification.icon,
                        color: isImportant ? AppColorsUnified.pureWhite : categoryColor,
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
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isImportant ? AppColorsUnified.charcoal : AppColorsUnified.charcoal,
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
                            notification.body,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColorsUnified.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimeAgo(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2),
                                ),
                              ),
                              const Spacer(),
                              _buildTypeChip(notification.type),
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
                              SnackBar(content: Text('Responder a: ${notification.title}')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Guardar',
                          Icons.bookmark_outline,
                          AppColorsUnified.textSecondary,
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
                        onPressed: () async {
                          await _repository.deleteNotification(notification.id);
                          await _loadNotifications();
                        },
                        color: AppColorsUnified.textSecondary,
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return 'Hace ${(difference.inDays / 7).floor()} semanas';
    }
  }

  Widget _buildTypeChip(NotificationType type) {
    final categoryColor = _getNotificationColor(type);
    String label;
    
    switch (type) {
      case NotificationType.message:
        label = 'Mensaje';
        break;
      case NotificationType.groupInvite:
        label = 'Grupo';
        break;
      case NotificationType.productLiked:
        label = 'Producto';
        break;
      case NotificationType.serviceRequest:
        label = 'Servicio';
        break;
      case NotificationType.newFollower:
        label = 'Seguidor';
        break;
      case NotificationType.comment:
        label = 'Comentario';
        break;
      case NotificationType.mention:
        label = 'Mención';
        break;
    }
    
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
            color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando tengas nuevas notificaciones\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
