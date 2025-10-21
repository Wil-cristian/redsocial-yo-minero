import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';
import 'core/di/locator.dart';
import 'features/products/domain/product_repository.dart';
import 'core/theme/colors.dart';
import 'core/routing/app_router.dart';
import 'core/auth/auth_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductRepository _repo;
  late List<Product> _allProducts;
  bool _isLoadingRemote = false;
  String? _remoteError;

  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  final List<String> _categories = const [
    'Todos',
    'Seguridad',
    'Herramientas',
    'Equipos',
    'Accesorios',
  ];

  final List<Color> _productColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.info,
    AppColors.warning,
    AppColors.primaryContainer,
    AppColors.secondaryContainer,
    AppColors.textSecondary,
  ];

  @override
  void initState() {
    super.initState();
    _repo = sl<ProductRepository>();
    _allProducts = [];

    _isLoadingRemote = true;
    () async {
      try {
        final remoteProducts = await _repo.getAll();
        if (mounted) {
          setState(() {
            _allProducts = remoteProducts;
            _isLoadingRemote = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _remoteError = e.toString();
            _isLoadingRemote = false;
          });
        }
      }
    }();
  }

  List<Product> get filtered {
    var list = _allProducts;

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                       p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != 'Todos') {
      // Simple category matching - in a real app this would be more sophisticated
      list = list.where((p) {
        final name = p.name.toLowerCase();
        switch (_selectedCategory) {
          case 'Seguridad':
            return name.contains('casco') || name.contains('chaleco') || name.contains('detector');
          case 'Herramientas':
            return name.contains('martillo') || name.contains('taladro');
          case 'Equipos':
            return name.contains('detector') || name.contains('martillo');
          case 'Accesorios':
            return name.contains('guantes') || name.contains('cuerda') || name.contains('linterna');
          default:
            return true;
        }
      }).toList();
    }

    return list;
  }

  Widget _buildProductsHeaderContent() {
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
                // Products icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Productos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Encuentra todo lo que necesitas para tu trabajo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _buildProductStatChip('${_allProducts.length}', 'Productos'),
                    const SizedBox(width: 12),
                    _buildProductStatChip('${_categories.length - 1}', 'Categorías'),
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

  @override
  Widget build(BuildContext context) {
    final filtered = this.filtered;

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
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  tooltip: 'Publicar producto',
                  onPressed: _showCreateProductDialog,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductsHeaderContent(),
            ),
          ),
        ],
        body: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: EdgeInsets.only(
                              right: index == _categories.length - 1 ? 0 : 12),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                            backgroundColor: AppColors.surface,
                            selectedColor: AppColors.primaryContainer,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoadingRemote)
                    const LinearProgressIndicator(minHeight: 3),
                  if (_remoteError != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'Error al cargar productos remotos',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  Text(
                    '${filtered.length} productos encontrados',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = filtered[index];
                  final color = _productColors[index % _productColors.length];
                  return _ProductCard(
                    product: product,
                    color: color,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.productDetail,
                      arguments: product,
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _showCreateProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Publicar Nuevo Producto'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  hintText: 'ej: Casco de seguridad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu producto en detalle...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio (USD)',
                  hintText: '50',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  _createNewProduct(
                    nameController.text,
                    descriptionController.text,
                    double.parse(priceController.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Publicar Producto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewProduct(String name, String description, double price) {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;

    final newProduct = Product(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorDisplayName: currentUser.accountDisplayName,
      authorAccountType: currentUser.accountType.name,
      authorAvatarUrl: currentUser.avatarUrl,
      authorRating: currentUser.ratingAvg,
      authorReviewCount: currentUser.ratingCount,
    );

    setState(() {
      _allProducts.add(newProduct);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Producto "${name}" publicado exitosamente!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color color;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con precio e icono
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getProductIcon(product.name),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Título del producto
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Descripción
                Expanded(
                  child: Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Información del autor
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.8),
                            AppColors.secondary.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: product.authorAvatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              product.authorAvatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              product.authorIcon,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                product.authorIcon,
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  product.authorDisplayName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.isAuthorVerified) ...[
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                              ],
                            ],
                          ),
                          if (product.authorRating > 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.star, size: 10, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.authorRating.toStringAsFixed(1)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Footer con estado y tiempo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.inStock ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.inStock ? 'Disponible' : 'Agotado',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: product.inStock ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    Text(
                      product.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('casco')) return Icons.construction;
    if (name.contains('linterna')) return Icons.flashlight_on;
    if (name.contains('guantes')) return Icons.back_hand;
    if (name.contains('botas')) return Icons.work;
    if (name.contains('chaleco')) return Icons.warning;
    if (name.contains('detector')) return Icons.sensors;
    if (name.contains('cuerda')) return Icons.link;
    if (name.contains('martillo')) return Icons.build;
    return Icons.inventory;
  }
}