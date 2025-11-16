/// Modelo de Booking/Reserva de Servicio
class ServiceBooking {
  final String id;
  final String serviceId;
  final String? serviceName;
  final String providerId;
  final String? providerName;
  final String clientId;
  final String? clientName;
  final String? clientUsername;
  final String? clientProfileImage;
  
  final DateTime bookingDate;
  final String startTime; // HH:mm format
  final String endTime;   // HH:mm format
  final double durationHours;
  
  final BookingStatus status;
  
  final String? clientNotes;
  final String? location;
  
  final double? totalPrice;
  final String currency;
  
  final String? providerNotes;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ServiceBooking({
    required this.id,
    required this.serviceId,
    this.serviceName,
    required this.providerId,
    this.providerName,
    required this.clientId,
    this.clientName,
    this.clientUsername,
    this.clientProfileImage,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.status,
    this.clientNotes,
    this.location,
    this.totalPrice,
    this.currency = 'USD',
    this.providerNotes,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String?,
      providerId: json['provider_id'] as String,
      providerName: json['provider_name'] as String?,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String?,
      clientUsername: json['client_username'] as String?,
      clientProfileImage: json['client_profile_image'] as String?,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationHours: (json['duration_hours'] as num).toDouble(),
      status: BookingStatus.fromString(json['status'] as String),
      clientNotes: json['client_notes'] as String?,
      location: json['location'] as String?,
      totalPrice: json['total_price'] != null 
          ? (json['total_price'] as num).toDouble() 
          : null,
      currency: json['currency'] as String? ?? 'USD',
      providerNotes: json['provider_notes'] as String?,
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at'] as String) 
          : null,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'service_name': serviceName,
      'provider_id': providerId,
      'provider_name': providerName,
      'client_id': clientId,
      'client_name': clientName,
      'client_username': clientUsername,
      'client_profile_image': clientProfileImage,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'duration_hours': durationHours,
      'status': status.value,
      'client_notes': clientNotes,
      'location': location,
      'total_price': totalPrice,
      'currency': currency,
      'provider_notes': providerNotes,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ServiceBooking copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? providerId,
    String? providerName,
    String? clientId,
    String? clientName,
    String? clientUsername,
    String? clientProfileImage,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    double? durationHours,
    BookingStatus? status,
    String? clientNotes,
    String? location,
    double? totalPrice,
    String? currency,
    String? providerNotes,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceBooking(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientUsername: clientUsername ?? this.clientUsername,
      clientProfileImage: clientProfileImage ?? this.clientProfileImage,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      status: status ?? this.status,
      clientNotes: clientNotes ?? this.clientNotes,
      location: location ?? this.location,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      providerNotes: providerNotes ?? this.providerNotes,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Estados de una reserva
enum BookingStatus {
  pending('pending', 'Pendiente'),
  confirmed('confirmed', 'Confirmada'),
  cancelled('cancelled', 'Cancelada'),
  completed('completed', 'Completada'),
  rejected('rejected', 'Rechazada');

  final String value;
  final String displayName;

  const BookingStatus(this.value, this.displayName);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Slot de tiempo disponible
class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isAvailable: json['is_available'] as bool,
    );
  }
}

/// Disponibilidad de servicio por día
class ServiceAvailability {
  final String id;
  final String serviceId;
  final int dayOfWeek; // 0=Domingo, 6=Sábado
  final String startTime;
  final String endTime;
  final bool isActive;

  const ServiceAvailability({
    required this.id,
    required this.serviceId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory ServiceAvailability.fromJson(Map<String, dynamic> json) {
    return ServiceAvailability(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
    };
  }

  String get dayName {
    const days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    return days[dayOfWeek];
  }
}
