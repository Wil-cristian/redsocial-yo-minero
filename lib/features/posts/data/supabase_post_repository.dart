import 'package:flutter/foundation.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/features/posts/domain/post_repository.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'dart:convert';

/// Implementación de PostRepository usando Supabase como backend
class SupabasePostRepository implements PostRepository {
  final _supabase = SupabaseService.instance.client;

  @override
  Future<List<Post>> getAll() async {
    try {
      debugPrint('🔍 Iniciando consulta de posts...');
      // Consultar posts ordenados por fecha de creación (más recientes primero)
      // ⚠️ IMPORTANTE: Supabase PostgREST necesita ALL sin * para traer TEXT[] arrays
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      debugPrint('✅ Respuesta recibida: ${response.length} posts');
      if (response.isNotEmpty) {
        debugPrint('📊 Primer post ID: ${response[0]['id']}');
        debugPrint('📊 Primer post poll_options: ${response[0]['poll_options']}');
      }

      // Convertir respuesta a lista de Posts
      final posts = (response as List)
          .map((json) => _mapToPost(json))
          .toList();
      
      debugPrint('✅ Posts mapeados: ${posts.length}');
      return posts;
    } catch (e) {
      debugPrint('❌ Error al obtener posts: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
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
      debugPrint('🔐 Usuario actual: ${currentUser?.id}');
      debugPrint('🔐 Email: ${currentUser?.email}');
      debugPrint('🔐 Token presente: ${_supabase.auth.currentSession?.accessToken != null}');
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Construir objeto metadata según el tipo de post
      // ⚠️ IMPORTANTE: Usar columnas directas donde existan para mejor rendimiento
      Map<String, dynamic> metadata = {};

      // Preparar datos base del post
      final postData = <String, dynamic>{
        'author_id': currentUser.id,
        'title': title,
        'content': content,
        'post_type': type.toString().split('.').last,
        'tags': tags,
        'categories': categories,
      };

      // ========== REQUEST: Usa columnas directas ==========
      if (type == PostType.request) {
        postData['required_tags'] = requiredTags ?? [];
        postData['budget_amount'] = budgetAmount;
        postData['budget_currency'] = budgetCurrency ?? 'USD';
        if (deadline != null) postData['deadline'] = deadline.toIso8601String();
        // Backup en metadata para compatibilidad
        metadata = {
          'required_tags': requiredTags ?? [],
          'budget_amount': budgetAmount,
          'budget_currency': budgetCurrency ?? 'USD',
          'deadline': deadline?.toIso8601String(),
        };
      }
      // ========== OFFER/SERVICE: Usa columnas directas ==========
      else if (type == PostType.offer || type == PostType.service) {
        postData['service_name'] = serviceName;
        postData['service_tags'] = serviceTags ?? [];
        postData['pricing_from'] = pricingFrom;
        postData['pricing_to'] = pricingTo;
        postData['pricing_unit'] = pricingUnit;
        postData['availability'] = availability;
        // Backup en metadata
        metadata = {
          'service_name': serviceName,
          'service_tags': serviceTags ?? [],
          'pricing_from': pricingFrom,
          'pricing_to': pricingTo,
          'pricing_unit': pricingUnit,
          'availability': availability,
        };
      }
      // ========== PRODUCT: Columnas directas + images[] ==========
      else if (type == PostType.product) {
        postData['product_price'] = productPrice;
        postData['product_currency'] = productCurrency ?? 'USD';
        postData['product_stock'] = productStock;
        postData['product_condition'] = productCondition;
        if (productImages != null && productImages.isNotEmpty) {
          postData['images'] = productImages;
        }
        // Backup en metadata
        metadata = {
          'price': productPrice,
          'currency': productCurrency ?? 'USD',
          'stock': productStock,
          'condition': productCondition,
        };
      }
      // ========== NEWS: Columnas directas + images[] ==========
      else if (type == PostType.news) {
        postData['news_source'] = newsSource;
        postData['news_author'] = newsAuthor;
        if (newsCoverImage != null) {
          postData['images'] = [newsCoverImage];
        }
        // Backup en metadata
        metadata = {
          'source': newsSource,
          'author': newsAuthor,
        };
      }
      // ========== POLL: Solo columnas directas ==========
      else if (type == PostType.poll) {
        if (pollOptions != null) postData['poll_options'] = pollOptions;
        if (pollEndsAt != null) postData['poll_ends_at'] = pollEndsAt.toIso8601String();
        postData['poll_allow_multiple'] = pollAllowMultiple ?? false;
        metadata = {}; // Vacío para encuestas
      }

      // Agregar metadata si tiene contenido
      if (metadata.isNotEmpty) {
        postData['metadata'] = metadata;
      }

      // 🔍 DEBUG: Ver qué se va a insertar
      debugPrint('📤 ====== DATOS A INSERTAR EN DB ======');
      debugPrint('Tipo de post: ${type.toString()}');
      debugPrint('Title: $title');
      if (type == PostType.poll) {
        debugPrint('🗳️ POLL DATA:');
        debugPrint('  pollOptions (parámetro): $pollOptions');
        debugPrint('  pollEndsAt (parámetro): $pollEndsAt');
        debugPrint('  poll_options en postData: ${postData['poll_options']}');
        debugPrint('  poll_ends_at en postData: ${postData['poll_ends_at']}');
        debugPrint('  poll_allow_multiple en postData: ${postData['poll_allow_multiple']}');
      }
      debugPrint('postData completo: $postData');
      debugPrint('======================================');

      // Insertar en Supabase
      final response = await _supabase
          .from('posts')
          .insert(postData)
          .select('''
            id, author_id, title, content, post_type, tags, categories, metadata, images,
            likes, comments, created_at, updated_at,
            poll_options, poll_votes, poll_ends_at, poll_allow_multiple,
            author:users!posts_author_id_fkey(id, name, username, profile_image_url)
          ''')
          .single();

      // 🔍 DEBUG: Ver qué devolvió la DB
      debugPrint('📥 ====== RESPUESTA DE DB ======');
      debugPrint('✅ Post creado con ID: ${response['id']}');
      if (type == PostType.poll) {
        debugPrint('🗳️ POLL RESPONSE:');
        debugPrint('  poll_options: ${response['poll_options']}');
        debugPrint('  poll_ends_at: ${response['poll_ends_at']}');
        debugPrint('  poll_allow_multiple: ${response['poll_allow_multiple']}');
      }
      debugPrint('================================');
      
      return _mapToPost(response);
    } catch (e) {
      debugPrint('❌ Error al crear post: $e');
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

      debugPrint('✅ Like agregado al post $postId');
      return true;
    } catch (e) {
      debugPrint('❌ Error al dar like: $e');
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
      debugPrint('❌ Error al verificar like: $e');
      return false;
    }
  }

  /// Mapea un JSON de Supabase a un objeto Post
  Post _mapToPost(Map<String, dynamic> json) {
    // Extraer metadata JSONB
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    // ⚠️ IMPORTANTE: La columna en BD es 'post_type', NO 'type'
    final postType = _parsePostType(json['post_type'] as String? ?? json['type'] as String?);
    
    // 🔍 DEBUG: Ver qué tipo se parsea
    debugPrint('🏷️ Parseando post ${json['id']}: type_raw=${json['post_type']}, type=${postType}');
    
    // Extraer images de la columna TEXT[]
    final images = json['images'] != null 
        ? List<String>.from(json['images']) 
        : null;
    
    // Extraer información del autor del JOIN
    final author = json['author'] as Map<String, dynamic>?;
    
    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: postType,
      tags: List<String>.from(json['tags'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      likes: json['likes_count'] as int? ?? 0,
      comments: 0, // Comentarios se implementarán cuando se cree la tabla
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      imageUrl: json['image_url'] as String?,
      active: json['active'] as bool? ?? true,
      
      // Información del autor
      authorName: author?['name'] as String?,
      authorUsername: author?['username'] as String?,
      authorProfileImage: author?['profile_image_url'] as String?,
      
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
      
      // ========== Campos de OFFER/SERVICE desde columnas directas O metadata ==========
      serviceName: (postType == PostType.offer || postType == PostType.service)
          ? (json['service_name'] as String? ?? metadata['service_name'] as String?)
          : null,
      serviceTags: (postType == PostType.offer || postType == PostType.service)
          ? (json['service_tags'] != null ? List<String>.from(json['service_tags']) : List<String>.from(metadata['service_tags'] ?? [])) 
          : null,
      pricingFrom: (postType == PostType.offer || postType == PostType.service)
          ? _parseDouble(json['pricing_from']) ?? (metadata['pricing_from'] as num?)?.toDouble()
          : null,
      pricingTo: (postType == PostType.offer || postType == PostType.service)
          ? _parseDouble(json['pricing_to']) ?? (metadata['pricing_to'] as num?)?.toDouble()
          : null,
      pricingUnit: (postType == PostType.offer || postType == PostType.service)
          ? (json['pricing_unit'] as String? ?? metadata['pricing_unit'] as String?)
          : null,
      availability: (postType == PostType.offer || postType == PostType.service)
          ? (json['availability'] as String? ?? metadata['availability'] as String?)
          : null,
      serviceId: (postType == PostType.offer || postType == PostType.service)
          ? (json['service_id'] as String?) // ID del servicio en la tabla services
          : null,
      
      // ========== Campos de PRODUCT desde columnas directas O metadata ==========
      productImages: postType == PostType.product ? images : null, // ← De columna images[]
      productPrice: postType == PostType.product 
          ? _parseDouble(json['product_price']) ?? (metadata['price'] as num?)?.toDouble()
          : null,
      productCurrency: postType == PostType.product 
          ? (json['product_currency'] as String? ?? metadata['currency'] as String?)
          : null,
      productStock: postType == PostType.product 
          ? (json['product_stock'] as int? ?? metadata['stock'] as int?)
          : null,
      productCondition: postType == PostType.product 
          ? (json['product_condition'] as String? ?? metadata['condition'] as String?)
          : null,
      
      // ========== Campos de NEWS desde columnas directas O metadata ==========
      newsSource: postType == PostType.news 
          ? (json['news_source'] as String? ?? metadata['source'] as String?)
          : null,
      newsAuthor: postType == PostType.news 
          ? (json['news_author'] as String? ?? metadata['author'] as String?)
          : null,
      newsCoverImage: postType == PostType.news && images != null && images.isNotEmpty
          ? images.first  // ← Primera imagen de columna images[]
          : null,
      
      // ========== Campos de POLL desde columnas directas O metadata (fallback) ==========
      pollOptions: postType == PostType.poll
          ? _parsePollOptions(json, metadata)
          : null,
      pollVotes: postType == PostType.poll
          ? (json['poll_votes'] != null
              ? Map<String, int>.from((json['poll_votes'] as Map).map(
                  (k, v) => MapEntry(k.toString(), (v as num).toInt())
                ))
              : (metadata['votes'] != null
                  ? Map<String, int>.from((metadata['votes'] as Map).map(
                      (k, v) => MapEntry(k.toString(), (v as num).toInt())
                    ))
                  : null))
          : null,
      pollAllowMultiple: postType == PostType.poll 
          ? (json['poll_allow_multiple'] as bool? ?? metadata['allow_multiple'] as bool?)
          : null,
      pollEndsAt: postType == PostType.poll
          ? (json['poll_ends_at'] != null
              ? DateTime.parse(json['poll_ends_at'] as String)
              : (metadata['ends_at'] != null
                  ? DateTime.parse(metadata['ends_at'] as String)
                  : null))
          : null,
    );
  }

  // ========== MÉTODO AUXILIAR PARA PARSEAR POLL OPTIONS ==========
  List<String>? _parsePollOptions(Map<String, dynamic> json, Map<String, dynamic> metadata) {
    try {
      // Primero intenta desde columna directa
      if (json['poll_options'] != null) {
        final options = json['poll_options'];
        debugPrint('🔍 poll_options raw: $options (tipo: ${options.runtimeType})');
        
        if (options is List) {
          final parsed = List<String>.from(options.map((o) => o.toString()));
          debugPrint('✅ poll_options parseado como List: $parsed');
          return parsed.isNotEmpty ? parsed : null;
        } else if (options is String) {
          // Si viene como string JSON, parsear
          final parsed = List<String>.from(
            (jsonDecode(options) as List).map((o) => o.toString())
          );
          debugPrint('✅ poll_options parseado como String JSON: $parsed');
          return parsed.isNotEmpty ? parsed : null;
        }
      }
      
      // Fallback a metadata
      if (metadata['options'] != null) {
        final options = metadata['options'];
        if (options is List) {
          final parsed = List<String>.from(options.map((o) => o.toString()));
          debugPrint('✅ poll_options desde metadata: $parsed');
          return parsed.isNotEmpty ? parsed : null;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error parseando poll_options: $e');
      return null;
    }
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

  // ========== MÉTODOS DE VOTACIÓN EN ENCUESTAS ==========

  @override
  Future<void> votePoll(String pollId, String option, [String? userId]) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      final uid = userId ?? currentUser?.id;
      
      if (uid == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar si ya votó
      final existing = await _supabase
          .from('poll_votes')
          .select()
          .eq('poll_id', pollId)
          .eq('user_id', uid)
          .maybeSingle();

      if (existing != null) {
        // Ya votó, actualizar su voto
        await _supabase
            .from('poll_votes')
            .update({'selected_option': option})
            .eq('poll_id', pollId)
            .eq('user_id', uid);
        debugPrint('✅ Voto actualizado: $option en poll $pollId');
      } else {
        // Primer voto, insertar
        await _supabase.from('poll_votes').insert({
          'poll_id': pollId,
          'user_id': uid,
          'selected_option': option,
        });
        debugPrint('✅ Voto registrado: $option en poll $pollId');
      }
    } catch (e) {
      debugPrint('❌ Error al votar: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getUserVote(String pollId, [String? userId]) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      final uid = userId ?? currentUser?.id;
      
      if (uid == null) return null;

      final result = await _supabase
          .from('poll_votes')
          .select('selected_option')
          .eq('poll_id', pollId)
          .eq('user_id', uid)
          .maybeSingle();

      return result?['selected_option'] as String?;
    } catch (e) {
      debugPrint('❌ Error al obtener voto del usuario: $e');
      return null;
    }
  }

  @override
  Future<Map<String, int>> getPollResults(String pollId) async {
    try {
      final results = await _supabase
          .from('poll_votes')
          .select('selected_option')
          .eq('poll_id', pollId);

      // Contar votos por opción
      final Map<String, int> voteCounts = {};
      for (final row in results as List) {
        final option = row['selected_option'] as String;
        voteCounts[option] = (voteCounts[option] ?? 0) + 1;
      }

      return voteCounts;
    } catch (e) {
      debugPrint('❌ Error al obtener resultados: $e');
      return {};
    }
  }

  /// Helper para convertir valores a double (maneja String, int, double)
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
