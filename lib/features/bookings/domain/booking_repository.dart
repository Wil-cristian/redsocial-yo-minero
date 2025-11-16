import 'package:yominero/shared/models/service_booking.dart';

/// Repositorio para gestionar bookings/reservas de servicios
abstract class BookingRepository {
  /// Crear una nueva reserva
  Future<ServiceBooking> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required double durationHours,
    String? clientNotes,
    String? location,
    double? totalPrice,
  });

  /// Obtener todas las reservas (como cliente o proveedor)
  Future<List<ServiceBooking>> getAllBookings();

  /// Obtener reservas de un servicio específico
  Future<List<ServiceBooking>> getBookingsForService(String serviceId);

  /// Obtener reservas como cliente
  Future<List<ServiceBooking>> getMyBookings();

  /// Obtener reservas como proveedor
  Future<List<ServiceBooking>> getBookingsAsProvider();

  /// Verificar disponibilidad de un slot
  Future<bool> checkAvailability({
    required String serviceId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
  });

  /// Obtener slots disponibles para un día
  Future<List<TimeSlot>> getAvailableSlots({
    required String serviceId,
    required DateTime bookingDate,
    double slotDuration = 1.0,
  });

  /// Confirmar una reserva (solo proveedor)
  Future<void> confirmBooking(String bookingId, {String? providerNotes});

  /// Rechazar una reserva (solo proveedor)
  Future<void> rejectBooking(String bookingId, String reason);

  /// Cancelar una reserva
  Future<void> cancelBooking(String bookingId, String reason);

  /// Completar una reserva
  Future<void> completeBooking(String bookingId);

  /// Obtener disponibilidad de un servicio
  Future<List<ServiceAvailability>> getServiceAvailability(String serviceId);

  /// Configurar disponibilidad de un servicio
  Future<void> setServiceAvailability({
    required String serviceId,
    required List<ServiceAvailability> availabilities,
  });
}
