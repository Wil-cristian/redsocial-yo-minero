import 'package:flutter/material.dart';
import 'core/theme/dashboard_colors.dart';
import 'core/theme/rich_decorations.dart';

/// Página de notificaciones del usuario
class NotificationsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const NotificationsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'title': 'Nueva oportunidad de proyecto',
      'description': 'Un nuevo proyecto minero está disponible en tu área',
      'icon': Icons.work,
      'color': DashboardColors.cardOrange,
      'time': 'Hace 2 horas',
      'read': false,
    },
    {
      'id': 2,
      'title': 'Miembro nuevo en tu grupo',
      'description': 'Juan Pérez se ha unido al grupo "Minería en Antioquia"',
      'icon': Icons.person_add,
      'color': DashboardColors.cardBlue,
      'time': 'Hace 4 horas',
      'read': false,
    },
    {
      'id': 3,
      'title': 'Mensaje en tu chat',
      'description': 'Carlos Morales: ¿Estás disponible para el proyecto?',
      'icon': Icons.message,
      'color': DashboardColors.cardPink,
      'time': 'Hace 6 horas',
      'read': true,
    },
    {
      'id': 4,
      'title': 'Servicio solicitado',
      'description': 'Tu servicio de perforación ha sido solicitado',
      'icon': Icons.engineering,
      'color': DashboardColors.cardPurple,
      'time': 'Hace 8 horas',
      'read': true,
    },
    {
      'id': 5,
      'title': 'Actualización de perfil',
      'description': 'Tu perfil ha sido verificado correctamente',
      'icon': Icons.verified_user,
      'color': DashboardColors.cardGreen,
      'time': 'Hace 1 día',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),

      // Body
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(notifications[index], index);
              },
            ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final bool isImportant = !notification['read'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isImportant 
            ? Border.all(
                color: DashboardColors.emerald.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isImportant
                ? DashboardColors.emerald.withValues(alpha: 0.15)
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
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.done),
                      title: const Text('Marcar como leído'),
                      onTap: () {
                        setState(() {
                          notification['read'] = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                      title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        setState(() {
                          notifications.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: isImportant
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DashboardColors.emeraldLight,
                              DashboardColors.emerald,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: DashboardColors.emerald.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : BoxDecoration(
                          color: (notification['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: isImportant ? Colors.white : (notification['color'] as Color),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification['read'] ? FontWeight.w500 : FontWeight.bold,
                                color: isImportant ? DashboardColors.sapphireDeep : Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification['read'])
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: DashboardColors.sapphireRadialGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: DashboardColors.sapphire.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí aparecerán tus notificaciones',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
