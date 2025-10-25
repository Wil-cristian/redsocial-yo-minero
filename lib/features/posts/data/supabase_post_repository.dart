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
    // Campos de producto
    List<String>? productImages,
    double? productPrice,
    String? productCurrency,
    int? productStock,
    String? productCondition,
    // Campos de noticia
    String? newsSource,
    String? newsAuthor,
    String? newsCoverImage,
    // Campos de encuesta
    List<String>? pollOptions,
    Map<String, int>? pollVotes,
    bool? pollAllowMultiple,
    DateTime? pollEndsAt,
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

      // Construir objeto metadata según el tipo de post
      Map<String, dynamic> metadata = {};
      List<String>? images;

      // Campos específicos de request
      if (type == PostType.request) {
        metadata = {
          'required_tags': requiredTags ?? [],
          'budget_amount': budgetAmount,
          'budget_currency': budgetCurrency ?? 'USD',
          'deadline': deadline?.toIso8601String(),
        };
      }
      // Campos específicos de offer
      else if (type == PostType.offer) {
        metadata = {
          'service_name': serviceName,
          'service_tags': serviceTags ?? [],
          'pricing_from': pricingFrom,
          'pricing_to': pricingTo,
          'pricing_unit': pricingUnit,
          'availability': availability,
        };
      }
      // Campos específicos de producto
      else if (type == PostType.product) {
        metadata = {
          'price': productPrice,
          'currency': productCurrency ?? 'USD',
          'stock': productStock,
          'condition': productCondition,
        };
        images = productImages; // Imágenes en columna separada
      }
      // Campos específicos de servicio
      else if (type == PostType.service) {
        metadata = {
          'service_name': serviceName,
          'service_tags': serviceTags ?? [],
          'pricing_from': pricingFrom,
          'pricing_to': pricingTo,
          'pricing_unit': pricingUnit,
          'availability': availability,
        };
      }
      // Campos específicos de noticia
      else if (type == PostType.news) {
        metadata = {
          'source': newsSource,
          'author': newsAuthor,
        };
        images = newsCoverImage != null ? [newsCoverImage] : null; // Cover en columna images[]
      }
      // Campos específicos de encuesta
      else if (type == PostType.poll) {
        metadata = {
          'options': pollOptions ?? [],
          'votes': pollVotes ?? {},
          'allow_multiple': pollAllowMultiple ?? false,
          'ends_at': pollEndsAt?.toIso8601String(),
        };
      }

      // Preparar datos del post con la nueva estructura
      final postData = {
        'author_id': currentUser.id,
        'title': title,
        'content': content,
        'type': type.toString().split('.').last,
        'tags': tags,
        'categories': categories,
        'metadata': metadata, // JSONB con data específica del tipo
        if (images != null && images.isNotEmpty) 'images': images, // Columna TEXT[]
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
    // Extraer metadata JSONB
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final postType = _parsePostType(json['type'] as String?);
    
    // Extraer images de la columna TEXT[]
    final images = json['images'] != null 
        ? List<String>.from(json['images']) 
        : null;
    
    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: postType,
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
      
      // ========== Campos de REQUEST desde metadata ==========
      requiredTags: postType == PostType.request 
          ? List<String>.from(metadata['required_tags'] ?? []) 
          : null,
      budgetAmount: postType == PostType.request 
          ? (metadata['budget_amount'] as num?)?.toDouble()
          : null,
      budgetCurrency: postType == PostType.request 
          ? metadata['budget_currency'] as String?
          : null,
      deadline: postType == PostType.request && metadata['deadline'] != null
          ? DateTime.parse(metadata['deadline'] as String) 
          : null,
      
      // ========== Campos de OFFER/SERVICE desde metadata ==========
      serviceName: (postType == PostType.offer || postType == PostType.service)
          ? metadata['service_name'] as String?
          : null,
      serviceTags: (postType == PostType.offer || postType == PostType.service)
          ? List<String>.from(metadata['service_tags'] ?? []) 
          : null,
      pricingFrom: (postType == PostType.offer || postType == PostType.service)
          ? (metadata['pricing_from'] as num?)?.toDouble()
          : null,
      pricingTo: (postType == PostType.offer || postType == PostType.service)
          ? (metadata['pricing_to'] as num?)?.toDouble()
          : null,
      pricingUnit: (postType == PostType.offer || postType == PostType.service)
          ? metadata['pricing_unit'] as String?
          : null,
      availability: (postType == PostType.offer || postType == PostType.service)
          ? metadata['availability'] as String?
          : null,
      
      // ========== Campos de PRODUCT desde metadata E IMAGES[] ==========
      productImages: postType == PostType.product ? images : null, // ← De columna images[]
      productPrice: postType == PostType.product 
          ? (metadata['price'] as num?)?.toDouble()
          : null,
      productCurrency: postType == PostType.product 
          ? metadata['currency'] as String?
          : null,
      productStock: postType == PostType.product 
          ? metadata['stock'] as int?
          : null,
      productCondition: postType == PostType.product 
          ? metadata['condition'] as String?
          : null,
      
      // ========== Campos de NEWS desde metadata E IMAGES[] ==========
      newsSource: postType == PostType.news 
          ? metadata['source'] as String?
          : null,
      newsAuthor: postType == PostType.news 
          ? metadata['author'] as String?
          : null,
      newsCoverImage: postType == PostType.news && images != null && images.isNotEmpty
          ? images.first  // ← Primera imagen de columna images[]
          : null,
      
      // ========== Campos de POLL desde metadata ==========
      pollOptions: postType == PostType.poll 
          ? List<String>.from(metadata['options'] ?? [])
          : null,
      pollVotes: postType == PostType.poll 
          ? Map<String, int>.from(metadata['votes'] ?? {})
          : null,
      pollAllowMultiple: postType == PostType.poll 
          ? metadata['allow_multiple'] as bool?
          : null,
      pollEndsAt: postType == PostType.poll && metadata['ends_at'] != null
          ? DateTime.parse(metadata['ends_at'] as String)
          : null,
    );
  }

  PostType _parsePostType(String? type) {
    switch (type) {
      case 'request':
        return PostType.request;
      case 'offer':
        return PostType.offer;
      case 'product':
        return PostType.product;
      case 'service':
        return PostType.service;
      case 'news':
        return PostType.news;
      case 'poll':
        return PostType.poll;
      default:
        return PostType.community;
    }
  }
}
