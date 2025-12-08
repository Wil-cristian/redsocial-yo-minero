/// Modelo para representar un item del inventario personal del usuario
/// Incluye métricas de interacción para cada publicación

enum InventoryItemType {
  product,   // Productos en venta
  service,   // Servicios ofrecidos
  offer,     // Ofertas publicadas
  request,   // Preguntas/solicitudes
  news,      // Noticias publicadas
  poll,      // Encuestas creadas
  community, // Posts generales
}

enum InventoryItemStatus {
  active,     // Activo y visible
  sold,       // Vendido (solo productos)
  expired,    // Expirado (polls, ofertas)
  paused,     // Pausado temporalmente
  archived,   // Archivado
}

/// Métricas de interacción para una publicación
class ItemMetrics {
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final int chats;        // Conversaciones iniciadas por esta publicación
  final int responses;    // Respuestas recibidas (para preguntas)
  final int sales;        // Ventas realizadas (para productos)
  final double revenue;   // Ingresos generados
  final Duration avgViewTime; // Tiempo promedio de visualización
  final double conversionRate; // Tasa de conversión (views → acción)
  
  // Para encuestas
  final int? totalVotes;
  final Map<String, int>? votesByOption;
  
  const ItemMetrics({
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.chats = 0,
    this.responses = 0,
    this.sales = 0,
    this.revenue = 0.0,
    this.avgViewTime = Duration.zero,
    this.conversionRate = 0.0,
    this.totalVotes,
    this.votesByOption,
  });
  
  /// Calcula el engagement rate
  double get engagementRate {
    if (views == 0) return 0.0;
    return ((likes + comments + shares + saves) / views * 100).clamp(0.0, 100.0);
  }
  
  /// Score general de la publicación (0-100)
  int get performanceScore {
    double score = 0;
    score += (engagementRate * 0.3);
    score += (conversionRate * 0.4);
    score += ((likes / 100).clamp(0.0, 1.0) * 15);
    score += ((comments / 50).clamp(0.0, 1.0) * 15);
    return score.round().clamp(0, 100);
  }
  
  factory ItemMetrics.fromJson(Map<String, dynamic> json) {
    return ItemMetrics(
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      saves: json['saves'] ?? 0,
      chats: json['chats'] ?? 0,
      responses: json['responses'] ?? 0,
      sales: json['sales'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      avgViewTime: Duration(seconds: json['avg_view_time_seconds'] ?? 0),
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
      totalVotes: json['total_votes'],
      votesByOption: json['votes_by_option'] != null 
          ? Map<String, int>.from(json['votes_by_option']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'views': views,
    'likes': likes,
    'comments': comments,
    'shares': shares,
    'saves': saves,
    'chats': chats,
    'responses': responses,
    'sales': sales,
    'revenue': revenue,
    'avg_view_time_seconds': avgViewTime.inSeconds,
    'conversion_rate': conversionRate,
    'total_votes': totalVotes,
    'votes_by_option': votesByOption,
  };
}

/// Item del inventario personal
class InventoryItem {
  final String id;
  final String postId;
  final String userId;
  final InventoryItemType type;
  final InventoryItemStatus status;
  final String title;
  final String? description;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  
  // Datos específicos según tipo
  final double? price;
  final String? currency;
  final int? stock;
  final String? condition;
  final List<String> tags;
  final String? category;
  final String? subcategory;
  
  // Métricas
  final ItemMetrics metrics;
  
  // Datos del post original
  final Map<String, dynamic>? metadata;
  
  const InventoryItem({
    required this.id,
    required this.postId,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.price,
    this.currency,
    this.stock,
    this.condition,
    this.tags = const [],
    this.category,
    this.subcategory,
    required this.metrics,
    this.metadata,
  });
  
  /// ¿Es un item vendible?
  bool get isSellable => type == InventoryItemType.product || type == InventoryItemType.service;
  
  /// ¿Está activo?
  bool get isActive => status == InventoryItemStatus.active;
  
  /// ¿Ha expirado?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  /// Días desde publicación
  int get daysSinceCreated => DateTime.now().difference(createdAt).inDays;
  
  /// Label del tipo
  String get typeLabel {
    switch (type) {
      case InventoryItemType.product:
        return 'Producto';
      case InventoryItemType.service:
        return 'Servicio';
      case InventoryItemType.offer:
        return 'Oferta';
      case InventoryItemType.request:
        return 'Pregunta';
      case InventoryItemType.news:
        return 'Noticia';
      case InventoryItemType.poll:
        return 'Encuesta';
      case InventoryItemType.community:
        return 'Publicación';
    }
  }
  
  /// Label del estado
  String get statusLabel {
    switch (status) {
      case InventoryItemStatus.active:
        return 'Activo';
      case InventoryItemStatus.sold:
        return 'Vendido';
      case InventoryItemStatus.expired:
        return 'Expirado';
      case InventoryItemStatus.paused:
        return 'Pausado';
      case InventoryItemStatus.archived:
        return 'Archivado';
    }
  }
  
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      postId: json['post_id'] ?? json['id'],
      userId: json['user_id'] ?? json['author_id'],
      type: _parseType(json['post_type'] ?? json['type']),
      status: _parseStatus(json['status']),
      title: json['title'] ?? 'Sin título',
      description: json['content'] ?? json['description'],
      images: _parseImages(json),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      price: _parsePrice(json),
      currency: json['currency'] ?? json['product_currency'] ?? 'USD',
      stock: json['stock'] ?? json['product_stock'],
      condition: json['condition'] ?? json['product_condition'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      subcategory: json['subcategory'],
      metrics: ItemMetrics.fromJson(json['metrics'] ?? {}),
      metadata: json['metadata'],
    );
  }
  
  /// Crea un InventoryItem desde un Post de la base de datos
  factory InventoryItem.fromPost(Map<String, dynamic> post) {
    // Buscar primero en post_type (usado en DB) y luego en type (fallback)
    final type = _parseType(post['post_type'] ?? post['type']);
    
    return InventoryItem(
      id: post['id'],
      postId: post['id'],
      userId: post['author_id'] ?? post['user_id'],
      type: type,
      status: post['active'] == true 
          ? InventoryItemStatus.active 
          : InventoryItemStatus.archived,
      title: post['title'] ?? 'Sin título',
      description: post['content'],
      images: _parseImages(post),
      createdAt: DateTime.parse(post['created_at']),
      updatedAt: post['updated_at'] != null 
          ? DateTime.parse(post['updated_at']) 
          : null,
      expiresAt: post['poll_ends_at'] != null 
          ? DateTime.parse(post['poll_ends_at']) 
          : null,
      price: _parsePrice(post),
      currency: post['product_currency'] ?? post['budget_currency'] ?? 'USD',
      stock: post['product_stock'],
      condition: post['product_condition'],
      tags: List<String>.from(post['tags'] ?? []),
      category: post['categories']?.isNotEmpty == true 
          ? post['categories'][0] 
          : null,
      subcategory: post['subcategory'],
      metrics: ItemMetrics(
        likes: post['likes'] ?? 0,
        comments: post['comments'] ?? 0,
        views: post['views'] ?? 0,
        totalVotes: _calculateTotalVotes(post['poll_votes']),
        votesByOption: post['poll_votes'] != null 
            ? Map<String, int>.from(post['poll_votes']) 
            : null,
      ),
      metadata: {
        'service_name': post['service_name'],
        'pricing_from': post['pricing_from'],
        'pricing_to': post['pricing_to'],
        'pricing_unit': post['pricing_unit'],
        'availability': post['availability'],
        'news_source': post['news_source'],
        'news_author': post['news_author'],
        'poll_options': post['poll_options'],
        'poll_allow_multiple': post['poll_allow_multiple'],
        'budget_amount': post['budget_amount'],
        'deadline': post['deadline'],
      },
    );
  }
  
  static InventoryItemType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'product':
        return InventoryItemType.product;
      case 'service':
        return InventoryItemType.service;
      case 'offer':
        return InventoryItemType.offer;
      case 'request':
        return InventoryItemType.request;
      case 'news':
        return InventoryItemType.news;
      case 'poll':
        return InventoryItemType.poll;
      default:
        return InventoryItemType.community;
    }
  }
  
  static InventoryItemStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return InventoryItemStatus.active;
      case 'sold':
        return InventoryItemStatus.sold;
      case 'expired':
        return InventoryItemStatus.expired;
      case 'paused':
        return InventoryItemStatus.paused;
      case 'archived':
        return InventoryItemStatus.archived;
      default:
        return InventoryItemStatus.active;
    }
  }
  
  static List<String> _parseImages(Map<String, dynamic> json) {
    // Intentar obtener imágenes de diferentes campos
    if (json['images'] != null && json['images'] is List) {
      return List<String>.from(json['images']);
    }
    if (json['product_images'] != null && json['product_images'] is List) {
      return List<String>.from(json['product_images']);
    }
    if (json['image_url'] != null) {
      return [json['image_url']];
    }
    if (json['news_cover_image'] != null) {
      return [json['news_cover_image']];
    }
    return [];
  }
  
  static double? _parsePrice(Map<String, dynamic> json) {
    if (json['product_price'] != null) {
      return (json['product_price'] as num).toDouble();
    }
    if (json['pricing_from'] != null) {
      return (json['pricing_from'] as num).toDouble();
    }
    if (json['budget_amount'] != null) {
      return (json['budget_amount'] as num).toDouble();
    }
    return null;
  }
  
  static int? _calculateTotalVotes(Map<String, dynamic>? pollVotes) {
    if (pollVotes == null) return null;
    int total = 0;
    for (var value in pollVotes.values) {
      if (value is int) total += value;
    }
    return total;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
    'type': type.name,
    'status': status.name,
    'title': title,
    'description': description,
    'images': images,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'price': price,
    'currency': currency,
    'stock': stock,
    'condition': condition,
    'tags': tags,
    'category': category,
    'subcategory': subcategory,
    'metrics': metrics.toJson(),
    'metadata': metadata,
  };
  
  InventoryItem copyWith({
    String? id,
    String? postId,
    String? userId,
    InventoryItemType? type,
    InventoryItemStatus? status,
    String? title,
    String? description,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    double? price,
    String? currency,
    int? stock,
    String? condition,
    List<String>? tags,
    String? category,
    String? subcategory,
    ItemMetrics? metrics,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      stock: stock ?? this.stock,
      condition: condition ?? this.condition,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      metrics: metrics ?? this.metrics,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Resumen de todo el inventario del usuario
class InventorySummary {
  final int totalItems;
  final int activeItems;
  final int soldItems;
  final int totalProducts;
  final int totalServices;
  final int totalQuestions;
  final int totalPolls;
  final int totalNews;
  final int totalOffers;
  
  // Métricas globales
  final int totalViews;
  final int totalLikes;
  final int totalComments;
  final int totalChats;
  final double totalRevenue;
  final double avgEngagement;
  
  const InventorySummary({
    this.totalItems = 0,
    this.activeItems = 0,
    this.soldItems = 0,
    this.totalProducts = 0,
    this.totalServices = 0,
    this.totalQuestions = 0,
    this.totalPolls = 0,
    this.totalNews = 0,
    this.totalOffers = 0,
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalChats = 0,
    this.totalRevenue = 0.0,
    this.avgEngagement = 0.0,
  });
  
  factory InventorySummary.fromItems(List<InventoryItem> items) {
    if (items.isEmpty) return const InventorySummary();
    
    int products = 0, services = 0, questions = 0, polls = 0, news = 0, offers = 0;
    int views = 0, likes = 0, comments = 0, chats = 0, sold = 0, active = 0;
    double revenue = 0.0, engagementSum = 0.0;
    
    for (var item in items) {
      // Contar por tipo
      switch (item.type) {
        case InventoryItemType.product:
          products++;
          break;
        case InventoryItemType.service:
          services++;
          break;
        case InventoryItemType.request:
          questions++;
          break;
        case InventoryItemType.poll:
          polls++;
          break;
        case InventoryItemType.news:
          news++;
          break;
        case InventoryItemType.offer:
          offers++;
          break;
        case InventoryItemType.community:
          break;
      }
      
      // Contar por estado
      if (item.status == InventoryItemStatus.active) active++;
      if (item.status == InventoryItemStatus.sold) sold++;
      
      // Sumar métricas
      views += item.metrics.views;
      likes += item.metrics.likes;
      comments += item.metrics.comments;
      chats += item.metrics.chats;
      revenue += item.metrics.revenue;
      engagementSum += item.metrics.engagementRate;
    }
    
    return InventorySummary(
      totalItems: items.length,
      activeItems: active,
      soldItems: sold,
      totalProducts: products,
      totalServices: services,
      totalQuestions: questions,
      totalPolls: polls,
      totalNews: news,
      totalOffers: offers,
      totalViews: views,
      totalLikes: likes,
      totalComments: comments,
      totalChats: chats,
      totalRevenue: revenue,
      avgEngagement: items.isNotEmpty ? engagementSum / items.length : 0.0,
    );
  }
}
