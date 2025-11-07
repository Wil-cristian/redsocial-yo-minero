import 'package:flutter/foundation.dart';
import 'package:yominero/shared/models/group.dart';
import 'package:yominero/core/groups/group_repository.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';

class SupabaseGroupRepository implements GroupRepository {
  final _supabase = SupabaseService.instance.client;

  @override
  Stream<List<Group>> watchAll() {
    return _supabase
        .from('groups')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Group.fromJson(json)).toList());
  }

  @override
  Future<List<Group>> getAll() async {
    try {
      final response = await _supabase
          .from('groups')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Group.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener grupos: $e');
      return [];
    }
  }

  @override
  Future<Group?> getById(String id) async {
    try {
      final response = await _supabase
          .from('groups')
          .select()
          .eq('id', id)
          .single();

      return Group.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al obtener grupo: $e');
      return null;
    }
  }

  @override
  Future<Group> create({
    required String name,
    required String description,
    Set<String>? tags,
    List<String>? keywords,
    List<String>? interests,
    bool isPrivate = false,
    int? maxMembers,
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final groupData = {
        'creator_id': currentUser.id,
        'name': name,
        'description': description,
        'keywords': keywords ?? (tags != null ? tags.toList() : []),
        'interests': interests ?? [],
        'is_private': isPrivate,
        'max_members': maxMembers,
        'members_count': 1,
      };

      final response = await _supabase
          .from('groups')
          .insert(groupData)
          .select()
          .single();

      await _addMemberToGroup(response['id'], currentUser.id);

      debugPrint('✅ Grupo creado: ${response['id']}');
      return Group.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al crear grupo: $e');
      rethrow;
    }
  }

  @override
  Future<void> join(String groupId, String userId) async {
    try {
      final alreadyMember = await isMember(groupId, userId);
      if (alreadyMember) {
        debugPrint('⚠️ Usuario $userId ya es miembro del grupo $groupId');
        return;
      }

      await _supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      await _supabase.rpc('increment_group_members', params: {'group_id': groupId});
      
      debugPrint('✅ Usuario $userId se unió al grupo $groupId');
    } catch (e) {
      debugPrint('❌ Error al unirse al grupo: $e');
      rethrow;
    }
  }

  @override
  Future<void> leave(String groupId, String userId) async {
    try {
      final isMemberResult = await isMember(groupId, userId);
      if (!isMemberResult) {
        debugPrint('⚠️ Usuario $userId no es miembro del grupo $groupId');
        return;
      }

      await _supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      await _supabase.rpc('decrement_group_members', params: {'group_id': groupId});
      
      debugPrint('✅ Usuario $userId abandonó el grupo $groupId');
    } catch (e) {
      debugPrint('❌ Error al abandonar el grupo: $e');
      rethrow;
    }
  }

  Future<List<String>> getGroupMembers(String groupId) async {
    try {
      final response = await _supabase
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId);

      return (response as List)
          .map((item) => item['user_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener miembros del grupo: $e');
      return [];
    }
  }

  Future<bool> isMember(String groupId, String userId) async {
    try {
      final response = await _supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('❌ Error al verificar membresía: $e');
      return false;
    }
  }

  Future<List<Group>> getUserGroups(String userId) async {
    try {
      final memberGroups = await _supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = (memberGroups as List)
          .map((item) => item['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) return [];

      final response = await _supabase
          .from('groups')
          .select()
          .inFilter('id', groupIds)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Group.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener grupos del usuario: $e');
      return [];
    }
  }

  Future<Group> update({
    required String id,
    String? name,
    String? description,
    List<String>? keywords,
    List<String>? interests,
    bool? isPrivate,
    int? maxMembers,
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (keywords != null) updates['keywords'] = keywords;
      if (interests != null) updates['interests'] = interests;
      if (isPrivate != null) updates['is_private'] = isPrivate;
      if (maxMembers != null) updates['max_members'] = maxMembers;

      final response = await _supabase
          .from('groups')
          .update(updates)
          .eq('id', id)
          .eq('creator_id', currentUser.id)
          .select()
          .single();

      debugPrint('✅ Grupo actualizado: $id');
      return Group.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al actualizar grupo: $e');
      rethrow;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase
          .from('groups')
          .delete()
          .eq('id', id)
          .eq('creator_id', currentUser.id);

      debugPrint('✅ Grupo eliminado: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error al eliminar grupo: $e');
      return false;
    }
  }

  Future<List<Group>> searchByKeywords(List<String> keywords) async {
    try {
      final response = await _supabase
          .from('groups')
          .select()
          .contains('keywords', keywords)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Group.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al buscar grupos: $e');
      return [];
    }
  }
}
