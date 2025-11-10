import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/notification_model.dart';
import '../../../core/errors/app_exception.dart';

class NotificationsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _notificationsChannel;

  Future<List<NotificationModel>> getUserNotifications(String userId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al cargar notificaciones: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Error inesperado al cargar notificaciones',
        originalError: e,
      );
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();

      return response.count;
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al obtener contador de no leídas: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Error inesperado al obtener contador',
        originalError: e,
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al marcar como leída: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Error inesperado al marcar notificación',
        originalError: e,
      );
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al marcar todas como leídas: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Error inesperado al marcar todas',
        originalError: e,
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Error al eliminar notificación: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Error inesperado al eliminar',
        originalError: e,
      );
    }
  }

  void subscribeToNotifications(
    String userId,
    void Function(NotificationModel) onNotification,
  ) {
    _notificationsChannel = _supabase.channel('notifications:$userId');

    _notificationsChannel!
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
            onNotification(NotificationModel.fromJson(payload.newRecord));
          },
        )
        .subscribe();
  }

  void unsubscribeFromNotifications() {
    _notificationsChannel?.unsubscribe();
    _notificationsChannel = null;
  }
}
