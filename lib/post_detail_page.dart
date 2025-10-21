import 'package:flutter/material.dart';
import 'package:yominero/shared/models/post.dart';
import 'core/theme/colors.dart';

/// Page that displays the full content of a post with beautiful design
/// and enhanced user interactions including likes, comments, and sharing.
class PostDetailPage extends StatefulWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> with TickerProviderStateMixin {
  late int _likes;
  bool _isLiked = false;
  late AnimationController _likeAnimationController;
  late AnimationController _scrollController;

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likes -= 1;
        _isLiked = false;
      } else {
        _likes += 1;
        _isLiked = true;
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reverse();
        });
      }
    });
  }

  Widget _buildPostHeaderContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 40,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Main content
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post type icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    _getPostTypeIcon(),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Subtitle with author info
                Text(
                  'Publicación de la comunidad',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _buildDetailStatChip('$_likes', 'Likes'),
                    const SizedBox(width: 12),
                    _buildDetailStatChip(_getTimeAgo(), 'Hace'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPostTypeIcon() {
    final content = widget.post.content.toLowerCase();
    if (content.contains('trabajo') || content.contains('empleo')) return Icons.work;
    if (content.contains('venta') || content.contains('vendo')) return Icons.sell;
    if (content.contains('busco') || content.contains('necesito')) return Icons.search;
    if (content.contains('ayuda') || content.contains('apoyo')) return Icons.help;
    return Icons.article;
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.post.createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de compartir próximamente')),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardado en favoritos')),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildPostHeaderContent(),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenido',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.post.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Actions section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Like button
                    GestureDetector(
                      onTap: _toggleLike,
                      child: AnimatedBuilder(
                        animation: _likeAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_likeAnimationController.value * 0.2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: _isLiked 
                                    ? LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      )
                                    : null,
                                color: _isLiked ? null : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isLiked ? AppColors.primary : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isLiked ? Icons.favorite : Icons.favorite_outline,
                                    color: _isLiked ? Colors.white : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_likes',
                                    style: TextStyle(
                                      color: _isLiked ? Colors.white : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Comment button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.comment_outlined, color: AppColors.textSecondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Comentar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Share button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Compartir',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
