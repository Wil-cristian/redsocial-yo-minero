import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/product.dart';
import '../domain/product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Product>> getAll() async {
    return getAllProducts();
  }

  @override
  Future<Product?> getById(String id) async {
    return getProductById(id);
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Product.fromJson(response);
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .eq('category', category)
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting products by seller: $e');
      return [];
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _supabase
          .from('products')
          .insert(product.toInsert())
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .single();

      return Product.fromJson(response);
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await _supabase
          .from('products')
          .update(product.toInsert())
          .eq('id', id)
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .single();

      return Product.fromJson(response);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            seller:users!products_seller_id_fkey(id, name, username, account_type, profile_image_url)
          ''')
          .or('name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
