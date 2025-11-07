import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/conversation.dart';
import '../../../shared/models/message.dart';

class MessagingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _subscriptions = {};

  // ==================== CONVERSATIONS ====================

  Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  Future<Conversation?> getConversation(String userId1, String userId2) async {
    try {
      final sortedIds = [userId1, userId2]..sort();
      
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user1_id', sortedIds[0])
          .eq('user2_id', sortedIds[1])
          .maybeSingle();

      if (response == null) return null;
      return Conversation.fromJson(response);
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  Future<Conversation> createConversation(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from('conversations')
          .insert(Conversation.toInsert(userId1, userId2))
          .select()
          .single();

      return Conversation.fromJson(response);
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  Future<Conversation> getOrCreateConversation(String userId1, String userId2) async {
    final existing = await getConversation(userId1, userId2);
    if (existing != null) return existing;
    return createConversation(userId1, userId2);
  }

  // ==================== MESSAGES ====================

  Future<List<Message>> getConversationMessages(String conversationId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Message.fromJson(json))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final message = Message(
        id: '',
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        messageType: type,
      );

      // NOTA: Los triggers de Supabase actualizan automáticamente:
      // - conversations.last_message_at = NOW()
      // - conversations.unread_count_user1 o unread_count_user2 += 1
      // Ver database/additional_tables.sql -> update_conversation_on_message()
      final response = await _supabase
          .from('messages')
          .insert(message.toInsert())
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      // Marcar mensajes como leídos
      await _supabase
          .from('messages')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      // Update conversation unread count
      final conv = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();
      
      final conversation = Conversation.fromJson(conv);
      
      if (conversation.user1Id == userId) {
        await _supabase
            .from('conversations')
            .update({'unread_count_user1': 0})
            .eq('id', conversationId);
      } else {
        await _supabase
            .from('conversations')
            .update({'unread_count_user2': 0})
            .eq('id', conversationId);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // ==================== REALTIME ====================

  Stream<Message> subscribeToMessages(String conversationId) {
    final controller = StreamController<Message>.broadcast();
    
    final channel = _supabase
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            try {
              final message = Message.fromJson(payload.newRecord);
              controller.add(message);
            } catch (e) {
              print('Error processing realtime message: $e');
            }
          },
        )
        .subscribe();

    _subscriptions['messages:$conversationId'] = channel;

    return controller.stream;
  }

  void unsubscribeFromMessages(String conversationId) {
    final channel = _subscriptions['messages:$conversationId'];
    if (channel != null) {
      _supabase.removeChannel(channel);
      _subscriptions.remove('messages:$conversationId');
    }
  }

  void dispose() {
    for (final channel in _subscriptions.values) {
      _supabase.removeChannel(channel);
    }
    _subscriptions.clear();
  }
}
