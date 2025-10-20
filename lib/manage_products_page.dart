import 'package:flutter/material.dart';
import 'package:yominero/shared/models/product.dart';
import 'core/theme/colors.dart';
import 'core/auth/auth_service.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  // Mock user products - In a real app, this would come from a database
  List<Product> _userProducts = [];

  @override
  void initState() {
    super.initState();
    _loadUserProducts();
  }

  void _loadUserProducts() {
    // Mock data - replace with actual data loading
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;
    
    _userProducts = [
      Product(
        id: '1',
        name: 'Taladro Industrial XL',
        description: 'Taladro de alta resistencia para minería',
        price: 2500.0,
        inStock: true,
        authorId: currentUser.id,
        authorName: currentUser.name,
        authorDisplayName: currentUser.accountDisplayName,
        authorAccountType: currentUser.accountType.name,
        authorAvatarUrl: currentUser.avatarUrl,
        authorRating: currentUser.ratingAvg,
        authorReviewCount: currentUser.ratingCount,
      ),
      Product(
        id: '2',
        name: 'Casco de Seguridad',
        description: 'Casco certificado para trabajos de minería',
        price: 75.0,
        inStock: true,
        authorId: currentUser.id,
        authorName: currentUser.name,
        authorDisplayName: currentUser.accountDisplayName,
        authorAccountType: currentUser.accountType.name,
        authorAvatarUrl: currentUser.avatarUrl,
        authorRating: currentUser.ratingAvg,
        authorReviewCount: currentUser.ratingCount,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withValues(alpha: 0.05),
              AppColors.primary.withValues(alpha: 0.03),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Beautiful App Bar with gradient
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
                  tooltip: 'Volver al perfil',
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18, color: AppColors.secondary),
                    label: const Text('Salir', style: TextStyle(color: AppColors.secondary)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 8),
                      const Text(
                        'Mis Productos',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Beautiful header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.secondary, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.store, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tu catálogo de productos mineros',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestiona, vende y promociona productos especializados para la industria',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Add new product button - Enhanced
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.secondary.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showAddProductDialog(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondary.withValues(alpha: 0.2),
                                        AppColors.primary.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.add_shopping_cart,
                                    size: 48,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Agregar Nuevo Producto',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Expande tu catálogo con productos de calidad',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Products list
                    if (_userProducts.isEmpty)
                      _buildBeautifulEmptyState()
                    else
                      Column(
                        children: _userProducts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOutBack,
                            child: _buildBeautifulProductCard(product, index),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifulEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.secondary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.secondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu inventario está esperando',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Comienza agregando productos especializados para la industria minera y conecta con compradores de toda la región',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Empieza a vender',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulProductCard(Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.secondary.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditProductDialog(product),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Enhanced product image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Icon(Icons.inventory_2, color: AppColors.secondary, size: 40),
                          ),
                        )
                      : Icon(Icons.inventory_2, color: AppColors.secondary, size: 40),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Enhanced product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.success.withValues(alpha: 0.2),
                                    AppColors.success.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.attach_money, color: Colors.white, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${product.price.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: product.inStock 
                                    ? [
                                        AppColors.success.withValues(alpha: 0.2),
                                        AppColors.success.withValues(alpha: 0.1),
                                      ]
                                    : [
                                        AppColors.error.withValues(alpha: 0.2),
                                        AppColors.error.withValues(alpha: 0.1),
                                      ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: product.inStock 
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : AppColors.error.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: product.inStock ? AppColors.success : AppColors.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.inStock ? 'En Stock' : 'Agotado',
                                    style: TextStyle(
                                      color: product.inStock ? AppColors.success : AppColors.error,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    _showProductDialog();
  }

  void _showEditProductDialog(Product product) {
    _showProductDialog(existingProduct: product);
  }

  void _showProductDialog({Product? existingProduct}) {
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final descriptionController = TextEditingController(text: existingProduct?.description ?? '');
    final priceController = TextEditingController(
      text: existingProduct?.price.toString() ?? ''
    );
    final imageUrlController = TextEditingController(text: existingProduct?.imageUrl ?? '');
    bool inStock = existingProduct?.inStock ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingProduct == null ? 'Nuevo Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto *',
                    hintText: 'ej: Taladro Industrial XL',
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Describe tu producto...',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    hintText: '0.00',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL de imagen (opcional)',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text('En stock:'),
                    const Spacer(),
                    Switch(
                      value: inStock,
                      onChanged: (value) {
                        setDialogState(() {
                          inStock = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (existingProduct != null)
              TextButton(
                onPressed: () => _deleteProduct(existingProduct),
                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _saveProduct(
                nameController.text,
                descriptionController.text,
                priceController.text,
                imageUrlController.text,
                inStock,
                existingProduct,
              ),
              child: Text(existingProduct == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProduct(
    String name,
    String description,
    String priceText,
    String imageUrl,
    bool inStock,
    Product? existingProduct,
  ) {
    if (name.trim().isEmpty || description.trim().isEmpty || priceText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre, descripción y precio son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un precio válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;

    final newProduct = Product(
      id: existingProduct?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      description: description.trim(),
      price: price,
      imageUrl: imageUrl.trim().isNotEmpty ? imageUrl.trim() : null,
      inStock: inStock,
      authorId: currentUser.id,
      authorName: currentUser.name,
      authorDisplayName: currentUser.accountDisplayName,
      authorAccountType: currentUser.accountType.name,
      authorAvatarUrl: currentUser.avatarUrl,
      authorRating: currentUser.ratingAvg,
      authorReviewCount: currentUser.ratingCount,
    );

    setState(() {
      if (existingProduct != null) {
        // Replace existing product
        final index = _userProducts.indexWhere((p) => p.id == existingProduct.id);
        if (index != -1) {
          _userProducts[index] = newProduct;
        }
      } else {
        // Add new product
        _userProducts.add(newProduct);
      }
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existingProduct == null 
          ? 'Producto creado exitosamente' 
          : 'Producto actualizado exitosamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userProducts.removeWhere((p) => p.id == product.id);
              });
              Navigator.of(context).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close edit dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado exitosamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}