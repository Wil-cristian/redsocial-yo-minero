import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

/// Página de carrito/favoritos
class CartFavoritesPage extends StatefulWidget {
  const CartFavoritesPage({super.key});

  @override
  State<CartFavoritesPage> createState() => _CartFavoritesPageState();
}

class _CartFavoritesPageState extends State<CartFavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> cartItems = [
    {
      'id': 1,
      'name': 'Servicio de perforación',
      'provider': 'Carlos Minería',
      'price': 500000,
      'quantity': 1,
    },
    {
      'id': 2,
      'name': 'Equipo de excavación',
      'provider': 'Empresa Minera Central',
      'price': 1500000,
      'quantity': 1,
    },
  ];

  final List<Map<String, dynamic>> favoriteItems = [
    {
      'id': 1,
      'name': 'Mineral procesado',
      'provider': 'Minería del Sur',
      'price': 300000,
    },
    {
      'id': 2,
      'name': 'Equipo de seguridad',
      'provider': 'Seguridad Total',
      'price': 150000,
    },
    {
      'id': 3,
      'name': 'Explosivos controlados',
      'provider': 'Química Minera',
      'price': 800000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.pureWhite,
        elevation: 0,
        title: Text(
          'Carrito y Favoritos',
          style: TextStyle(
            color: AppColorsUnified.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColorsUnified.charcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColorsUnified.orange,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          indicatorColor: AppColorsUnified.orange,
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_bag),
              text: 'Carrito',
            ),
            Tab(
              icon: Icon(Icons.favorite),
              text: 'Favoritos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCartTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    if (cartItems.isEmpty) {
      return _buildEmptyState(
        'Carrito vacío',
        'No tienes productos en tu carrito',
        Icons.shopping_cart_outlined,
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(cartItems[index], index);
            },
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColorsUnified.background, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(fontSize: 14, color: AppColorsUnified.textSecondary),
                    ),
                    Text(
                      '\$${_calculateSubtotal().toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Envío:',
                      style: TextStyle(fontSize: 14, color: AppColorsUnified.textSecondary),
                    ),
                    Text(
                      '\$${(50000).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${(_calculateSubtotal() + 50000).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.companyBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Proceder al pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.pureWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColorsUnified.background, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColorsUnified.fade(AppColorsUnified.orange, 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: AppColorsUnified.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['provider'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item['price'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.companyBlue,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColorsUnified.background,
                    foregroundColor: AppColorsUnified.charcoal,
                  ),
                  child: const Text('-', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['quantity'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 30,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColorsUnified.orange,
                    foregroundColor: AppColorsUnified.pureWhite,
                  ),
                  child: const Text('+', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (favoriteItems.isEmpty) {
      return _buildEmptyState(
        'Sin favoritos',
        'Guarda tus productos favoritos aquí',
        Icons.favorite_outline,
      );
    }

    return ListView.builder(
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        return _buildFavoriteItem(favoriteItems[index], index);
      },
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> item, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColorsUnified.background, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColorsUnified.fade(AppColorsUnified.error, 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: AppColorsUnified.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['provider'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item['price'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.companyBlue,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart, size: 16),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsUnified.orange,
                  foregroundColor: AppColorsUnified.pureWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    favoriteItems.removeAt(index);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String description, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }
}
