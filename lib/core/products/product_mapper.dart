import 'package:yominero/shared/models/product.dart';

Product mapRowToProduct(Map<String, dynamic> r) {
  return Product(
    id: r['id']?.toString() ?? '',
    name: r['name']?.toString() ?? 'No name',
    description: r['description']?.toString() ?? '',
    price: double.tryParse(r['price']?.toString() ?? '0') ?? 0.0,
    imageUrl: r['image_url']?.toString(),
    inStock: (r['in_stock'] == null)
        ? true
        : (r['in_stock'] == true || r['in_stock'].toString() == '1'),
    
    // Información del autor desde la base de datos
    authorId: r['author_id']?.toString() ?? 'unknown',
    authorName: r['author_name']?.toString() ?? 'Usuario desconocido',
    authorDisplayName: r['author_display_name']?.toString() ?? r['author_name']?.toString() ?? 'Usuario desconocido',
    authorAccountType: r['author_account_type']?.toString() ?? 'individual',
    authorAvatarUrl: r['author_avatar_url']?.toString(),
    authorRating: double.tryParse(r['author_rating']?.toString() ?? '0') ?? 0.0,
    authorReviewCount: int.tryParse(r['author_review_count']?.toString() ?? '0') ?? 0,
    createdAt: r['created_at'] != null ? DateTime.parse(r['created_at'].toString()) : null,
    updatedAt: r['updated_at'] != null ? DateTime.parse(r['updated_at'].toString()) : null,
  );
}
