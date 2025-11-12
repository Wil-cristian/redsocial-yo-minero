import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';
import 'core/di/locator.dart';
import 'features/products/domain/product_repository.dart';
import 'core/theme/colors.dart';
import 'core/routing/app_router.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/theme/premium_product_card.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

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
            AppColorsUnified.orange,
            AppColorsUnified.orange.withValues(alpha: 0.8),
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
                color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.1),
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
                color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.05),
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
                    color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3)),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: AppColorsUnified.pureWhite,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Productos',
                  style: TextStyle(
                    color: AppColorsUnified.pureWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Encuentra todo lo que necesitas para tu trabajo',
                  style: TextStyle(
                    color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.9),
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
        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColorsUnified.pureWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.8),
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
      backgroundColor: AppColorsUnified.background,
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
                color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3)),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColorsUnified.pureWhite),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3)),
                ),
                child: IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppColorsUnified.pureWhite, size: 24),
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
                      color: AppColorsUnified.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorsUnified.textPrimary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: Icon(Icons.search, color: AppColorsUnified.textSecondary),
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
                            selectedColor: AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
                            checkmarkColor: AppColorsUnified.orange,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColorsUnified.orange
                                  : AppColorsUnified.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColorsUnified.orange
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
                        color: AppColorsUnified.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColorsUnified.error.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'Error al cargar productos remotos',
                        style: TextStyle(color: AppColorsUnified.error),
                      ),
                    ),
                  Text(
                    '${filtered.length} productos encontrados',
                    style: const TextStyle(
                      color: AppColorsUnified.textSecondary,
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
                  return PremiumProductCard(
                    product: product,
                    index: index,
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
                  colors: [AppColors.secondary, AppColorsUnified.orange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory, color: AppColorsUnified.pureWhite, size: 20),
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
                colors: [AppColors.secondary, AppColorsUnified.orange],
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
              child: Text(
                'Publicar Producto',
                style: TextStyle(color: AppColorsUnified.pureWhite, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewProduct(String name, String description, double price) {
    final profile = SupabaseAuthService.instance.currentUserProfile;
    if (profile == null) return;

    final newProduct = Product(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      authorId: profile['id'],
      authorName: profile['name'] ?? '',
      authorDisplayName: profile['name'] ?? '',
      authorAccountType: profile['account_type'] ?? 'individual',
      authorAvatarUrl: profile['profile_image_url'],
      authorRating: (profile['rating_avg'] ?? 0.0).toDouble(),
      authorReviewCount: profile['rating_count'] ?? 0,
    );

    setState(() {
      _allProducts.add(newProduct);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColorsUnified.pureWhite),
            const SizedBox(width: 8),
            Text('Producto "$name" publicado exitosamente!'),
          ],
        ),
        backgroundColor: AppColorsUnified.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}