import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yominero/shared/models/connection_request.dart';

abstract class ConnectionRepository {
  Future<void> sendConnectionRequest(String receiverId, {String? message});
  Future<void> acceptConnectionRequest(String requestId);
  Future<void> rejectConnectionRequest(String requestId);
  Future<void> cancelConnectionRequest(String requestId);
  Future<List<ConnectionRequest>> getPendingRequestsReceived();
  Future<List<ConnectionRequest>> getPendingRequestsSent();
  Future<List<Connection>> getUserConnections();
  Future<bool> areUsersConnected(String userId1, String userId2);
  Future<ConnectionRequest?> getPendingRequestBetweenUsers(String userId1, String userId2);
}

class SupabaseConnectionRepository implements ConnectionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> sendConnectionRequest(String receiverId, {String? message}) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    // Verificar que no existe ya una solicitud pendiente o una conexión
    final existingRequest = await getPendingRequestBetweenUsers(currentUserId, receiverId);
    if (existingRequest != null) {
      throw Exception('Ya existe una solicitud pendiente con este usuario');
    }

    final isConnected = await areUsersConnected(currentUserId, receiverId);
    if (isConnected) {
      throw Exception('Ya estás conectado con este usuario');
    }

    await _supabase.from('connection_requests').insert({
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'message': message,
      'status': 'pending',
    });
  }

  @override
  Future<void> acceptConnectionRequest(String requestId) async {
    await _supabase
        .from('connection_requests')
        .update({'status': 'accepted'})
        .eq('id', requestId);
  }

  @override
  Future<void> rejectConnectionRequest(String requestId) async {
    await _supabase
        .from('connection_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }

  @override
  Future<void> cancelConnectionRequest(String requestId) async {
    await _supabase
        .from('connection_requests')
        .delete()
        .eq('id', requestId);
  }

  @override
  Future<List<ConnectionRequest>> getPendingRequestsReceived() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _supabase
        .from('connection_requests')
        .select('''
          *,
          sender:sender_id(
            name,
            username,
            profile_image_url
          )
        ''')
        .eq('receiver_id', currentUserId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final sender = json['sender'] as Map<String, dynamic>?;
      return ConnectionRequest.fromJson({
        ...json,
        'sender_name': sender?['name'],
        'sender_username': sender?['username'],
        'sender_profile_image': sender?['profile_image_url'],
      });
    }).toList();
  }

  @override
  Future<List<ConnectionRequest>> getPendingRequestsSent() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _supabase
        .from('connection_requests')
        .select('''
          *,
          receiver:receiver_id(
            name,
            username,
            profile_image_url
          )
        ''')
        .eq('sender_id', currentUserId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final receiver = json['receiver'] as Map<String, dynamic>?;
      return ConnectionRequest.fromJson({
        ...json,
        'receiver_name': receiver?['name'],
        'receiver_username': receiver?['username'],
        'receiver_profile_image': receiver?['profile_image_url'],
      });
    }).toList();
  }

  @override
  Future<List<Connection>> getUserConnections() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _supabase
        .from('connections')
        .select('''
          *,
          user1:user1_id(name, username, profile_image_url),
          user2:user2_id(name, username, profile_image_url)
        ''')
        .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final user1 = json['user1'] as Map<String, dynamic>?;
      final user2 = json['user2'] as Map<String, dynamic>?;
      return Connection.fromJson({
        ...json,
        'user1_name': user1?['name'],
        'user1_username': user1?['username'],
        'user1_profile_image': user1?['profile_image_url'],
        'user2_name': user2?['name'],
        'user2_username': user2?['username'],
        'user2_profile_image': user2?['profile_image_url'],
      });
    }).toList();
  }

  @override
  Future<bool> areUsersConnected(String userId1, String userId2) async {
    final orderedIds = [userId1, userId2]..sort();
    
    final response = await _supabase
        .from('connections')
        .select('id')
        .eq('user1_id', orderedIds[0])
        .eq('user2_id', orderedIds[1])
        .maybeSingle();

    return response != null;
  }

  @override
  Future<ConnectionRequest?> getPendingRequestBetweenUsers(String userId1, String userId2) async {
    // Buscar solicitud pendiente en cualquier dirección
    final response = await _supabase
        .from('connection_requests')
        .select()
        .eq('status', 'pending')
        .or('and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)')
        .maybeSingle();

    if (response == null) return null;
    return ConnectionRequest.fromJson(response);
  }
}
