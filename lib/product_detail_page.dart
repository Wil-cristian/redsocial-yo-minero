import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';
import 'core/theme/colors.dart';

/// Displays detailed information about a product with beautiful design
/// and enhanced user interactions including cart, favorites, and sharing.
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with TickerProviderStateMixin {
  bool _isFavorite = false;
  bool _inCart = false;
  int _quantity = 1;
  late AnimationController _cartAnimationController;
  late AnimationController _favoriteAnimationController;

  @override
  void initState() {
    super.initState();
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        _favoriteAnimationController.forward().then((_) {
          _favoriteAnimationController.reverse();
        });
      }
    });
  }

  void _addToCart() {
    setState(() {
      _inCart = true;
      _cartAnimationController.forward().then((_) {
        _cartAnimationController.reverse();
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProductHeaderContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 60,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: 130,
            left: -25,
            child: Container(
              width: 90,
              height: 90,
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
                // Product icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    _getProductIcon(),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Product name
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _buildProductStatChip(widget.product.inStock ? 'Disponible' : 'Agotado', 'Estado'),
                    const SizedBox(width: 12),
                    _buildProductStatChip('★★★★☆', 'Rating'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon() {
    final name = widget.product.name.toLowerCase();
    if (name.contains('casco')) return Icons.construction;
    if (name.contains('linterna')) return Icons.flashlight_on;
    if (name.contains('guantes')) return Icons.back_hand;
    if (name.contains('botas')) return Icons.work;
    if (name.contains('chaleco')) return Icons.warning;
    if (name.contains('detector')) return Icons.sensors;
    if (name.contains('herramienta')) return Icons.build;
    if (name.contains('equipo')) return Icons.precision_manufacturing;
    return Icons.inventory;
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
                child: AnimatedBuilder(
                  animation: _favoriteAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_favoriteAnimationController.value * 0.2),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
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
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartir producto próximamente')),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductHeaderContent(),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description section
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
                      'Descripción',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.product.description,
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
              
              // Specifications section
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
                      'Especificaciones',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSpecRow('Estado', widget.product.inStock ? 'Disponible' : 'Agotado'),
                    _buildSpecRow('Precio', '\$${widget.product.price.toStringAsFixed(2)}'),
                    _buildSpecRow('Categoría', 'Equipos y Herramientas'),
                    _buildSpecRow('Condición', 'Nuevo'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _cartAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_cartAnimationController.value * 0.05),
                            child: ElevatedButton.icon(
                              onPressed: widget.product.inStock ? _addToCart : null,
                              icon: const Icon(Icons.shopping_cart, color: AppColors.primary),
                              label: Text(
                                widget.product.inStock ? 'Agregar al Carrito' : 'No Disponible',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          );
                        },
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

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
