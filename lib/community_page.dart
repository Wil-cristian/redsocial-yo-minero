import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/auth/supabase_auth_service.dart';
import 'package:yominero/shared/models/post.dart';
import 'core/routing/app_router.dart';
import 'core/di/locator.dart';
import 'features/posts/domain/post_repository.dart';
import 'features/posts/ui/post_creation_sheet.dart';
import 'core/matching/match_engine.dart';
import 'core/matching/suggestion_cache.dart';
import 'core/theme/animations.dart';
import 'core/theme/glass_card.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final PostRepository _repo;
  late List<Post> _posts;
  String _query = '';
  PostSort _sort = PostSort.recent;
  List<MatchResult> _suggestions = [];
  final Map<String, int> _suggestionScores = {};
  final Map<String, bool> _likesCache = {};

  @override
  void initState() {
    super.initState();
    _repo = sl<PostRepository>();
    _posts = [];
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _repo
          .getAll()
          .timeout(const Duration(seconds: 8), onTimeout: () => <Post>[]);
      _posts = posts;
      final user = SupabaseAuthService.instance.currentUser;
      _likesCache.clear();
      if (user != null) {
        // populate likes cache (simple per-post checks)
        for (final p in _posts) {
          try {
            final liked = await _repo.hasUserLiked(p.id, user.id);
            _likesCache[p.id] = liked;
          } catch (_) {
            _likesCache[p.id] = false;
          }
        }
      }
      _computeSuggestions();
      if (mounted) setState(() {});
    } catch (e) {
      // keep previous list on error
      if (mounted) setState(() {});
    }
  }

  void _computeSuggestions() {
    // MatchEngine migrado a trabajar con Supabase User Profile
    // Temporalmente desactivado - Las sugerencias no se mostrarán
    _suggestions = [];
    _suggestionScores.clear();
    return;
    
    /* CODIGO ORIGINAL - COMENTADO HASTA MIGRAR MATCHENGINE
    final user = SupabaseAuthService.instance.currentUser;
    if (user == null) {
      _suggestions = [];
      return;
    }
    final signature = buildPostSignature(_posts);
    _suggestions = SuggestionCache.instance.getOrCompute(
      userId: user.id,
      signature: signature,
      builder: () {
        final reqs = MatchEngine.requestsForUser(user, _posts, threshold: 30);
        final opps =
            MatchEngine.opportunitiesForUser(user, _posts, threshold: 30);
        final byId = <String, MatchResult>{};
        for (final r in [...reqs, ...opps]) {
          final existing = byId[r.post.id];
          if (existing == null || r.score > existing.score) {
            byId[r.post.id] = r;
          }
        }
        final all = byId.values.toList();
        all.sort((a, b) => b.score.compareTo(a.score));
        return all.take(10).toList();
      },
    );
    _suggestionScores
      ..clear()
      ..addEntries(_suggestions.map((m) => MapEntry(m.post.id, m.score)));
    */
  }

  List<Post> _filteredSorted() {
    var list = List<Post>.from(_posts);
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.content.toLowerCase().contains(q))
          .toList();
    }
    list.sort((a, b) => _sort == PostSort.popular
        ? b.likes.compareTo(a.likes)
        : b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Map<String, List<Post>> _group(List<Post> posts) {
    final map = <String, List<Post>>{};
    for (final p in posts) {
      final d = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
      final key = _humanDate(d);
      map.putIfAbsent(key, () => []).add(p);
    }
    return map;
  }

  String _humanDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final base = DateTime(date.year, date.month, date.day);
    if (base == today) return 'Hoy';
    if (base == yesterday) return 'Ayer';
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  Future<void> _likePost(Post post) async {
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;
    final user = SupabaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para dar like.')),
      );
      return;
    }
    final applied = await _repo.like(post.id, user.id);
    if (!applied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya le diste like a este post.')),
        );
      }
      return;
    }
    // optimistically update local state
    if (!mounted) return;
    setState(() {
      final current = _posts[idx];
      _posts[idx] = current.copyWith(likes: current.likes + 1);
      _likesCache[post.id] = true;
      _computeSuggestions();
    });
  }

  void _openCreatePost() {
    final user = SupabaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para publicar.')),
      );
      return;
    }
    
    final profile = SupabaseAuthService.instance.currentUserProfile;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PostCreationSheet(
        authorName: profile?['name'] ?? 'Usuario',
        create: ({
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
        }) async {
          return _repo.create(
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
        },
        onCreated: (post) async {
          _query = '';
          _sort = PostSort.recent;
          // Invalidate cache for current user to force recompute next access
          final u = SupabaseAuthService.instance.currentUser;
          if (u != null) SuggestionCache.instance.invalidateUser(u.id);
          await _loadPosts();
          if (!mounted) return;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Publicado: ${post.title}')),
          );
        },
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      height: 100,
      decoration: BoxDecoration(gradient: AppColorsUnified.greySoftGradient),  // Blanco perla suave
      child: const SafeArea(child: Center(child: Text('Comunidad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColorsUnified.textPrimary)))),  // Texto negro
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredSorted();
    final grouped = _group(list);
    final orderedKeys = list
        .map((p) => _humanDate(
              DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day),
            ))
        .toList();
    final seen = <String>{};
    final keys = <String>[];
    for (final k in orderedKeys) {
      if (seen.add(k)) keys.add(k);
    }

    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        backgroundColor: AppColorsUnified.gold,  // ⭐ ORO en vez de gris
        elevation: 8,
        icon: const Icon(Icons.add, color: AppColorsUnified.textPrimary),  // Icono negro
        label: const Text(
          'Nueva Publicación',
          style: TextStyle(
            color: AppColorsUnified.textPrimary,  // Texto negro sobre oro
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Nuevo header customizable con efectos premium
          SliverToBoxAdapter(
            child: _buildSimpleHeader(),
          ),
        ],
        body: Column(
        children: [
          // Enhanced Search Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColorsUnified.pureWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColorsUnified.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColorsUnified.background),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar en la comunidad...',
                      hintStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.search, color: AppColorsUnified.orange, size: 20),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip(
                      'Recientes',
                      Icons.schedule,
                      _sort == PostSort.recent,
                      () => setState(() => _sort = PostSort.recent),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip(
                      'Populares',
                      Icons.trending_up,
                      _sort == PostSort.popular,
                      () => setState(() => _sort = PostSort.popular),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${list.length} posts',
                        style: const TextStyle(
                          color: AppColorsUnified.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount:
                  keys.fold<int>(0, (acc, k) => acc + 1 + grouped[k]!.length) +
                      (_suggestions.isNotEmpty ? 1 : 0),
              itemBuilder: (context, globalIndex) {
                int index = globalIndex;
                if (_suggestions.isNotEmpty) {
                  if (index == 0) {
                    return _buildSuggestionsSection();
                  }
                  index -= 1; // shift for suggestions header block
                }
                int cursor = 0;
                for (final k in keys) {
                  if (index == cursor) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Text(
                        k,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.charcoal,
                            ),
                      ),
                    );
                  }
                  cursor++;
                  final postsOfDay = grouped[k]!;
                  if (index < cursor + postsOfDay.length) {
                    final post = postsOfDay[index - cursor];
                    final user = SupabaseAuthService.instance.currentUser;
                    final liked =
                        user != null && (_likesCache[post.id] ?? false);
                    return FadeInSlide(
                      duration: AppDurations.normal,
                      delay: Duration(milliseconds: 50 * (index - cursor)),
                      child: _PostCard(
                        post: post,
                        liked: liked,
                        likeTap: () => _likePost(post),
                        score: _suggestionScores[post.id],
                      ),
                    );
                  }
                  cursor += postsOfDay.length;
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Sugeridos para ti',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final mr = _suggestions[i];
              final p = mr.post;
              return ScaleFadeIn(
                duration: AppDurations.normal,
                delay: Duration(milliseconds: 80 * i),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.postDetail,
                    arguments: p,
                  ),
                  child: SizedBox(
                    width: 240,
                    child: PremiumCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      gradientColors: [
                        AppColorsUnified.pureWhite,
                        AppColorsUnified.fade(AppColorsUnified.orange, 0.1).withValues(alpha: 0.1),
                      ],
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.type.name,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColorsUnified.orange,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          Text('${mr.score} pts',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsUnified.orange)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          p.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColorsUnified.charcoal, height: 1.3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (p.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: -6,
                          children: p.tags.take(3).map((t) {
                            return Chip(
                              label:
                                  Text(t, style: const TextStyle(fontSize: 10)),
                              backgroundColor: AppColors.secondaryContainer,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                    ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [AppColorsUnified.orange, AppColorsUnified.orange.withValues(alpha: 0.8)],
                )
              : null,
          color: selected ? null : AppColorsUnified.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColorsUnified.orange : AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: AppColorsUnified.orange.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColorsUnified.pureWhite : AppColorsUnified.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColorsUnified.pureWhite : AppColorsUnified.charcoal,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PostSort { recent, popular }

class _PostCard extends StatelessWidget {
  final Post post;
  final bool liked;
  final VoidCallback likeTap;
  final int? score;
  const _PostCard({
    required this.post,
    required this.liked,
    required this.likeTap,
    this.score,
  });

  String _humanDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final base = DateTime(date.year, date.month, date.day);
    if (base == today) return 'Hoy';
    if (base == yesterday) return 'Ayer';
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.postDetail,
        arguments: post,
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppColors.secondaryContainer.withValues(alpha: .6),
                  backgroundImage: post.authorProfileImage != null 
                      ? NetworkImage(post.authorProfileImage!) 
                      : null,
                  child: post.authorProfileImage == null
                      ? Text(
                          (post.authorName ?? post.title)[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColorsUnified.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ?? post.authorUsername ?? 'Usuario ${post.authorId.substring(0, 8)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _humanDate(DateTime(post.createdAt.year,
                            post.createdAt.month, post.createdAt.day)),
                        style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (score != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$score pts',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.orange)),
                  ),
                Icon(Icons.more_vert, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColorsUnified.charcoal, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: likeTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: liked
                          ? AppColorsUnified.orange.withValues(alpha: .15)
                          : AppColorsUnified.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? AppColorsUnified.orange : AppColorsUnified.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.likes.toString(),
                          style: TextStyle(
                            color: liked ? AppColorsUnified.orange : AppColorsUnified.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: AppColorsUnified.textSecondary, size: 18),
                      SizedBox(width: 6),
                      Text('0',
                          style: TextStyle(
                              color: AppColorsUnified.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share_outlined,
                      color: AppColorsUnified.textSecondary, size: 18),
                ),
              ],
            ),
          ],
      ),
    );
  }
}
