class Service {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  
  // Pricing (coincide con esquema SQL)
  final double? pricingFrom;
  final double? pricingTo;
  final String? pricingUnit;
  
  // Disponibilidad
  final String? availability;
  final bool isAvailable;
  
  // Información del proveedor (viene de JOIN con users)
  final String? providerName;
  final String? providerAccountType;
  final String? providerAvatarUrl;
  
  // Imágenes
  final List<String> imageUrls;
  
  // Métricas
  final int viewsCount;
  final int requestsCount;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.category,
    this.tags = const [],
    this.pricingFrom,
    this.pricingTo,
    this.pricingUnit,
    this.availability,
    this.isAvailable = true,
    this.providerName,
    this.providerAccountType,
    this.providerAvatarUrl,
    this.imageUrls = const [],
    this.viewsCount = 0,
    this.requestsCount = 0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Retorna el rango de precio formateado
  String get priceDisplay {
    if (pricingFrom != null && pricingTo != null) {
      return '\$${pricingFrom!.toStringAsFixed(0)} - \$${pricingTo!.toStringAsFixed(0)}${pricingUnit != null ? '/$pricingUnit' : ''}';
    } else if (pricingFrom != null) {
      return 'Desde \$${pricingFrom!.toStringAsFixed(0)}${pricingUnit != null ? '/$pricingUnit' : ''}';
    }
    return 'Precio a consultar';
  }

  /// Retorna el tiempo transcurrido desde la publicación
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} meses';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas';
    } else {
      return '${difference.inMinutes} minutos';
    }
  }

  /// Constructor desde JSON (Supabase con JOIN de users)
  factory Service.fromJson(Map<String, dynamic> json) {
    // Extraer información del proveedor (puede venir de un JOIN)
    final provider = json['provider'] as Map<String, dynamic>?;
    
    return Service(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      pricingFrom: (json['pricing_from'] as num?)?.toDouble(),
      pricingTo: (json['pricing_to'] as num?)?.toDouble(),
      pricingUnit: json['pricing_unit'] as String?,
      availability: json['availability'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      providerName: provider?['name'] as String?,
      providerAccountType: provider?['account_type'] as String?,
      providerAvatarUrl: provider?['profile_image_url'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      viewsCount: json['views_count'] as int? ?? 0,
      requestsCount: json['requests_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  /// Convertir a JSON (para insertar/actualizar en Supabase)
  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'name': name,
      'description': description,
      'category': category,
      'tags': tags,
      'pricing_from': pricingFrom,
      'pricing_to': pricingTo,
      'pricing_unit': pricingUnit,
      'availability': availability,
      'is_available': isAvailable,
    };
  }
}
