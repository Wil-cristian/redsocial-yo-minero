enum PostType { 
  community,   // Post normal/general
  request,     // Pregunta/solicitud
  offer,       // Oferta/servicio
  product,     // Venta de producto (con carrusel de imágenes)
  news,        // Noticias/artículos informativos
  service,     // Servicio específico (con interactividad)
  poll,        // Encuesta con opciones múltiples
}

class Post {
  final String id;
  final PostType type;
  final String authorId;
  final String title;
  final String content; // renamed from body to keep existing uses
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> categories;
  final List<String> tags;
  final String? imageUrl;
  final int likes;
  final int comments;
  final bool active;

  // Request specific (Preguntas/Solicitudes)
  final List<String>? requiredTags;
  final double? budgetAmount;
  final String? budgetCurrency;
  final DateTime? deadline;

  // Offer/Service specific (Ofertas/Servicios)
  final String? serviceName;
  final List<String>? serviceTags;
  final double? pricingFrom;
  final double? pricingTo;
  final String? pricingUnit;
  final String? availability;

  // Product specific (Ventas con carrusel)
  final List<String>? productImages; // URLs de múltiples imágenes
  final double? productPrice;
  final String? productCurrency;
  final int? productStock;
  final String? productCondition; // nuevo, usado, excelente, etc.

  // News/Article specific (Noticias/Artículos)
  final String? newsSource; // Fuente de la noticia
  final String? newsAuthor; // Autor del artículo
  final String? newsCoverImage; // Imagen principal de la noticia

  // Poll specific (Encuestas)
  final List<String>? pollOptions; // Opciones de la encuesta ['Opción 1', 'Opción 2', ...]
  final Map<String, int>? pollVotes; // Votos por opción {'Opción 1': 15, 'Opción 2': 8, ...}
  final bool? pollAllowMultiple; // ¿Permite seleccionar múltiples opciones?
  final DateTime? pollEndsAt; // Fecha de cierre de la encuesta

  const Post({
    required this.id,
    required this.type,
    required this.authorId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.categories = const [],
    this.tags = const [],
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.active = true,
    // Request fields
    this.requiredTags,
    this.budgetAmount,
    this.budgetCurrency,
    this.deadline,
    // Offer/Service fields
    this.serviceName,
    this.serviceTags,
    this.pricingFrom,
    this.pricingTo,
    this.pricingUnit,
    this.availability,
    // Product fields
    this.productImages,
    this.productPrice,
    this.productCurrency,
    this.productStock,
    this.productCondition,
    // News/Article fields
    this.newsSource,
    this.newsAuthor,
    this.newsCoverImage,
    // Poll fields
    this.pollOptions,
    this.pollVotes,
    this.pollAllowMultiple,
    this.pollEndsAt,
  });



  Post copyWith({
    PostType? type,
    String? authorId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? categories,
    List<String>? tags,
    String? imageUrl,
    int? likes,
    int? comments,
    bool? active,
    List<String>? requiredTags,
    double? budgetAmount,
    String? budgetCurrency,
    DateTime? deadline,
    String? serviceName,
    List<String>? serviceTags,
    double? pricingFrom,
    double? pricingTo,
    String? pricingUnit,
    String? availability,
  }) =>
      Post(
        id: id,
        type: type ?? this.type,
        authorId: authorId ?? this.authorId,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        categories: categories ?? this.categories,
        tags: tags ?? this.tags,
        imageUrl: imageUrl ?? this.imageUrl,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        active: active ?? this.active,
        requiredTags: requiredTags ?? this.requiredTags,
        budgetAmount: budgetAmount ?? this.budgetAmount,
        budgetCurrency: budgetCurrency ?? this.budgetCurrency,
        deadline: deadline ?? this.deadline,
        serviceName: serviceName ?? this.serviceName,
        serviceTags: serviceTags ?? this.serviceTags,
        pricingFrom: pricingFrom ?? this.pricingFrom,
        pricingTo: pricingTo ?? this.pricingTo,
        pricingUnit: pricingUnit ?? this.pricingUnit,
        availability: availability ?? this.availability,
      );

  /// Backwards helper for older simple constructor usage.
  factory Post.simple({
    required String id,
    required String title,
    required String content,
    required String author,
    required DateTime createdAt,
    String? imageUrl,
    int likes = 0,
    int comments = 0,
  }) =>
      Post(
        id: id,
        type: PostType.community,
        authorId: author,
        title: title,
        content: content,
        createdAt: createdAt,
        imageUrl: imageUrl,
        likes: likes,
        comments: comments,
      );
}
