import 'package:flutter/foundation.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/features/services/domain/service_repository.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';

class SupabaseServiceRepository implements ServiceRepository {
  final _supabase = SupabaseService.instance.client;

  @override
  Future<List<Service>> getAll() async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener servicios: $e');
      return [];
    }
  }

  @override
  Future<Service?> getById(String id) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .eq('id', id)
          .single();

      return Service.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al obtener servicio: $e');
      return null;
    }
  }

  Future<Service> create({
    required String name,
    required String description,
    required String category,
    List<String> tags = const [],
    double? pricingFrom,
    double? pricingTo,
    String? pricingUnit,
    String? availability,
    List<String> imageUrls = const [],
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final serviceData = {
        'provider_id': currentUser.id,
        'name': name,
        'description': description,
        'category': category,
        'tags': tags,
        'pricing_from': pricingFrom,
        'pricing_to': pricingTo,
        'pricing_unit': pricingUnit,
        'availability': availability,
        'is_available': true,
        'image_urls': imageUrls,
      };

      final response = await _supabase
          .from('services')
          .insert(serviceData)
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .single();

      debugPrint('✅ Servicio creado: ${response['id']}');
      return Service.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al crear servicio: $e');
      rethrow;
    }
  }

  Future<Service> update({
    required String id,
    String? name,
    String? description,
    String? category,
    List<String>? tags,
    double? pricingFrom,
    double? pricingTo,
    String? pricingUnit,
    String? availability,
    bool? isAvailable,
    List<String>? imageUrls,
  }) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;
      if (tags != null) updates['tags'] = tags;
      if (pricingFrom != null) updates['pricing_from'] = pricingFrom;
      if (pricingTo != null) updates['pricing_to'] = pricingTo;
      if (pricingUnit != null) updates['pricing_unit'] = pricingUnit;
      if (availability != null) updates['availability'] = availability;
      if (isAvailable != null) updates['is_available'] = isAvailable;
      if (imageUrls != null) updates['image_urls'] = imageUrls;

      final response = await _supabase
          .from('services')
          .update(updates)
          .eq('id', id)
          .eq('provider_id', currentUser.id)
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .single();

      debugPrint('✅ Servicio actualizado: $id');
      return Service.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al actualizar servicio: $e');
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
          .from('services')
          .delete()
          .eq('id', id)
          .eq('provider_id', currentUser.id);

      debugPrint('✅ Servicio eliminado: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error al eliminar servicio: $e');
      return false;
    }
  }

  Future<void> incrementViews(String id) async {
    try {
      await _supabase.rpc('increment_service_views', params: {'service_id': id});
    } catch (e) {
      debugPrint('⚠️ Error al incrementar vistas: $e');
    }
  }

  Future<void> incrementRequests(String id) async {
    try {
      await _supabase.rpc('increment_service_requests', params: {'service_id': id});
    } catch (e) {
      debugPrint('⚠️ Error al incrementar solicitudes: $e');
    }
  }

  Future<List<Service>> getByProvider(String providerId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener servicios del proveedor: $e');
      return [];
    }
  }

  Future<List<Service>> searchByCategory(String category) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .eq('category', category)
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al buscar servicios por categoría: $e');
      return [];
    }
  }

  Future<List<Service>> searchByTags(List<String> tags) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider:users!services_provider_id_fkey(id, name, username, account_type)
          ''')
          .contains('tags', tags)
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al buscar servicios por tags: $e');
      return [];
    }
  }
}
