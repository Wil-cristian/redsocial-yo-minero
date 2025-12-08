import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

/// Repositorio para manejar el inventario personal del usuario
/// Obtiene todas las publicaciones del usuario con sus métricas
class MyInventoryRepository {
  final SupabaseClient _supabase;
  
  MyInventoryRepository(this._supabase);
  
  /// Obtiene todos los items del inventario del usuario actual
  Future<List<InventoryItem>> getMyInventory({
    String? userId,
    InventoryItemType? filterType,
    InventoryItemStatus? filterStatus,
    String? sortBy,
    bool descending = true,
  }) async {
    try {
      final currentUserId = userId ?? _supabase.auth.currentUser?.id;
      debugPrint('🔍 [MyInventory] Buscando posts para usuario: $currentUserId');
      
      if (currentUserId == null) {
        debugPrint('❌ [MyInventory] Usuario no autenticado');
        throw Exception('Usuario no autenticado');
      }
      
      // Consultar posts del usuario - usar select simple primero
      final response = await _supabase
          .from('posts')
          .select()
          .eq('author_id', currentUserId)
          .order('created_at', ascending: false);
      
      debugPrint('✅ [MyInventory] Respuesta recibida: ${response.length} posts');
      
      if (response.isEmpty) {
        debugPrint('⚠️ [MyInventory] No se encontraron posts para este usuario');
        return [];
      }
      
      // Debug: mostrar primer post
      debugPrint('📊 [MyInventory] Primer post: ${response[0]}');
      
      // Convertir a InventoryItems
      List<InventoryItem> items = [];
      for (var post in response) {
        try {
          final item = InventoryItem.fromPost(post);
          
          // Aplicar filtro de tipo si se especifica
          if (filterType != null && item.type != filterType) {
            continue;
          }
          
          // Aplicar filtro de estado si se especifica
          if (filterStatus == null || item.status == filterStatus) {
            items.add(item);
          }
        } catch (e) {
          debugPrint('⚠️ [MyInventory] Error convirtiendo post: $e');
        }
      }
      
      debugPrint('✅ [MyInventory] Items convertidos: ${items.length}');
      
      // Por ahora retornar sin enriquecer para evitar timeout
      // TODO: Optimizar con batch queries
      // items = await _enrichWithMetrics(items);
      
      return items;
    } catch (e) {
      debugPrint('❌ [MyInventory] Error obteniendo inventario: $e');
      return [];
    }
  }
  
  /// Obtiene items del inventario por tipo específico
  Future<List<InventoryItem>> getItemsByType(InventoryItemType type) async {
    return getMyInventory(filterType: type);
  }
  
  /// Obtiene solo productos del usuario
  Future<List<InventoryItem>> getMyProducts() async {
    return getItemsByType(InventoryItemType.product);
  }
  
  /// Obtiene solo servicios del usuario
  Future<List<InventoryItem>> getMyServices() async {
    return getItemsByType(InventoryItemType.service);
  }
  
  /// Obtiene solo preguntas del usuario
  Future<List<InventoryItem>> getMyQuestions() async {
    return getItemsByType(InventoryItemType.request);
  }
  
  /// Obtiene solo encuestas del usuario
  Future<List<InventoryItem>> getMyPolls() async {
    return getItemsByType(InventoryItemType.poll);
  }
  
  /// Obtiene solo noticias del usuario
  Future<List<InventoryItem>> getMyNews() async {
    return getItemsByType(InventoryItemType.news);
  }
  
  /// Obtiene solo ofertas del usuario
  Future<List<InventoryItem>> getMyOffers() async {
    return getItemsByType(InventoryItemType.offer);
  }
  
  /// Obtiene un resumen del inventario
  Future<InventorySummary> getInventorySummary() async {
    final items = await getMyInventory();
    return InventorySummary.fromItems(items);
  }
  
  /// Enriquece los items con métricas adicionales
  Future<List<InventoryItem>> _enrichWithMetrics(List<InventoryItem> items) async {
    if (items.isEmpty) return items;
    
    final enrichedItems = <InventoryItem>[];
    
    for (var item in items) {
      // Obtener conteo de comentarios
      final commentsCount = await _getCommentsCount(item.postId);
      
      // Obtener conteo de guardados
      final savesCount = await _getSavesCount(item.postId);
      
      // Obtener conteo de conversaciones
      final chatsCount = await _getChatsCount(item.postId);
      
      // Obtener conteo de respuestas (para preguntas)
      final responsesCount = item.type == InventoryItemType.request 
          ? await _getResponsesCount(item.postId) 
          : 0;
      
      // Actualizar métricas
      final updatedMetrics = ItemMetrics(
        views: item.metrics.views,
        likes: item.metrics.likes,
        comments: commentsCount,
        shares: item.metrics.shares,
        saves: savesCount,
        chats: chatsCount,
        responses: responsesCount,
        sales: item.metrics.sales,
        revenue: item.metrics.revenue,
        avgViewTime: item.metrics.avgViewTime,
        conversionRate: _calculateConversionRate(
          views: item.metrics.views,
          actions: item.metrics.likes + commentsCount + savesCount + chatsCount,
        ),
        totalVotes: item.metrics.totalVotes,
        votesByOption: item.metrics.votesByOption,
      );
      
      enrichedItems.add(item.copyWith(metrics: updatedMetrics));
    }
    
    return enrichedItems;
  }
  
  /// Obtiene el conteo de comentarios para un post
  Future<int> _getCommentsCount(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('id')
          .eq('post_id', postId);
      return response.length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Obtiene el conteo de guardados para un post
  Future<int> _getSavesCount(String postId) async {
    try {
      final response = await _supabase
          .from('saved_posts')
          .select('id')
          .eq('post_id', postId);
      return response.length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Obtiene el conteo de conversaciones iniciadas por un post
  Future<int> _getChatsCount(String postId) async {
    try {
      // Buscar conversaciones donde el post_id esté en metadata
      final response = await _supabase
          .from('conversations')
          .select('id')
          .contains('metadata', {'post_id': postId});
      return response.length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Obtiene el conteo de respuestas para una pregunta
  Future<int> _getResponsesCount(String postId) async {
    try {
      final response = await _supabase
          .from('responses')
          .select('id')
          .eq('post_id', postId);
      return response.length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Calcula la tasa de conversión
  double _calculateConversionRate({required int views, required int actions}) {
    if (views == 0) return 0.0;
    return (actions / views * 100).clamp(0.0, 100.0);
  }
  
  /// Actualiza el estado de un item del inventario
  Future<bool> updateItemStatus(String postId, InventoryItemStatus newStatus) async {
    try {
      await _supabase
          .from('posts')
          .update({'active': newStatus == InventoryItemStatus.active})
          .eq('id', postId);
      return true;
    } catch (e) {
      print('Error actualizando estado: $e');
      return false;
    }
  }
  
  /// Elimina un item del inventario (soft delete)
  Future<bool> archiveItem(String postId) async {
    return updateItemStatus(postId, InventoryItemStatus.archived);
  }
  
  /// Reactiva un item archivado
  Future<bool> reactivateItem(String postId) async {
    return updateItemStatus(postId, InventoryItemStatus.active);
  }
  
  /// Marca un producto como vendido
  Future<bool> markAsSold(String postId) async {
    try {
      await _supabase
          .from('posts')
          .update({
            'product_stock': 0,
            'active': false,
          })
          .eq('id', postId);
      return true;
    } catch (e) {
      print('Error marcando como vendido: $e');
      return false;
    }
  }
  
  /// Actualiza el stock de un producto
  Future<bool> updateStock(String postId, int newStock) async {
    try {
      await _supabase
          .from('posts')
          .update({'product_stock': newStock})
          .eq('id', postId);
      return true;
    } catch (e) {
      print('Error actualizando stock: $e');
      return false;
    }
  }
  
  /// Obtiene estadísticas de rendimiento por período
  Future<Map<String, dynamic>> getPerformanceStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final items = await getMyInventory();
      
      // Filtrar items por período
      final periodItems = items.where((item) {
        return item.createdAt.isAfter(startDate) && 
               item.createdAt.isBefore(endDate);
      }).toList();
      
      // Calcular estadísticas
      int totalViews = 0;
      int totalLikes = 0;
      int totalComments = 0;
      int totalChats = 0;
      double totalRevenue = 0;
      
      for (var item in periodItems) {
        totalViews += item.metrics.views;
        totalLikes += item.metrics.likes;
        totalComments += item.metrics.comments;
        totalChats += item.metrics.chats;
        totalRevenue += item.metrics.revenue;
      }
      
      return {
        'period_start': startDate.toIso8601String(),
        'period_end': endDate.toIso8601String(),
        'items_created': periodItems.length,
        'total_views': totalViews,
        'total_likes': totalLikes,
        'total_comments': totalComments,
        'total_chats': totalChats,
        'total_revenue': totalRevenue,
        'avg_engagement': periodItems.isNotEmpty 
            ? periodItems.map((i) => i.metrics.engagementRate).reduce((a, b) => a + b) / periodItems.length
            : 0.0,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }
  
  /// Obtiene los items más populares del usuario
  Future<List<InventoryItem>> getTopPerformingItems({int limit = 5}) async {
    final items = await getMyInventory();
    
    // Ordenar por performance score
    items.sort((a, b) => b.metrics.performanceScore.compareTo(a.metrics.performanceScore));
    
    return items.take(limit).toList();
  }
  
  /// Obtiene items que necesitan atención (bajo engagement, sin respuestas, etc.)
  Future<List<InventoryItem>> getItemsNeedingAttention() async {
    final items = await getMyInventory(filterStatus: InventoryItemStatus.active);
    
    return items.where((item) {
      // Items con bajo engagement
      if (item.metrics.engagementRate < 2.0 && item.daysSinceCreated > 3) {
        return true;
      }
      // Preguntas sin respuestas después de 2 días
      if (item.type == InventoryItemType.request && 
          item.metrics.responses == 0 && 
          item.daysSinceCreated > 2) {
        return true;
      }
      // Productos sin interacción después de 7 días
      if (item.type == InventoryItemType.product && 
          item.metrics.chats == 0 && 
          item.daysSinceCreated > 7) {
        return true;
      }
      // Encuestas próximas a expirar
      if (item.type == InventoryItemType.poll && item.expiresAt != null) {
        final daysUntilExpiry = item.expiresAt!.difference(DateTime.now()).inDays;
        if (daysUntilExpiry > 0 && daysUntilExpiry <= 2) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}
