import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors_unified.dart';

class AccountingInventoryPage extends StatefulWidget {
  final String odooMineId;

  const AccountingInventoryPage({
    super.key,
    required this.odooMineId,
  });

  @override
  State<AccountingInventoryPage> createState() => _AccountingInventoryPageState();
}

class _AccountingInventoryPageState extends State<AccountingInventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  bool _isLoading = true;
  List<InventoryItem> _items = [];
  InventorySummary? _summary;
  String _filterCategory = 'all';
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    _items = _generateSampleItems();
    _calculateSummary();
    
    setState(() => _isLoading = false);
  }

  void _calculateSummary() {
    double totalValue = 0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (var item in _items) {
      totalValue += item.totalValue;
      if (item.quantity == 0) {
        outOfStockCount++;
      } else if (item.quantity <= item.minStock) {
        lowStockCount++;
      }
    }

    _summary = InventorySummary(
      totalItems: _items.length,
      totalValue: totalValue,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
    );
  }

  List<InventoryItem> _generateSampleItems() {
    return [
      // Explosivos
      InventoryItem(
        id: '1',
        name: 'Dinamita Industrial',
        sku: 'EXP-001',
        category: 'Explosivos',
        quantity: 450,
        unit: 'kg',
        unitCost: 185.00,
        minStock: 200,
        maxStock: 1000,
        location: 'Almacén A - Zona Explosivos',
        supplier: 'Explosivos Industriales S.A.',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      InventoryItem(
        id: '2',
        name: 'Fulminantes Eléctricos',
        sku: 'EXP-002',
        category: 'Explosivos',
        quantity: 1200,
        unit: 'piezas',
        unitCost: 45.00,
        minStock: 500,
        maxStock: 3000,
        location: 'Almacén A - Zona Explosivos',
        supplier: 'Explosivos Industriales S.A.',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      InventoryItem(
        id: '3',
        name: 'Mecha de Seguridad',
        sku: 'EXP-003',
        category: 'Explosivos',
        quantity: 180,
        unit: 'metros',
        unitCost: 25.00,
        minStock: 200,
        maxStock: 800,
        location: 'Almacén A - Zona Explosivos',
        supplier: 'Explosivos Industriales S.A.',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      // Combustibles
      InventoryItem(
        id: '4',
        name: 'Diesel Industrial',
        sku: 'COMB-001',
        category: 'Combustibles',
        quantity: 8500,
        unit: 'litros',
        unitCost: 24.50,
        minStock: 5000,
        maxStock: 20000,
        location: 'Tanque Principal',
        supplier: 'Combustibles del Bajío',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      InventoryItem(
        id: '5',
        name: 'Gasolina Premium',
        sku: 'COMB-002',
        category: 'Combustibles',
        quantity: 1200,
        unit: 'litros',
        unitCost: 25.80,
        minStock: 1000,
        maxStock: 5000,
        location: 'Tanque Secundario',
        supplier: 'Combustibles del Bajío',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      // Refacciones
      InventoryItem(
        id: '6',
        name: 'Filtro de Aire - CAT 320',
        sku: 'REF-001',
        category: 'Refacciones',
        quantity: 8,
        unit: 'piezas',
        unitCost: 2850.00,
        minStock: 5,
        maxStock: 20,
        location: 'Almacén B - Refacciones',
        supplier: 'Maquinaria Pesada México',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 45)),
      ),
      InventoryItem(
        id: '7',
        name: 'Aceite Motor 15W40',
        sku: 'REF-002',
        category: 'Refacciones',
        quantity: 120,
        unit: 'litros',
        unitCost: 185.00,
        minStock: 100,
        maxStock: 500,
        location: 'Almacén B - Lubricantes',
        supplier: 'Lubricantes Industriales',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
      InventoryItem(
        id: '8',
        name: 'Banda Transportadora',
        sku: 'REF-003',
        category: 'Refacciones',
        quantity: 0,
        unit: 'metros',
        unitCost: 1250.00,
        minStock: 50,
        maxStock: 200,
        location: 'Almacén B - Refacciones',
        supplier: 'Bandas y Correas S.A.',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
      // EPP
      InventoryItem(
        id: '9',
        name: 'Casco de Seguridad',
        sku: 'EPP-001',
        category: 'Seguridad',
        quantity: 45,
        unit: 'piezas',
        unitCost: 450.00,
        minStock: 30,
        maxStock: 100,
        location: 'Almacén C - EPP',
        supplier: 'Equipos de Seguridad Industrial',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 35)),
      ),
      InventoryItem(
        id: '10',
        name: 'Guantes de Carnaza',
        sku: 'EPP-002',
        category: 'Seguridad',
        quantity: 150,
        unit: 'pares',
        unitCost: 85.00,
        minStock: 100,
        maxStock: 500,
        location: 'Almacén C - EPP',
        supplier: 'Equipos de Seguridad Industrial',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      InventoryItem(
        id: '11',
        name: 'Botas de Seguridad',
        sku: 'EPP-003',
        category: 'Seguridad',
        quantity: 25,
        unit: 'pares',
        unitCost: 1200.00,
        minStock: 30,
        maxStock: 80,
        location: 'Almacén C - EPP',
        supplier: 'Equipos de Seguridad Industrial',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 40)),
      ),
      // Herramientas
      InventoryItem(
        id: '12',
        name: 'Pico Minero',
        sku: 'HER-001',
        category: 'Herramientas',
        quantity: 35,
        unit: 'piezas',
        unitCost: 380.00,
        minStock: 20,
        maxStock: 60,
        location: 'Almacén D - Herramientas',
        supplier: 'Ferretería Industrial',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 50)),
      ),
      InventoryItem(
        id: '13',
        name: 'Pala Cuadrada',
        sku: 'HER-002',
        category: 'Herramientas',
        quantity: 28,
        unit: 'piezas',
        unitCost: 320.00,
        minStock: 15,
        maxStock: 50,
        location: 'Almacén D - Herramientas',
        supplier: 'Ferretería Industrial',
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 55)),
      ),
    ];
  }

  List<InventoryItem> get _filteredItems {
    var filtered = _items.where((item) {
      if (_filterCategory == 'all') return true;
      if (_filterCategory == 'lowStock') return item.quantity <= item.minStock && item.quantity > 0;
      if (_filterCategory == 'outOfStock') return item.quantity == 0;
      return item.category == _filterCategory;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'value':
          return b.totalValue.compareTo(a.totalValue);
        case 'quantity':
          return a.quantity.compareTo(b.quantity);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.backgroundMedium,
        title: const Text(
          'Inventario Contable',
          style: TextStyle(color: AppColorsUnified.goldPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColorsUnified.goldPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColorsUnified.goldPrimary,
          labelColor: AppColorsUnified.goldPrimary,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.inventory), text: 'Artículos'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'Movimientos'),
            Tab(icon: Icon(Icons.analytics), text: 'Valoración'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColorsUnified.goldPrimary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildItemsTab(),
                _buildMovementsTab(),
                _buildValuationTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppColorsUnified.goldPrimary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_summary == null) return const Center(child: Text('No hay datos'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Valor total del inventario
          _buildTotalValueCard(),
          const SizedBox(height: 16),
          
          // Alertas
          if (_summary!.lowStockCount > 0 || _summary!.outOfStockCount > 0)
            _buildAlertsSection(),
          const SizedBox(height: 16),
          
          // Tarjetas de resumen
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Total Artículos', '${_summary!.totalItems}', Icons.inventory_2, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Stock Bajo', '${_summary!.lowStockCount}', Icons.warning, Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Sin Stock', '${_summary!.outOfStockCount}', Icons.remove_shopping_cart, Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Categorías', '${_items.map((e) => e.category).toSet().length}', Icons.category, Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Distribución por categoría
          _buildCategoryDistribution(),
          const SizedBox(height: 16),
          
          // Top artículos por valor
          _buildTopItemsByValue(),
        ],
      ),
    );
  }

  Widget _buildTotalValueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.goldPrimary.withValues(alpha: 0.3),
            AppColorsUnified.backgroundMedium,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.goldPrimary.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, color: AppColorsUnified.goldPrimary),
              SizedBox(width: 8),
              Text(
                'Valor Total del Inventario',
                style: TextStyle(color: AppColorsUnified.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(_summary!.totalValue),
            style: const TextStyle(
              color: AppColorsUnified.goldPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actualizado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notification_important, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Alertas de Inventario',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_summary!.outOfStockCount > 0)
            _buildAlertItem(
              '${_summary!.outOfStockCount} artículos sin stock',
              Colors.red,
              Icons.remove_shopping_cart,
            ),
          if (_summary!.lowStockCount > 0)
            _buildAlertItem(
              '${_summary!.lowStockCount} artículos con stock bajo',
              Colors.orange,
              Icons.warning,
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _filterCategory = icon == Icons.remove_shopping_cart ? 'outOfStock' : 'lowStock';
              });
              _tabController.animateTo(1);
            },
            child: const Text('Ver', style: TextStyle(color: AppColorsUnified.goldPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColorsUnified.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    final categoryValues = <String, double>{};
    for (var item in _items) {
      categoryValues[item.category] = (categoryValues[item.category] ?? 0) + item.totalValue;
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valor por Categoría',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: categoryValues.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final cat = entry.value;
                  final total = categoryValues.values.reduce((a, b) => a + b);
                  final percentage = (cat.value / total) * 100;

                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: cat.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryValues.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${cat.key}: ${_currencyFormat.format(cat.value)}',
                    style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsByValue() {
    final sorted = List<InventoryItem>.from(_items)..sort((a, b) => b.totalValue.compareTo(a.totalValue));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Artículos por Valor',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((item) {
            final maxValue = sorted.first.totalValue;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(color: AppColorsUnified.textPrimary, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(item.totalValue),
                        style: const TextStyle(
                          color: AppColorsUnified.goldPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: item.totalValue / maxValue,
                    backgroundColor: AppColorsUnified.backgroundDark,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColorsUnified.goldPrimary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsTab() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 64, color: AppColorsUnified.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No hay artículos',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            ),
            TextButton(
              onPressed: () => setState(() => _filterCategory = 'all'),
              child: const Text('Mostrar todos'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    Color stockColor;
    String stockStatus;
    
    if (item.quantity == 0) {
      stockColor = Colors.red;
      stockStatus = 'Sin Stock';
    } else if (item.quantity <= item.minStock) {
      stockColor = Colors.orange;
      stockStatus = 'Stock Bajo';
    } else {
      stockColor = Colors.green;
      stockStatus = 'En Stock';
    }

    return Card(
      color: AppColorsUnified.backgroundMedium,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.quantity == 0 ? Colors.red.withValues(alpha: 0.5) : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.goldPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColorsUnified.goldPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AppColorsUnified.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'SKU: ${item.sku}',
                          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stockStatus,
                      style: TextStyle(
                        color: stockColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildItemInfo('Categoría', item.category),
                  _buildItemInfo('Cantidad', '${item.quantity} ${item.unit}'),
                  _buildItemInfo('Valor', _currencyFormat.format(item.totalValue)),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: ${item.quantity}/${item.maxStock}',
                        style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
                      ),
                      Text(
                        'Mín: ${item.minStock}',
                        style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: item.maxStock > 0 ? item.quantity / item.maxStock : 0,
                    backgroundColor: AppColorsUnified.backgroundDark,
                    valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColorsUnified.textPrimary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMovementsTab() {
    // Movimientos de inventario simulados
    final movements = [
      InventoryMovement(
        id: '1',
        itemName: 'Diesel Industrial',
        type: MovementType.entrada,
        quantity: 5000,
        unit: 'litros',
        date: DateTime.now().subtract(const Duration(days: 1)),
        reference: 'OC-2024-089',
        user: 'Juan Pérez',
      ),
      InventoryMovement(
        id: '2',
        itemName: 'Dinamita Industrial',
        type: MovementType.salida,
        quantity: 50,
        unit: 'kg',
        date: DateTime.now().subtract(const Duration(days: 2)),
        reference: 'REQ-2024-156',
        user: 'María García',
      ),
      InventoryMovement(
        id: '3',
        itemName: 'Filtro de Aire - CAT 320',
        type: MovementType.salida,
        quantity: 2,
        unit: 'piezas',
        date: DateTime.now().subtract(const Duration(days: 3)),
        reference: 'OT-2024-445',
        user: 'Roberto Hernández',
      ),
      InventoryMovement(
        id: '4',
        itemName: 'Casco de Seguridad',
        type: MovementType.entrada,
        quantity: 20,
        unit: 'piezas',
        date: DateTime.now().subtract(const Duration(days: 4)),
        reference: 'OC-2024-085',
        user: 'Ana Martínez',
      ),
      InventoryMovement(
        id: '5',
        itemName: 'Fulminantes Eléctricos',
        type: MovementType.salida,
        quantity: 200,
        unit: 'piezas',
        date: DateTime.now().subtract(const Duration(days: 5)),
        reference: 'REQ-2024-148',
        user: 'Pedro Sánchez',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final mov = movements[index];
        return _buildMovementCard(mov);
      },
    );
  }

  Widget _buildMovementCard(InventoryMovement mov) {
    final isEntrada = mov.type == MovementType.entrada;

    return Card(
      color: AppColorsUnified.backgroundMedium,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isEntrada ? Colors.green : Colors.red).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isEntrada ? Icons.arrow_downward : Icons.arrow_upward,
            color: isEntrada ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          mov.itemName,
          style: const TextStyle(color: AppColorsUnified.textPrimary, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${mov.quantity} ${mov.unit} • ${mov.reference}',
          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('dd/MM').format(mov.date),
              style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
            ),
            Text(
              isEntrada ? 'Entrada' : 'Salida',
              style: TextStyle(
                color: isEntrada ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Método de valoración
          _buildValuationMethodCard(),
          const SizedBox(height: 16),
          
          // Resumen de valoración
          _buildValuationSummary(),
          const SizedBox(height: 16),
          
          // Tabla de valoración por categoría
          _buildValuationTable(),
        ],
      ),
    );
  }

  Widget _buildValuationMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate, color: AppColorsUnified.goldPrimary),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Método de Valoración',
                  style: TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                ),
                Text(
                  'Costo Promedio Ponderado',
                  style: TextStyle(
                    color: AppColorsUnified.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Cambiar método
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsUnified.goldPrimary,
              side: const BorderSide(color: AppColorsUnified.goldPrimary),
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  Widget _buildValuationSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Valoración',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildValuationRow('Costo de Adquisición', _summary!.totalValue),
          _buildValuationRow('Valor de Mercado (est.)', _summary!.totalValue * 1.15),
          _buildValuationRow('Depreciación Acumulada', _summary!.totalValue * 0.05),
          const Divider(color: AppColorsUnified.textSecondary),
          _buildValuationRow('Valor Neto en Libros', _summary!.totalValue * 0.95, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildValuationRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColorsUnified.textPrimary : AppColorsUnified.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _currencyFormat.format(value),
            style: TextStyle(
              color: isTotal ? AppColorsUnified.goldPrimary : AppColorsUnified.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuationTable() {
    final categoryValues = <String, Map<String, double>>{};
    for (var item in _items) {
      categoryValues.putIfAbsent(item.category, () => {'items': 0, 'value': 0});
      categoryValues[item.category]!['items'] = (categoryValues[item.category]!['items'] ?? 0) + 1;
      categoryValues[item.category]!['value'] = (categoryValues[item.category]!['value'] ?? 0) + item.totalValue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valoración por Categoría',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            children: [
              const TableRow(
                children: [
                  Text('Categoría', style: TextStyle(color: AppColorsUnified.goldPrimary, fontWeight: FontWeight.bold)),
                  Text('Items', style: TextStyle(color: AppColorsUnified.goldPrimary, fontWeight: FontWeight.bold)),
                  Text('Valor', style: TextStyle(color: AppColorsUnified.goldPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                ],
              ),
              ...categoryValues.entries.map((entry) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(entry.key, style: const TextStyle(color: AppColorsUnified.textPrimary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('${entry.value['items']!.toInt()}', style: const TextStyle(color: AppColorsUnified.textSecondary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _currencyFormat.format(entry.value['value']),
                          style: const TextStyle(color: AppColorsUnified.textPrimary),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final categories = ['all', 'lowStock', 'outOfStock', ..._items.map((e) => e.category).toSet()];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por',
              style: TextStyle(
                color: AppColorsUnified.goldPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                String label;
                if (cat == 'all') {
                  label = 'Todos';
                } else if (cat == 'lowStock') {
                  label = 'Stock Bajo';
                } else if (cat == 'outOfStock') {
                  label = 'Sin Stock';
                } else {
                  label = cat;
                }
                
                final isSelected = _filterCategory == cat;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _filterCategory = cat);
                    Navigator.pop(context);
                  },
                  selectedColor: AppColorsUnified.goldPrimary.withValues(alpha: 0.3),
                  checkmarkColor: AppColorsUnified.goldPrimary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColorsUnified.goldPrimary : AppColorsUnified.textSecondary,
                  ),
                  backgroundColor: AppColorsUnified.backgroundDark,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ordenar por',
              style: TextStyle(
                color: AppColorsUnified.goldPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildSortChip('name', 'Nombre'),
                _buildSortChip('value', 'Valor'),
                _buildSortChip('quantity', 'Cantidad'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
      selectedColor: AppColorsUnified.goldPrimary.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? AppColorsUnified.goldPrimary : AppColorsUnified.textSecondary,
      ),
      backgroundColor: AppColorsUnified.backgroundDark,
    );
  }

  void _showItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundMedium,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorsUnified.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.name,
                style: const TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'SKU: ${item.sku}',
                style: const TextStyle(color: AppColorsUnified.goldPrimary),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Categoría', item.category),
              _buildDetailRow('Ubicación', item.location),
              _buildDetailRow('Proveedor', item.supplier),
              _buildDetailRow('Última compra', DateFormat('dd/MM/yyyy').format(item.lastPurchaseDate)),
              const Divider(height: 32, color: AppColorsUnified.textSecondary),
              const Text(
                'Stock',
                style: TextStyle(color: AppColorsUnified.goldPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Cantidad actual', '${item.quantity} ${item.unit}'),
              _buildDetailRow('Stock mínimo', '${item.minStock} ${item.unit}'),
              _buildDetailRow('Stock máximo', '${item.maxStock} ${item.unit}'),
              const Divider(height: 32, color: AppColorsUnified.textSecondary),
              const Text(
                'Valoración',
                style: TextStyle(color: AppColorsUnified.goldPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Costo unitario', _currencyFormat.format(item.unitCost)),
              _buildDetailRow('Valor total', _currencyFormat.format(item.totalValue)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAdjustStockDialog(item),
                      icon: const Icon(Icons.edit),
                      label: const Text('Ajustar Stock'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColorsUnified.goldPrimary,
                        side: const BorderSide(color: AppColorsUnified.goldPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Crear orden de compra
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Ordenar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsUnified.goldPrimary,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColorsUnified.textSecondary)),
          Text(value, style: const TextStyle(color: AppColorsUnified.textPrimary)),
        ],
      ),
    );
  }

  void _showAdjustStockDialog(InventoryItem item) {
    final controller = TextEditingController();
    String adjustType = 'add';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColorsUnified.backgroundMedium,
          title: const Text(
            'Ajustar Stock',
            style: TextStyle(color: AppColorsUnified.goldPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.name}\nStock actual: ${item.quantity} ${item.unit}',
                style: const TextStyle(color: AppColorsUnified.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Agregar', style: TextStyle(color: AppColorsUnified.textPrimary)),
                      value: 'add',
                      groupValue: adjustType,
                      activeColor: Colors.green,
                      onChanged: (v) => setDialogState(() => adjustType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Restar', style: TextStyle(color: AppColorsUnified.textPrimary)),
                      value: 'subtract',
                      groupValue: adjustType,
                      activeColor: Colors.red,
                      onChanged: (v) => setDialogState(() => adjustType = v!),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColorsUnified.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                  suffixText: item.unit,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorsUnified.goldPrimary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColorsUnified.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock ajustado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadData();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColorsUnified.goldPrimary),
              child: const Text('Guardar', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _scanBarcode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escáner disponible próximamente'),
        backgroundColor: AppColorsUnified.goldPrimary,
      ),
    );
  }

  void _showAddItemDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función disponible próximamente'),
        backgroundColor: AppColorsUnified.goldPrimary,
      ),
    );
  }
}

// Modelos
class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double quantity;
  final String unit;
  final double unitCost;
  final double minStock;
  final double maxStock;
  final String location;
  final String supplier;
  final DateTime lastPurchaseDate;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.minStock,
    required this.maxStock,
    required this.location,
    required this.supplier,
    required this.lastPurchaseDate,
  });

  double get totalValue => quantity * unitCost;
}

class InventorySummary {
  final int totalItems;
  final double totalValue;
  final int lowStockCount;
  final int outOfStockCount;

  InventorySummary({
    required this.totalItems,
    required this.totalValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });
}

enum MovementType { entrada, salida }

class InventoryMovement {
  final String id;
  final String itemName;
  final MovementType type;
  final double quantity;
  final String unit;
  final DateTime date;
  final String reference;
  final String user;

  InventoryMovement({
    required this.id,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.reference,
    required this.user,
  });
}
