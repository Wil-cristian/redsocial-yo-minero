import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/notification_model.dart';

class NotificationsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener todas las notificaciones del usuario actual
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error al obtener notificaciones: $e');
      return [];
    }
  }

  /// Obtener notificaciones no leídas
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error al obtener notificaciones no leídas: $e');
      return [];
    }
  }

  /// Obtener notificaciones por categoría
  Future<List<NotificationModel>> getNotificationsByType(NotificationType type) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final typeString = _notificationTypeToString(type);
      
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('type', typeString)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error al obtener notificaciones por tipo: $e');
      return [];
    }
  }

  /// Marcar notificación como leída
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      return true;
    } catch (e) {
      print('❌ Error al marcar notificación como leída: $e');
      return false;
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<bool> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);

      return true;
    } catch (e) {
      print('❌ Error al marcar todas como leídas: $e');
      return false;
    }
  }

  /// Eliminar una notificación
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      return true;
    } catch (e) {
      print('❌ Error al eliminar notificación: $e');
      return false;
    }
  }

  /// Contar notificaciones no leídas
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('❌ Error al contar notificaciones no leídas: $e');
      return 0;
    }
  }

  /// Contar notificaciones no leídas por tipo
  Future<int> getUnreadCountByType(NotificationType type) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      final typeString = _notificationTypeToString(type);

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('type', typeString)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('❌ Error al contar notificaciones no leídas por tipo: $e');
      return 0;
    }
  }

  /// Suscribirse a cambios en tiempo real de notificaciones
  RealtimeChannel subscribeToNotifications(Function(NotificationModel) onNotification) {
    final userId = _supabase.auth.currentUser?.id;
    
    return _supabase
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = NotificationModel.fromJson(payload.newRecord);
            onNotification(notification);
          },
        )
        .subscribe();
  }

  // Helper para convertir NotificationType a string
  String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return 'message';
      case NotificationType.groupInvite:
        return 'group_invite';
      case NotificationType.productLiked:
        return 'product_liked';
      case NotificationType.serviceRequest:
        return 'service_request';
      case NotificationType.newFollower:
        return 'new_follower';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.mention:
        return 'mention';
    }
  }
}
