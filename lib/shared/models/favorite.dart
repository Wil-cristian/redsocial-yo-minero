class Favorite {
  final String id;
  final String userId;
  final String? productId;
  final String? serviceId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    this.productId,
    this.serviceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isProduct => productId != null;
  bool get isService => serviceId != null;

  String get itemId => productId ?? serviceId ?? '';

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String?,
      serviceId: json['service_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'service_id': serviceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'user_id': userId,
      'product_id': productId,
      'service_id': serviceId,
    };
  }
}
