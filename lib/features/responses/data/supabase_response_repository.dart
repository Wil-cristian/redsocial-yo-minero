import 'package:flutter/foundation.dart';
import 'package:yominero/shared/models/response.dart';
import 'package:yominero/features/responses/domain/response_repository.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';

class SupabaseResponseRepository implements ResponseRepository {
  final _supabase = SupabaseService.instance.client;

  @override
  Future<List<Response>> getResponsesForPost(String postId) async {
    try {
      debugPrint('📥 Obteniendo respuestas para post: $postId');

      // Intentar usar la función con jerarquía, fallback a la función original
      late final List<dynamic> data;
      try {
        data = await _supabase.rpc(
          'get_post_responses_with_nesting',
          params: {'p_post_id': postId},
        );
      } catch (e) {
        debugPrint('⚠️ Función con jerarquía no disponible, usando función original: $e');
        // Fallback a la función original
        data = await _supabase.rpc(
          'get_post_responses',
          params: {'target_post_id': postId},
        );
      }

      debugPrint('📊 Respuestas recibidas: ${data.length}');
      
      // 🔍 DEBUG: Verificar datos de jerarquía
      for (final item in data) {
        final json = item as Map<String, dynamic>;
        debugPrint('🔍 Response ID: ${json['id']} | Parent: ${json['parent_response_id']} | Content: ${json['content']?.toString().substring(0, (json['content']?.toString().length ?? 0).clamp(0, 30))}...');
      }

      final responses = data
          .map((json) => Response.fromJson(json as Map<String, dynamic>))
          .toList();

      return responses;
    } catch (e) {
      debugPrint('❌ Error obteniendo respuestas: $e');
      return [];
    }
  }

  @override
  Future<Response> createResponse({
    required String postId,
    required String content,
    String? parentResponseId,
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('💬 Creando respuesta para post: $postId${parentResponseId != null ? ' (anidada: $parentResponseId)' : ''}');

      // Preparar datos de inserción
      final insertData = {
        'post_id': postId,
        'author_id': currentUser.id,
        'content': content,
      };
      
      // Agregar parent_response_id si es respuesta anidada
      if (parentResponseId != null) {
        insertData['parent_response_id'] = parentResponseId;
      }

      // Insertar respuesta
      final data = await _supabase
          .from('post_responses')
          .insert(insertData)
          .select('*, users!author_id(name, username, profile_image_url)')
          .single();

      debugPrint('✅ Respuesta creada: ${data['id']}');

      // Mapear datos del autor
      final author = data['users'] as Map<String, dynamic>?;
      final responseData = Map<String, dynamic>.from(data);
      responseData['author_name'] = author?['name'];
      responseData['author_username'] = author?['username'];
      responseData['author_profile_image'] = author?['profile_image_url'];
      responseData['user_has_liked'] = false;

      return Response.fromJson(responseData);
    } catch (e) {
      debugPrint('❌ Error creando respuesta: $e');
      rethrow;
    }
  }

  @override
  Future<Response> updateResponse({
    required String responseId,
    required String content,
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('✏️ Actualizando respuesta: $responseId');

      // Actualizar respuesta e incrementar contador de ediciones
      final data = await _supabase
          .from('post_responses')
          .update({
            'content': content,
            'is_edited': true,
            'edit_count': _supabase.rpc('increment', params: {'x': 1}),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', responseId)
          .eq('author_id', currentUser.id)
          .select('*, users!author_id(name, username, profile_image_url)')
          .single();

      debugPrint('✅ Respuesta actualizada');

      // Mapear datos del autor
      final author = data['users'] as Map<String, dynamic>?;
      final responseData = Map<String, dynamic>.from(data);
      responseData['author_name'] = author?['name'];
      responseData['author_username'] = author?['username'];
      responseData['author_profile_image'] = author?['profile_image_url'];

      return Response.fromJson(responseData);
    } catch (e) {
      debugPrint('❌ Error actualizando respuesta: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteResponse(String responseId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('🗑️ Eliminando respuesta: $responseId');

      await _supabase
          .from('post_responses')
          .delete()
          .eq('id', responseId)
          .eq('author_id', currentUser.id);

      debugPrint('✅ Respuesta eliminada');
    } catch (e) {
      debugPrint('❌ Error eliminando respuesta: $e');
      rethrow;
    }
  }

  @override
  Future<void> likeResponse(String responseId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('❤️ Dando like a respuesta: $responseId');

      await _supabase.from('response_likes').insert({
        'response_id': responseId,
        'user_id': currentUser.id,
      });

      debugPrint('✅ Like agregado');
    } catch (e) {
      debugPrint('❌ Error dando like: $e');
      rethrow;
    }
  }

  @override
  Future<void> unlikeResponse(String responseId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('💔 Quitando like de respuesta: $responseId');

      await _supabase
          .from('response_likes')
          .delete()
          .eq('response_id', responseId)
          .eq('user_id', currentUser.id);

      debugPrint('✅ Like removido');
    } catch (e) {
      debugPrint('❌ Error quitando like: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsBestAnswer({
    required String responseId,
    required String postId,
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('🔄 Cambiando estado de mejor respuesta: $responseId');

      // Usar RPC function que maneja tanto marcar como desmarcar
      await _supabase.rpc(
        'mark_as_best_answer',
        params: {
          'target_response_id': responseId,
          'target_post_id': postId,
        },
      );

      debugPrint('✅ Estado de mejor respuesta actualizado');
    } catch (e) {
      debugPrint('❌ Error cambiando mejor respuesta: $e');
      rethrow;
    }
  }

  @override
  Future<Response> createNestedResponse({
    required String postId,
    required String parentResponseId,
    required String content,
  }) async {
    // Usar el método createResponse con parentResponseId
    return createResponse(
      postId: postId,
      content: content,
      parentResponseId: parentResponseId,
    );
  }
}
