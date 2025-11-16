import 'package:flutter/foundation.dart';
import 'package:yominero/shared/models/service_booking.dart';
import 'package:yominero/features/bookings/domain/booking_repository.dart';
import 'package:yominero/core/supabase/supabase_service.dart';

class SupabaseBookingRepository implements BookingRepository {
  final _supabase = SupabaseService.instance.client;

  @override
  Future<ServiceBooking> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required double durationHours,
    String? clientNotes,
    String? location,
    double? totalPrice,
  }) async {
    try {
      debugPrint('📅 Creando booking para servicio: $serviceId');

      final bookingId = await _supabase.rpc(
        'create_service_booking',
        params: {
          'p_service_id': serviceId,
          'p_booking_date': bookingDate.toIso8601String().split('T')[0],
          'p_start_time': startTime,
          'p_end_time': endTime,
          'p_duration_hours': durationHours,
          'p_client_notes': clientNotes,
          'p_location': location,
          'p_total_price': totalPrice,
        },
      );

      debugPrint('✅ Booking creado: $bookingId');

      // Obtener el booking recién creado
      final bookings = await getBookingsForService(serviceId);
      return bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      debugPrint('❌ Error creando booking: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceBooking>> getAllBookings() async {
    try {
      final response = await _supabase.rpc('get_service_bookings');
      
      return (response as List<dynamic>)
          .map((json) => ServiceBooking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo bookings: $e');
      return [];
    }
  }

  @override
  Future<List<ServiceBooking>> getBookingsForService(String serviceId) async {
    try {
      final response = await _supabase.rpc(
        'get_service_bookings',
        params: {'p_service_id': serviceId},
      );
      
      return (response as List<dynamic>)
          .map((json) => ServiceBooking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo bookings del servicio: $e');
      return [];
    }
  }

  @override
  Future<List<ServiceBooking>> getMyBookings() async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select('''
            *,
            services(name),
            provider:users!service_bookings_provider_id_fkey(name),
            client:users!service_bookings_client_id_fkey(name, username, profile_image_url)
          ''')
          .eq('client_id', _supabase.auth.currentUser!.id)
          .order('booking_date', ascending: false);

      return (response as List<dynamic>).map((json) {
        final data = Map<String, dynamic>.from(json);
        data['service_name'] = data['services']?['name'];
        data['provider_name'] = data['provider']?['name'];
        data['client_name'] = data['client']?['name'];
        data['client_username'] = data['client']?['username'];
        data['client_profile_image'] = data['client']?['profile_image_url'];
        return ServiceBooking.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo mis bookings: $e');
      return [];
    }
  }

  @override
  Future<List<ServiceBooking>> getBookingsAsProvider() async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select('''
            *,
            services(name),
            provider:users!service_bookings_provider_id_fkey(name),
            client:users!service_bookings_client_id_fkey(name, username, profile_image_url)
          ''')
          .eq('provider_id', _supabase.auth.currentUser!.id)
          .order('booking_date', ascending: false);

      return (response as List<dynamic>).map((json) {
        final data = Map<String, dynamic>.from(json);
        data['service_name'] = data['services']?['name'];
        data['provider_name'] = data['provider']?['name'];
        data['client_name'] = data['client']?['name'];
        data['client_username'] = data['client']?['username'];
        data['client_profile_image'] = data['client']?['profile_image_url'];
        return ServiceBooking.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo bookings como proveedor: $e');
      return [];
    }
  }

  @override
  Future<bool> checkAvailability({
    required String serviceId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await _supabase.rpc(
        'check_service_availability',
        params: {
          'p_service_id': serviceId,
          'p_booking_date': bookingDate.toIso8601String().split('T')[0],
          'p_start_time': startTime,
          'p_end_time': endTime,
        },
      );

      return response as bool;
    } catch (e) {
      debugPrint('❌ Error verificando disponibilidad: $e');
      return false;
    }
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots({
    required String serviceId,
    required DateTime bookingDate,
    double slotDuration = 1.0,
  }) async {
    try {
      debugPrint('🔍 Consultando slots disponibles...');
      debugPrint('   serviceId: $serviceId');
      debugPrint('   bookingDate: ${bookingDate.toIso8601String().split('T')[0]}');
      debugPrint('   slotDuration: $slotDuration hrs');
      
      final response = await _supabase.rpc(
        'get_available_slots',
        params: {
          'p_service_id': serviceId,
          'p_booking_date': bookingDate.toIso8601String().split('T')[0],
          'p_slot_duration_hours': slotDuration,
        },
      );

      debugPrint('✅ Respuesta RPC: ${response.length} slots');
      debugPrint('📊 Slots: $response');

      return (response as List<dynamic>)
          .map((json) => TimeSlot.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo slots disponibles: $e');
      debugPrint('❌ Stack: ${StackTrace.current}');
      return [];
    }
  }

  @override
  Future<void> confirmBooking(String bookingId, {String? providerNotes}) async {
    try {
      await _supabase.from('service_bookings').update({
        'status': 'confirmed',
        'confirmed_at': DateTime.now().toIso8601String(),
        'provider_notes': providerNotes,
      }).eq('id', bookingId);

      debugPrint('✅ Booking confirmado: $bookingId');
    } catch (e) {
      debugPrint('❌ Error confirmando booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectBooking(String bookingId, String reason) async {
    try {
      await _supabase.from('service_bookings').update({
        'status': 'rejected',
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancellation_reason': reason,
      }).eq('id', bookingId);

      debugPrint('✅ Booking rechazado: $bookingId');
    } catch (e) {
      debugPrint('❌ Error rechazando booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _supabase.from('service_bookings').update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancellation_reason': reason,
      }).eq('id', bookingId);

      debugPrint('✅ Booking cancelado: $bookingId');
    } catch (e) {
      debugPrint('❌ Error cancelando booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    try {
      await _supabase.from('service_bookings').update({
        'status': 'completed',
      }).eq('id', bookingId);

      debugPrint('✅ Booking completado: $bookingId');
    } catch (e) {
      debugPrint('❌ Error completando booking: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceAvailability>> getServiceAvailability(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_availability')
          .select()
          .eq('service_id', serviceId)
          .order('day_of_week');

      return (response as List<dynamic>)
          .map((json) => ServiceAvailability.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo disponibilidad: $e');
      return [];
    }
  }

  @override
  Future<void> setServiceAvailability({
    required String serviceId,
    required List<ServiceAvailability> availabilities,
  }) async {
    try {
      // Eliminar disponibilidad existente
      await _supabase
          .from('service_availability')
          .delete()
          .eq('service_id', serviceId);

      // Insertar nueva disponibilidad
      final data = availabilities.map((a) => {
        'service_id': serviceId,
        'day_of_week': a.dayOfWeek,
        'start_time': a.startTime,
        'end_time': a.endTime,
        'is_active': a.isActive,
      }).toList();

      await _supabase.from('service_availability').insert(data);

      debugPrint('✅ Disponibilidad configurada para servicio: $serviceId');
    } catch (e) {
      debugPrint('❌ Error configurando disponibilidad: $e');
      rethrow;
    }
  }
}
