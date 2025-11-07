import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/favorite.dart';

abstract class FavoriteRepository {
  Future<List<Favorite>> getUserFavorites(String userId);
  Future<bool> isFavorite(String userId, {String? productId, String? serviceId});
  Future<Favorite> addFavorite(String userId, {String? productId, String? serviceId});
  Future<void> removeFavorite(String userId, {String? productId, String? serviceId});
  Future<List<String>> getFavoriteProductIds(String userId);
  Future<List<String>> getFavoriteServiceIds(String userId);
}

class SupabaseFavoriteRepository implements FavoriteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Favorite>> getUserFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Favorite.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  @override
  Future<bool> isFavorite(String userId, {String? productId, String? serviceId}) async {
    try {
      var query = _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId);

      if (productId != null) {
        query = query.eq('product_id', productId);
      } else if (serviceId != null) {
        query = query.eq('service_id', serviceId);
      }

      final response = await query.maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  @override
  Future<Favorite> addFavorite(String userId, {String? productId, String? serviceId}) async {
    try {
      final data = {
        'user_id': userId,
        if (productId != null) 'product_id': productId,
        if (serviceId != null) 'service_id': serviceId,
      };

      final response = await _supabase
          .from('favorites')
          .insert(data)
          .select()
          .single();

      return Favorite.fromJson(response);
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite(String userId, {String? productId, String? serviceId}) async {
    try {
      var query = _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId);

      if (productId != null) {
        query = query.eq('product_id', productId);
      } else if (serviceId != null) {
        query = query.eq('service_id', serviceId);
      }

      await query;
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getFavoriteProductIds(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId)
          .not('product_id', 'is', null);

      return (response as List)
          .map((item) => item['product_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting favorite product IDs: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getFavoriteServiceIds(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('service_id')
          .eq('user_id', userId)
          .not('service_id', 'is', null);

      return (response as List)
          .map((item) => item['service_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting favorite service IDs: $e');
      return [];
    }
  }
}
