import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/inventory_item.dart';
import '../supabase/supabase_service.dart';

/// Servicio para gestionar el inventario en Supabase
class InventoryService {
  final SupabaseClient _client = supabase;

  // ============================================
  // 📦 OPERACIONES DE ITEMS
  // ============================================

  /// Obtener todos los items de inventario de la empresa actual
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      final response = await _client
          .from('inventory_items')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener inventario: $e');
    }
  }

  /// Obtener items filtrados por categoría
  Future<List<InventoryItem>> getItemsByCategory(InventoryCategory category) async {
    try {
      final response = await _client
          .from('inventory_items')
          .select()
          .eq('category', category.name)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar por categoría: $e');
    }
  }

  /// Obtener items filtrados por estado
  Future<List<InventoryItem>> getItemsByStatus(InventoryStatus status) async {
    try {
      final response = await _client
          .from('inventory_items')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar por estado: $e');
    }
  }

  /// Obtener items con stock bajo o crítico
  Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final response = await _client
          .from('inventory_items')
          .select()
          .inFilter('status', ['bajo', 'critico', 'agotado'])
          .order('quantity', ascending: true);

      return (response as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener items con stock bajo: $e');
    }
  }

  /// Obtener un item por ID
  Future<InventoryItem?> getItemById(String itemId) async {
    try {
      final response = await _client
          .from('inventory_items')
          .select()
          .eq('id', itemId)
          .single();

      return InventoryItem.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener item: $e');
    }
  }

  /// Crear un nuevo item de inventario
  Future<InventoryItem> createItem(InventoryItem item) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final data = item.toJson();
      data['company_id'] = userId;

      final response = await _client
          .from('inventory_items')
          .insert(data)
          .select()
          .single();

      return InventoryItem.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear item: $e');
    }
  }

  /// Actualizar un item existente
  Future<InventoryItem> updateItem(InventoryItem item) async {
    try {
      final data = item.toJson();
      data.remove('id'); // No actualizar el ID
      data.remove('company_id'); // No actualizar la empresa
      data.remove('created_at'); // No actualizar fecha de creación

      final response = await _client
          .from('inventory_items')
          .update(data)
          .eq('id', item.id)
          .select()
          .single();

      return InventoryItem.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar item: $e');
    }
  }

  /// Eliminar un item
  Future<void> deleteItem(String itemId) async {
    try {
      await _client
          .from('inventory_items')
          .delete()
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Error al eliminar item: $e');
    }
  }

  /// Alternar estado de favorito de un item
  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      await _client
          .from('inventory_items')
          .update({'is_favorite': !isFavorite})
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Error al actualizar favorito: $e');
    }
  }

  /// Incrementar contador de pedidos de un item
  Future<void> incrementRequestCount(String itemId, int currentCount) async {
    try {
      await _client
          .from('inventory_items')
          .update({'request_count': currentCount + 1})
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Error al incrementar pedidos: $e');
    }
  }

  // ============================================
  // 📊 OPERACIONES DE MOVIMIENTOS
  // ============================================

  /// Obtener movimientos de un item específico
  Future<List<InventoryMovement>> getMovementsByItem(String itemId) async {
    try {
      final response = await _client
          .from('inventory_movements')
          .select()
          .eq('item_id', itemId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => InventoryMovement.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos: $e');
    }
  }

  /// Crear un nuevo movimiento (automáticamente actualiza la cantidad)
  Future<InventoryMovement> createMovement(InventoryMovement movement) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final data = movement.toJson();
      data['responsible_user_id'] = userId;

      final response = await _client
          .from('inventory_movements')
          .insert(data)
          .select()
          .single();

      return InventoryMovement.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear movimiento: $e');
    }
  }

  // ============================================
  // 📈 ESTADÍSTICAS Y REPORTES
  // ============================================

  /// Obtener estadísticas generales del inventario
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final items = await getInventoryItems();
      
      final totalItems = items.length;
      final totalValue = items.fold<double>(
        0, 
        (sum, item) => sum + item.totalValue,
      );
      final lowStockCount = items.where((item) => 
        item.calculatedStatus == InventoryStatus.bajo ||
        item.calculatedStatus == InventoryStatus.critico ||
        item.calculatedStatus == InventoryStatus.agotado
      ).length;
      
      final availableCount = items.where((item) => 
        item.calculatedStatus == InventoryStatus.disponible
      ).length;
      
      final avgStockLevel = items.isEmpty 
          ? 0.0 
          : items.fold<double>(0, (sum, item) => sum + item.stockPercentage) / items.length;

      return {
        'totalItems': totalItems,
        'totalValue': totalValue,
        'lowStockCount': lowStockCount,
        'availableCount': availableCount,
        'avgStockLevel': avgStockLevel,
      };
    } catch (e) {
      throw Exception('Error al calcular estadísticas: $e');
    }
  }

  /// Obtener distribución por categoría
  Future<Map<InventoryCategory, int>> getCategoryDistribution() async {
    try {
      final items = await getInventoryItems();
      final distribution = <InventoryCategory, int>{};
      
      for (final category in InventoryCategory.values) {
        distribution[category] = items.where((item) => item.category == category).length;
      }
      
      return distribution;
    } catch (e) {
      throw Exception('Error al calcular distribución por categoría: $e');
    }
  }

  /// Obtener distribución por estado
  Future<Map<InventoryStatus, int>> getStatusDistribution() async {
    try {
      final items = await getInventoryItems();
      final distribution = <InventoryStatus, int>{};
      
      for (final status in InventoryStatus.values) {
        distribution[status] = items.where((item) => 
          item.calculatedStatus == status
        ).length;
      }
      
      return distribution;
    } catch (e) {
      throw Exception('Error al calcular distribución por estado: $e');
    }
  }

  // ============================================
  // 🔔 SUSCRIPCIONES EN TIEMPO REAL
  // ============================================

  /// Suscribirse a cambios en el inventario
  RealtimeChannel subscribeToInventoryChanges({
    required Function(List<InventoryItem>) onData,
    required Function(String) onError,
  }) {
    return _client
        .channel('inventory_items_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventory_items',
          callback: (payload) async {
            try {
              final items = await getInventoryItems();
              onData(items);
            } catch (e) {
              onError('Error al procesar cambios: $e');
            }
          },
        )
        .subscribe();
  }

  /// Suscribirse a cambios en movimientos de un item específico
  RealtimeChannel subscribeToMovementChanges({
    required String itemId,
    required Function(List<InventoryMovement>) onData,
    required Function(String) onError,
  }) {
    return _client
        .channel('inventory_movements_$itemId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventory_movements',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'item_id',
            value: itemId,
          ),
          callback: (payload) async {
            try {
              final movements = await getMovementsByItem(itemId);
              onData(movements);
            } catch (e) {
              onError('Error al procesar cambios: $e');
            }
          },
        )
        .subscribe();
  }
}
