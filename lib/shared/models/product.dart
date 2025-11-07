class Product {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String currency;
  final int stock;
  final bool isAvailable;
  final List<String> imageUrls;
  
  // Información del vendedor (viene de JOIN con users)
  final String? sellerName;
  final String? sellerAccountType;
  final String? sellerAvatarUrl;
  
  // Métricas
  final int viewsCount;
  final int favoritesCount;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    String? sellerId,
    required this.name,
    required this.description,
    String? category,
    required this.price,
    this.currency = 'USD',
    this.stock = 0,
    this.isAvailable = true,
    this.imageUrls = const [],
    this.sellerName,
    this.sellerAccountType,
    this.sellerAvatarUrl,
    this.viewsCount = 0,
    this.favoritesCount = 0,
    DateTime? createdAt,
    this.updatedAt,
    // Legacy parameters for backwards compatibility
    String? authorId,
    String? authorName,
    String? authorDisplayName,
    String? authorAccountType,
    String? authorAvatarUrl,
    double? authorRating,
    int? authorReviewCount,
    String? imageUrl,
    bool? inStock,
  }) : sellerId = sellerId ?? authorId ?? '',
       category = category ?? 'General',
       createdAt = createdAt ?? DateTime.now();
  
  // Compatibilidad con código legacy
  String get authorId => sellerId;
  String get authorName => sellerName ?? 'Usuario';
  String get authorDisplayName => sellerName ?? 'Usuario';
  String get authorAccountType => sellerAccountType ?? 'individual';
  String? get authorAvatarUrl => sellerAvatarUrl;
  double get authorRating => 0.0;
  int get authorReviewCount => 0;
  bool get inStock => isAvailable && stock > 0;
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Retorna el icono apropiado para el tipo de cuenta del vendedor
  String get authorIcon {
    switch (sellerAccountType ?? 'individual') {
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

  /// Indica si el vendedor es una cuenta verificada
  bool get isAuthorVerified {
    return false;
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
  
  String get priceDisplay {
    if (currency == 'USD') {
      return '\$${price.toStringAsFixed(2)}';
    }
    return '$currency ${price.toStringAsFixed(2)}';
  }
  
  factory Product.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>?;
    
    return Product(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      stock: json['stock'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      sellerName: seller?['name'] as String?,
      sellerAccountType: seller?['account_type'] as String?,
      sellerAvatarUrl: seller?['profile_image_url'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      favoritesCount: json['favorites_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'currency': currency,
      'stock': stock,
      'is_available': isAvailable,
      'image_urls': imageUrls,
      'views_count': viewsCount,
      'favorites_count': favoritesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  Map<String, dynamic> toInsert() {
    return {
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'currency': currency,
      'stock': stock,
      'is_available': isAvailable,
      'image_urls': imageUrls,
    };
  }
}
