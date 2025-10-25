import 'package:yominero/shared/models/post.dart';

/// Abstraction for retrieving and mutating posts.
abstract class PostRepository {
  /// Retrieve all posts (newest first).
  Future<List<Post>> getAll();

  /// Create a post of any type. For simple community post, just leave defaults.
  /// If the caller is authenticated, the repository will prefer the authenticated
  /// user's id as the author; the `author` parameter can be used as a fallback.
  Future<Post> create({
    String? author,
    required String title,
    required String content,
    PostType type,
    List<String> tags,
    List<String> categories,
    // request specific
    List<String>? requiredTags,
    double? budgetAmount,
    String? budgetCurrency,
    DateTime? deadline,
    // offer/service specific
    String? serviceName,
    List<String>? serviceTags,
    double? pricingFrom,
    double? pricingTo,
    String? pricingUnit,
    String? availability,
    // product specific
    List<String>? productImages,
    double? productPrice,
    String? productCurrency,
    int? productStock,
    String? productCondition,
    // news specific
    String? newsSource,
    String? newsAuthor,
    String? newsCoverImage,
    // poll specific
    List<String>? pollOptions,
    Map<String, int>? pollVotes,
    bool? pollAllowMultiple,
    DateTime? pollEndsAt,
  });

  /// Returns true if like was applied, false if user had already liked.
  /// If `userId` is omitted the repository should prefer the authenticated user.
  Future<bool> like(String postId, [String? userId]);
  Future<bool> hasUserLiked(String postId, [String? userId]);
}
