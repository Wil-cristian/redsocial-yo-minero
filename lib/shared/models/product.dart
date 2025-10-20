class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool inStock;
  
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

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.authorId,
    required this.authorName,
    required this.authorDisplayName,
    required this.authorAccountType,
    this.imageUrl,
    this.inStock = true,
    this.authorAvatarUrl,
    this.authorRating = 0.0,
    this.authorReviewCount = 0,
    DateTime? createdAt,
    this.updatedAt,
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
}
