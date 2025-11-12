import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class CompanyRequestedProductsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CompanyRequestedProductsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CompanyRequestedProductsPage> createState() =>
      _CompanyRequestedProductsPageState();
}

class _CompanyRequestedProductsPageState
    extends State<CompanyRequestedProductsPage> {
  late List<Map<String, dynamic>> _products;
  String _selectedStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _products = [
      {
        'id': '1',
        'name': 'Casco de Seguridad Industrial',
        'supplier': 'SafeGear S.A.S',
        'status': 'Entregado',
        'quantity': 50,
        'unitPrice': 25000,
        'totalPrice': 1250000,
        'orderDate': '2024-09-15',
        'deliveryDate': '2024-10-10',
      },
      {
        'id': '2',
        'name': 'Guantes de Nitrilo Premium',
        'supplier': 'Protección Total',
        'status': 'En Camino',
        'quantity': 100,
        'unitPrice': 2500,
        'totalPrice': 250000,
        'orderDate': '2024-10-05',
        'deliveryDate': '2024-10-25',
      },
      {
        'id': '3',
        'name': 'Chaleco Reflectivo',
        'supplier': 'Safety First',
        'status': 'Pendiente',
        'quantity': 75,
        'unitPrice': 18000,
        'totalPrice': 1350000,
        'orderDate': '2024-10-18',
        'deliveryDate': '2024-11-05',
      },
      {
        'id': '4',
        'name': 'Botas de Seguridad Steel Toe',
        'supplier': 'WorkSafe',
        'status': 'Entregado',
        'quantity': 30,
        'unitPrice': 85000,
        'totalPrice': 2550000,
        'orderDate': '2024-08-20',
        'deliveryDate': '2024-09-15',
      },
      {
        'id': '5',
        'name': 'Casco Minero LED',
        'supplier': 'TechMining',
        'status': 'En Procesamiento',
        'quantity': 20,
        'unitPrice': 45000,
        'totalPrice': 900000,
        'orderDate': '2024-10-15',
        'deliveryDate': '2024-11-10',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedStatus == 'Todos') {
      return _products;
    }
    return _products
        .where((product) => product['status'] == _selectedStatus)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Entregado':
        return AppColorsUnified.success;
      case 'En Camino':
        return AppColorsUnified.companyBlue;
      case 'En Procesamiento':
        return AppColorsUnified.companyBlueDark;
      case 'Pendiente':
        return AppColorsUnified.orange;
      case 'Cancelado':
        return AppColorsUnified.error;
      default:
        return AppColorsUnified.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text('Productos Pedidos'),
        backgroundColor: AppColorsUnified.companySecondary,
        foregroundColor: AppColorsUnified.pureWhite,
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showOrderProductDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Filter Chips
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: [
                  'Todos',
                  'Pendiente',
                  'En Procesamiento',
                  'En Camino',
                  'Entregado',
                ]
                    .map((status) {
                  final isSelected = _selectedStatus == status;
                  return FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    backgroundColor: AppColorsUnified.pureWhite,
                    selectedColor: AppColorsUnified.companySecondary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColorsUnified.pureWhite : AppColorsUnified.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Products Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredProducts.length} productos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColorsUnified.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Products List
            if (_filteredProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 48,
                      color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No se encontraron productos',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return _buildProductCard(product);
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final statusColor = _getStatusColor(product['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showProductDetail(product),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['supplier'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColorsUnified.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        product['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Quantity and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cantidad',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          '${product['quantity']} unidades',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Precio Unitario',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${product['unitPrice']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${product['totalPrice']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pedido',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          product['orderDate'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Entrega',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          product['deliveryDate'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
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

  void _showProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Proveedor: ${product['supplier']}'),
            Text('Estado: ${product['status']}'),
            Text('Cantidad: ${product['quantity']} unidades'),
            Text('Precio Unitario: \$${product['unitPrice']}'),
            Text('Total: \$${product['totalPrice']}'),
            Text('Fecha Pedido: ${product['orderDate']}'),
            Text('Fecha Entrega: ${product['deliveryDate']}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.track_changes),
                    label: const Text('Rastrear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.companySecondary,
                      foregroundColor: AppColorsUnified.pureWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Contactar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.textSecondary,
                      foregroundColor: AppColorsUnified.pureWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar Nuevo Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Producto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Proveedor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Precio Unitario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pedido realizado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsUnified.companySecondary,
            ),
            child: const Text('Ordenar'),
          ),
        ],
      ),
    );
  }
}
