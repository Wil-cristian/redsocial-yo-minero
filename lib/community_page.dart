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
                          color: AppColorsUnified.orange.withOpacity(0.1),
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
                        color: AppColorsUnified.orange.withOpacity(0.1),
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
                        AppColorsUnified.fade(AppColorsUnified.orange, 0.1).withOpacity(0.1),
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
                  colors: [AppColorsUnified.orange, AppColorsUnified.orange.withOpacity(0.8)],
                )
              : null,
          color: selected ? null : AppColorsUnified.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColorsUnified.orange : AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: AppColorsUnified.orange.withOpacity(0.3),
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

class _PostCard extends StatefulWidget {
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

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isLikeAnimating = false;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  int? _hoveredChipIndex;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _handleLikeAnimation() {
    setState(() => _isLikeAnimating = true);
    widget.likeTap();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLikeAnimating = false);
    });
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final liked = widget.liked;
    final score = widget.score;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleController.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsUnified.pureWhite,
                      _isHovered ? AppColorsUnified.grey50 : AppColorsUnified.pureWhite,
                    ],
                  ),
                  border: Border.all(
                    color: _isHovered 
                        ? AppColorsUnified.gold.withOpacity(0.4)
                        : AppColorsUnified.grey200,
                    width: _isHovered ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppColorsUnified.gold.withOpacity(0.2)
                          : AppColorsUnified.shadowMedium,
                      blurRadius: _isHovered ? 28 : 12,
                      spreadRadius: _isHovered ? 3 : 0,
                      offset: Offset(0, _isHovered ? 10 : 4),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: AppColorsUnified.goldBright.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Shimmer effect en hover
                    if (_isHovered)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment(-1.0 + (_shimmerController.value * 3), -1.0),
                                  end: Alignment(1.0 + (_shimmerController.value * 3), 1.0),
                                  colors: [
                                    Colors.transparent,
                                    AppColorsUnified.goldBright.withOpacity(0.05),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.postDetail,
                          arguments: post,
                        ),
                        splashColor: AppColorsUnified.gold.withOpacity(0.1),
                        highlightColor: AppColorsUnified.gold.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header con avatar y usuario
                              Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isHovered
                                            ? AppColorsUnified.gold
                                            : AppColorsUnified.gold.withOpacity(0.3),
                                        width: _isHovered ? 2.5 : 2,
                                      ),
                                      boxShadow: _isHovered
                                          ? [
                                              BoxShadow(
                                                color: AppColorsUnified.gold.withOpacity(0.3),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: AppColorsUnified.gold.withOpacity(0.15),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColorsUnified.grey100,
                                      backgroundImage: post.authorProfileImage != null 
                                          ? NetworkImage(post.authorProfileImage!) 
                                          : null,
                                      child: post.authorProfileImage == null
                                          ? Text(
                                              (post.authorName ?? post.title)[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: AppColorsUnified.gold,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.authorName ?? post.authorUsername ?? 'Usuario ${post.authorId.substring(0, 8)}',
                                          style: const TextStyle(
                                            color: AppColorsUnified.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          _humanDate(DateTime(post.createdAt.year,
                                              post.createdAt.month, post.createdAt.day)),
                                          style: const TextStyle(
                                            color: AppColorsUnified.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (score != null)
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: 1.0 + (0.05 * _pulseController.value),
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColorsUnified.goldHighlight,
                                                  AppColorsUnified.goldBright,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColorsUnified.gold.withOpacity(0.4),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColorsUnified.gold.withValues(
                                                    alpha: 0.2 + (0.1 * _pulseController.value),
                                                  ),
                                                  blurRadius: 8 + (4 * _pulseController.value),
                                                  spreadRadius: _pulseController.value * 2,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  color: AppColorsUnified.gold,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$score',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColorsUnified.goldShadow,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  const Icon(
                                    Icons.more_vert_rounded,
                                    color: AppColorsUnified.textSecondary,
                                    size: 22,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              
                              // Título del post
                              Text(
                                post.title,
                                style: const TextStyle(
                                  color: AppColorsUnified.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Contenido
                              Text(
                                post.content,
                                style: const TextStyle(
                                  color: AppColorsUnified.textSecondary,
                                  fontSize: 15,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              // Chips de información (precio, disponibilidad, etc.)
                              if (_hasMetadata(post)) ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    // Precio de producto
                                    if (post.productPrice != null)
                                      _buildInteractiveChip(
                                        0,
                                        '\$${post.productPrice!.toStringAsFixed(2)}',
                                        Icons.attach_money_rounded,
                                        AppColorsUnified.gold,
                                        isPrimary: true,
                                      ),
                                    
                                    // Rango de precios (servicios/ofertas)
                                    if (post.pricingFrom != null)
                                      _buildInteractiveChip(
                                        1,
                                        'Desde \$${post.pricingFrom!.toInt()}',
                                        Icons.money_rounded,
                                        AppColorsUnified.success,
                                      ),
                                    if (post.pricingTo != null)
                                      _buildInteractiveChip(
                                        2,
                                        'Hasta \$${post.pricingTo!.toInt()}',
                                        Icons.trending_up_rounded,
                                        AppColorsUnified.warning,
                                      ),
                                    
                                    // Disponibilidad
                                    if (post.availability != null)
                                      _buildInteractiveChip(
                                        3,
                                        post.availability!,
                                        Icons.schedule_rounded,
                                        AppColorsUnified.companyBlue,
                                      ),
                                    
                                    // Stock de producto
                                    if (post.productStock != null && post.productStock! > 0)
                                      _buildInteractiveChip(
                                        4,
                                        '${post.productStock} en stock',
                                        Icons.inventory_2_rounded,
                                        AppColorsUnified.success,
                                      ),
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 18),
                              
                              // Acciones (Like, Comentar, Compartir)
                              Row(
                                children: [
                                  _buildInteractiveActionButton(
                                    icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    label: post.likes.toString(),
                                    color: liked ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
                                    isActive: liked,
                                    onTap: _handleLikeAnimation,
                                  ),
                                  const SizedBox(width: 10),
                                  _buildInteractiveActionButton(
                                    icon: Icons.chat_bubble_outline_rounded,
                                    label: '0',
                                    color: AppColorsUnified.textSecondary,
                                    isActive: false,
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 10),
                                  _buildInteractiveActionButton(
                                    icon: Icons.share_rounded,
                                    label: '',
                                    color: AppColorsUnified.textSecondary,
                                    isActive: false,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              
                              // CTA para PREGUNTAS - Invita a responder
                              if (post.type == PostType.request) ...[
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColorsUnified.goldHighlight.withOpacity(0.3),
                                        AppColorsUnified.grey50,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColorsUnified.gold.withOpacity(_isHovered ? 0.4 : 0.2),
                                      width: _isHovered ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: AppColorsUnified.goldRadialGradient,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColorsUnified.gold.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.question_answer_rounded,
                                              color: AppColorsUnified.goldDeep,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '¿Tienes la respuesta?',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColorsUnified.textPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Ayuda a esta persona con tu conocimiento',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColorsUnified.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      _buildQuestionCTAButton(
                                        label: 'Responder Pregunta',
                                        icon: Icons.edit_rounded,
                                        onTap: () {
                                          // TODO: Abrir modal de respuesta
                                          debugPrint('Responder pregunta: ${post.id}');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  bool _hasMetadata(Post post) {
    return post.productPrice != null ||
        post.pricingFrom != null ||
        post.pricingTo != null ||
        post.availability != null ||
        (post.productStock != null && post.productStock! > 0);
  }
  
  Widget _buildInteractiveChip(int index, String text, IconData icon, Color color, {bool isPrimary = false}) {
    final isHovered = _hoveredChipIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredChipIndex = index),
      onExit: (_) => setState(() => _hoveredChipIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isHovered ? -2 : 0, 0),
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 14 : 12,
          vertical: isPrimary ? 10 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    AppColorsUnified.goldHighlight,
                    AppColorsUnified.goldBright.withOpacity(0.5),
                  ],
                )
              : null,
          color: isPrimary ? null : color.withOpacity(isHovered ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(isHovered ? (isPrimary ? 0.6 : 0.4) : (isPrimary ? 0.4 : 0.2)),
            width: isHovered ? (isPrimary ? 2 : 1.5) : (isPrimary ? 1.5 : 1),
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: color.withOpacity(isPrimary ? 0.3 : 0.2),
                    blurRadius: isPrimary ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : isPrimary
                  ? [
                      BoxShadow(
                        color: AppColorsUnified.gold.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isPrimary ? AppColorsUnified.goldShadow : color,
                size: isHovered ? (isPrimary ? 20 : 18) : (isPrimary ? 18 : 16),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isPrimary ? AppColorsUnified.goldDeep : color,
                fontSize: isHovered ? (isPrimary ? 15 : 14) : (isPrimary ? 14 : 13),
                fontWeight: isHovered ? FontWeight.w800 : (isPrimary ? FontWeight.w700 : FontWeight.w600),
              ),
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInteractiveActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: _isLikeAnimating && isActive ? 1.2 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: color.withOpacity(0.2),
            highlightColor: color.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColorsUnified.gold.withOpacity(0.15)
                    : AppColorsUnified.grey100,
                borderRadius: BorderRadius.circular(24),
                border: isActive
                    ? Border.all(
                        color: AppColorsUnified.gold.withOpacity(0.4),
                        width: 1.5,
                      )
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColorsUnified.gold.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: RotationTransition(
                          turns: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      color: color,
                      size: 20,
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: color,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: Text(label),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildQuestionCTAButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setLocalState(() => isHovered = true),
          onExit: (_) => setLocalState(() => isHovered = false),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, pulseValue, child) {
              final pulse = !isHovered ? (1.0 + 0.06 * (pulseValue % 1)) : 1.0;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                transform: Matrix4.identity()
                  ..scale(isHovered ? 1.03 : 1.0)
                  ..scale(pulse),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(14),
                    splashColor: AppColorsUnified.gold.withOpacity(0.3),
                    highlightColor: AppColorsUnified.gold.withOpacity(0.2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isHovered
                              ? [
                                  AppColorsUnified.gold,
                                  AppColorsUnified.goldShadow,
                                ]
                              : [
                                  AppColorsUnified.gold.withOpacity(0.9),
                                  AppColorsUnified.gold,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: AppColorsUnified.gold.withOpacity(0.5),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: AppColorsUnified.gold.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: AppColorsUnified.gold.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            transform: Matrix4.identity()
                              ..scale(isHovered ? 1.15 : 1.0),
                            child: Icon(
                              icon,
                              color: AppColorsUnified.pureWhite,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: isHovered ? 17 : 16,
                              fontWeight: isHovered ? FontWeight.w900 : FontWeight.w800,
                              color: AppColorsUnified.pureWhite,
                              letterSpacing: 0.8,
                            ),
                            child: Text(label),
                          ),
                          const SizedBox(width: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            transform: Matrix4.identity()
                              ..translate(isHovered ? 4.0 : 0.0, 0.0, 0.0),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColorsUnified.pureWhite,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

