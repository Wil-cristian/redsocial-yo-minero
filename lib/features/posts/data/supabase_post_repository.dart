import 'package:yominero/shared/models/post.dart';
import 'package:yominero/features/posts/domain/post_repository.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';

/// Implementación de PostRepository usando Supabase como backend
class SupabasePostRepository implements PostRepository {
  final _supabase = SupabaseService.instance.client;

  @override
  Future<List<Post>> getAll() async {
    try {
      // Consultar posts ordenados por fecha de creación (más recientes primero)
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            author:users!posts_author_id_fkey(id, name, username, profile_image_url)
          ''')
          .order('created_at', ascending: false);

      // Convertir respuesta a lista de Posts
      return (response as List)
          .map((json) => _mapToPost(json))
          .toList();
    } catch (e) {
      print('❌ Error al obtener posts: $e');
      return [];
    }
  }

  @override
  Future<Post> create({
    String? author,
    required String title,
    required String content,
    PostType type = PostType.community,
    List<String> tags = const [],
    List<String> categories = const [],
    List<String>? requiredTags,
    double? budgetAmount,
    String? budgetCurrency,
    DateTime? deadline,
    String? serviceName,
    List<String>? serviceTags,
    double? pricingFrom,
    double? pricingTo,
    String? pricingUnit,
    String? availability,
  }) async {
    try {
      // Obtener ID del usuario autenticado
      final currentUser = SupabaseAuthService.instance.currentUser;
      
      // DEBUG: Verificar autenticación
      print('🔐 Usuario actual: ${currentUser?.id}');
      print('🔐 Email: ${currentUser?.email}');
      print('🔐 Token presente: ${_supabase.auth.currentSession?.accessToken != null}');
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Preparar datos del post
      final postData = {
        'author_id': currentUser.id,
        'title': title,
        'content': content,
        'type': type.toString().split('.').last, // 'community', 'request', 'offer', etc
        'tags': tags,
        'categories': categories,
        // NO incluir likes_count - la tabla usa un COUNT desde post_likes
        // Campos específicos de request
        if (type == PostType.request) ...{
          'required_tags': requiredTags ?? [],
          'budget_amount': budgetAmount,
          'budget_currency': budgetCurrency ?? 'USD',
          'deadline': deadline?.toIso8601String(),
        },
        // Campos específicos de offer
        if (type == PostType.offer) ...{
          'service_name': serviceName,
          'service_tags': serviceTags ?? [],
          'pricing_from': pricingFrom,
          'pricing_to': pricingTo,
          'pricing_unit': pricingUnit,
          'availability': availability,
        },
      };

      // Insertar en Supabase
      final response = await _supabase
          .from('posts')
          .insert(postData)
          .select('''
            *,
            author:users!posts_author_id_fkey(id, name, username, profile_image_url)
          ''')
          .single();

      print('✅ Post creado: ${response['id']}');
      return _mapToPost(response);
    } catch (e) {
      print('❌ Error al crear post: $e');
      rethrow;
    }
  }

  @override
  Future<bool> like(String postId, [String? userId]) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      final uid = userId ?? currentUser?.id;
      
      if (uid == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar si ya dio like
      final existing = await _supabase
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', uid)
          .maybeSingle();

      if (existing != null) {
        // Ya dio like, no hacer nada
        return false;
      }

      // Insertar like (el trigger auto-incrementará likes_count)
      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': uid,
      });

      print('✅ Like agregado al post $postId');
      return true;
    } catch (e) {
      print('❌ Error al dar like: $e');
      return false;
    }
  }

  @override
  Future<bool> hasUserLiked(String postId, [String? userId]) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      final uid = userId ?? currentUser?.id;
      
      if (uid == null) return false;

      final result = await _supabase
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', uid)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('❌ Error al verificar like: $e');
      return false;
    }
  }

  /// Mapea un JSON de Supabase a un objeto Post
  Post _mapToPost(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: _parsePostType(json['type'] as String?),
      tags: List<String>.from(json['tags'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      likes: json['likes_count'] as int? ?? 0,
      comments: 0, // TODO: Implementar comments cuando se cree la tabla
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      imageUrl: json['image_url'] as String?,
      active: json['active'] as bool? ?? true,
      // Campos de request
      requiredTags: json['required_tags'] != null 
          ? List<String>.from(json['required_tags']) 
          : null,
      budgetAmount: json['budget_amount'] as double?,
      budgetCurrency: json['budget_currency'] as String?,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String) 
          : null,
      // Campos de offer
      serviceName: json['service_name'] as String?,
      serviceTags: json['service_tags'] != null 
          ? List<String>.from(json['service_tags']) 
          : null,
      pricingFrom: json['pricing_from'] as double?,
      pricingTo: json['pricing_to'] as double?,
      pricingUnit: json['pricing_unit'] as String?,
      availability: json['availability'] as String?,
    );
  }

  PostType _parsePostType(String? type) {
    switch (type) {
      case 'request':
        return PostType.request;
      case 'offer':
        return PostType.offer;
      default:
        return PostType.community;
    }
  }
}
