import 'package:yominero/features/posts/domain/post_repository.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/features/posts/data/in_memory_post_repository.dart';

// Stub that delegates to the in-memory repo; kept temporarily for API stability
class PostRepositorySupabase implements PostRepository {
  final InMemoryPostRepository _delegate = InMemoryPostRepository();

  @override
  Future<Post> create({
    String? author,
    required String title,
    required String content,
    PostType type = PostType.community,
    List<String> tags = const [],
    List<String> categories = const [],
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
    List<String>? productImages,
    double? productPrice,
    String? productCurrency,
    int? productStock,
    String? productCondition,
    String? newsSource,
    String? newsAuthor,
    String? newsCoverImage,
    List<String>? pollOptions,
    Map<String, int>? pollVotes,
    bool? pollAllowMultiple,
    DateTime? pollEndsAt,
  }) =>
      _delegate.create(
        author: author,
        title: title,
        content: content,
        type: type,
        tags: tags,
        categories: categories,
        requiredTags: requiredTags,
        budgetAmount: budgetAmount,
        budgetCurrency: budgetCurrency,
        deadline: deadline,
        serviceName: serviceName,
        serviceTags: serviceTags,
        pricingFrom: pricingFrom,
        pricingTo: pricingTo,
        pricingUnit: pricingUnit,
        availability: availability,
        productImages: productImages,
        productPrice: productPrice,
        productCurrency: productCurrency,
        productStock: productStock,
        productCondition: productCondition,
        newsSource: newsSource,
        newsAuthor: newsAuthor,
        newsCoverImage: newsCoverImage,
        pollOptions: pollOptions,
        pollVotes: pollVotes,
        pollAllowMultiple: pollAllowMultiple,
        pollEndsAt: pollEndsAt,
      );

  @override
  Future<List<Post>> getAll() => _delegate.getAll();

  @override
  Future<bool> hasUserLiked(String postId, [String? userId]) =>
      _delegate.hasUserLiked(postId, userId);

  @override
  Future<bool> like(String postId, [String? userId]) =>
      _delegate.like(postId, userId);
}
