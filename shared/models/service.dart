class Service {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  
  final double? pricingFrom;
  final double? pricingTo;
  final String? pricingUnit;
  
  final String? availability;
  final bool isAvailable;
  
  final List<String> imageUrls;
  
  final int viewsCount;
  final int requestsCount;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? authorId;
  final String? authorName;
  final String? authorDisplayName;
  final String? authorAccountType;
  final double? authorRating;
  final int? authorReviewCount;
  final String? location;
  
  @Deprecated('Use pricingFrom instead')
  double? get rate => pricingFrom;

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
    this.imageUrls = const [],
    this.viewsCount = 0,
    this.requestsCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.authorId,
    this.authorName,
    this.authorDisplayName,
    this.authorAccountType,
    this.authorRating,
    this.authorReviewCount,
    this.location,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>?;
    
    return Service(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      pricingFrom: json['pricing_from'] != null 
          ? (json['pricing_from'] as num).toDouble() 
          : null,
      pricingTo: json['pricing_to'] != null 
          ? (json['pricing_to'] as num).toDouble() 
          : null,
      pricingUnit: json['pricing_unit'] as String?,
      availability: json['availability'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : [],
      viewsCount: json['views_count'] as int? ?? 0,
      requestsCount: json['requests_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      authorId: provider?['id'] as String?,
      authorName: provider?['name'] as String?,
      authorDisplayName: provider?['username'] as String?,
      authorAccountType: provider?['account_type'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'image_urls': imageUrls,
      'views_count': viewsCount,
      'requests_count': requestsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
