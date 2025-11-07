class Service {
  final String id;
  final String name;
  final String description;
  final double rate; // tarifa por hora
  
  // Información del autor - NUEVO SISTEMA
  final String authorId;
  final String authorName;
  final String authorDisplayName;  // Puede ser nombre personal, grupo o empresa
  final String authorAccountType;  // 'individual', 'group', or 'company'
  final String? authorAvatarUrl;
  final double authorRating;
  final int authorReviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Información adicional del servicio
  final List<String> tags;
  final String? category;
  final bool isAvailable;
  final String? location;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.rate,
    required this.authorId,
    required this.authorName,
    required this.authorDisplayName,
    required this.authorAccountType,
    this.authorAvatarUrl,
    this.authorRating = 0.0,
    this.authorReviewCount = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.tags = const [],
    this.category,
    this.isAvailable = true,
    this.location,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Retorna el icono apropiado para el tipo de cuenta del autor
  String get authorIcon {
    switch (authorAccountType) {
      case 'individual':
        return '👤';
      case 'group':
        return '👥';
      case 'company':
        return '🏢';
      default:
        return '👤';
    }
  }

  /// Indica si el autor es una cuenta verificada
  bool get isAuthorVerified {
    return authorRating >= 4.0 && authorReviewCount >= 5;
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

  /// Retorna el rango de precio formateado
  String get rateDisplay {
    return '\$${rate.toStringAsFixed(0)}/hora';
  }

  /// Constructor desde JSON (Supabase)
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rate: (json['rate'] as num).toDouble(),
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? '',
      authorDisplayName: json['author_display_name'] as String? ?? '',
      authorAccountType: json['author_account_type'] as String? ?? 'individual',
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorRating: (json['author_rating'] as num?)?.toDouble() ?? 0.0,
      authorReviewCount: json['author_review_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      location: json['location'] as String?,
    );
  }

  /// Convertir a JSON (para Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rate': rate,
      'author_id': authorId,
      'author_name': authorName,
      'author_display_name': authorDisplayName,
      'author_account_type': authorAccountType,
      'author_avatar_url': authorAvatarUrl,
      'author_rating': authorRating,
      'author_review_count': authorReviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'tags': tags,
      'category': category,
      'is_available': isAvailable,
      'location': location,
    };
  }
}
