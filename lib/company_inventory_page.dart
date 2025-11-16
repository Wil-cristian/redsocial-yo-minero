import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_colors_unified.dart';
import 'shared/models/inventory_item.dart';
import 'company_inventory_reports_page.dart';
import 'company_add_inventory_item_page.dart';
import 'company_inventory_movements_page.dart';
import 'core/services/inventory_service.dart';

/// Página principal de gestión de inventario para empresas
/// Sistema completo con tabs, filtros, alertas de stock crítico y reportes
class CompanyInventoryPage extends StatefulWidget {
  const CompanyInventoryPage({super.key});

  @override
  State<CompanyInventoryPage> createState() => _CompanyInventoryPageState();
}

class _CompanyInventoryPageState extends State<CompanyInventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLocation = 'Todas';
  InventoryStatus? _selectedStatus;

  final InventoryService _inventoryService = InventoryService();
  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = true;
  String? _error;
  RealtimeChannel? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadInventory();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _realtimeSubscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final items = await _inventoryService.getInventoryItems();
      
      setState(() {
        _inventoryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestItems() async {
    try {
      setState(() => _isLoading = true);

      // 1. Tubo PVC
      final tuboPVC = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: 'company1',
        name: 'Tubo PVC Presión',
        category: InventoryCategory.material,
        quantity: 50,
        unit: 'unidades',
        minStock: 10,
        location: 'Almacén Principal',
        lastUpdated: DateTime.now(),
        status: InventoryStatus.disponible,
        cost: 45.50,
        description: 'Tubo PVC para instalaciones de agua a presión',
        subcategory: MaterialSubcategory.tuboPVC.code,
        specifications: {
          'diametro': '2',
          'diametro_unidad': 'pulgadas',
          'longitud': '6',
          'longitud_unidad': 'metros',
          'espesor': 'Schedule 40',
        },
        dimensions: '2pulgadas × 6metros',
        weightPerUnit: 8.5,
      );

      // 2. Tubo Acero
      final tuboAcero = InventoryItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        companyId: 'company1',
        name: 'Tubo Acero Galvanizado',
        category: InventoryCategory.material,
        quantity: 30,
        unit: 'unidades',
        minStock: 5,
        location: 'Bodega 2',
        lastUpdated: DateTime.now(),
        status: InventoryStatus.disponible,
        cost: 125.00,
        description: 'Tubo de acero galvanizado para estructuras',
        subcategory: MaterialSubcategory.tuboAcero.code,
        specifications: {
          'diametro': '4',
          'diametro_unidad': 'pulgadas',
          'longitud': '3',
          'longitud_unidad': 'metros',
          'espesor': '3mm',
        },
        dimensions: '4pulgadas × 3metros',
        weightPerUnit: 15.2,
      );

      // 3. Arena
      final arena = InventoryItem(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        companyId: 'company1',
        name: 'Arena Gruesa',
        category: InventoryCategory.material,
        quantity: 20,
        unit: 'm³',
        minStock: 5,
        location: 'Patio Exterior',
        lastUpdated: DateTime.now(),
        status: InventoryStatus.disponible,
        cost: 35.00,
        description: 'Arena gruesa para construcción',
        subcategory: MaterialSubcategory.arena.code,
        specifications: {
          'granulometria': '2-5mm',
          'densidad': '1.6',
        },
        weightPerUnit: 1600.0,
      );

      // 4. Grava
      final grava = InventoryItem(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        companyId: 'company1',
        name: 'Grava Triturada',
        category: InventoryCategory.material,
        quantity: 15,
        unit: 'm³',
        minStock: 3,
        location: 'Patio Exterior',
        lastUpdated: DateTime.now(),
        status: InventoryStatus.disponible,
        cost: 42.00,
        description: 'Grava triturada para concreto',
        subcategory: MaterialSubcategory.grava.code,
        specifications: {
          'granulometria': '10-20mm',
          'densidad': '1.7',
        },
        weightPerUnit: 1700.0,
      );

      // 5. Cemento
      final cemento = InventoryItem(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        companyId: 'company1',
        name: 'Cemento Portland',
        category: InventoryCategory.material,
        quantity: 100,
        unit: 'bolsas',
        minStock: 20,
        location: 'Almacén Cubierto',
        lastUpdated: DateTime.now(),
        status: InventoryStatus.disponible,
        cost: 8.50,
        description: 'Cemento Portland Tipo I',
        subcategory: MaterialSubcategory.cemento.code,
        specifications: {
          'tipo': 'Portland Tipo I',
          'resistencia': '42.5 MPa',
        },
        dimensions: 'Bolsa 42.5kg',
        weightPerUnit: 42.5,
      );

      // Guardar todos los items
      await _inventoryService.createItem(tuboPVC);
      await _inventoryService.createItem(tuboAcero);
      await _inventoryService.createItem(arena);
      await _inventoryService.createItem(grava);
      await _inventoryService.createItem(cemento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 5 elementos de prueba creados exitosamente'),
            backgroundColor: AppColorsUnified.success,
            duration: Duration(seconds: 3),
          ),
        );
      }

      await _loadInventory();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear elementos: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _setupRealtimeSubscription() {
    _realtimeSubscription = _inventoryService.subscribeToInventoryChanges(
      onData: (items) {
        if (mounted) {
          setState(() {
            _inventoryItems = items;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error en actualización: $error'),
              backgroundColor: AppColorsUnified.error,
            ),
          );
        }
      },
    );
  }

  List<InventoryItem> get _filteredItems {
    return _inventoryItems.where((item) {
      bool matchesLocation = _selectedLocation == 'Todas' || item.location == _selectedLocation;
      bool matchesStatus = _selectedStatus == null || item.calculatedStatus == _selectedStatus;
      bool matchesCategory = _tabController.index == 0 || 
                             item.category == InventoryCategory.values[_tabController.index - 1];
      return matchesLocation && matchesStatus && matchesCategory;
    }).toList();
  }

  List<InventoryItem> get _criticalItems {
    return _inventoryItems.where((item) => item.needsRestock).toList()
      ..sort((a, b) => a.quantity.compareTo(b.quantity));
  }

  List<InventoryItem> get _favoriteItems {
    return _inventoryItems.where((item) => item.isFavorite).toList()
      ..sort((a, b) => b.requestCount.compareTo(a.requestCount));
  }

  List<InventoryItem> get _mostRequestedItems {
    return _inventoryItems.where((item) => item.requestCount > 0).toList()
      ..sort((a, b) => b.requestCount.compareTo(a.requestCount));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColorsUnified.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColorsUnified.gold),
              SizedBox(height: 16),
              Text(
                'Cargando inventario...',
                style: TextStyle(color: AppColorsUnified.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColorsUnified.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColorsUnified.error),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar inventario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColorsUnified.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadInventory,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsUnified.gold,
                  foregroundColor: AppColorsUnified.pureWhite,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsCards(),
                _buildAlertsSection(),
                _buildFilters(),
              ],
            ),
          ),
          _buildInventoryList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColorsUnified.goldGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.add, color: AppColorsUnified.textPrimary),
              SizedBox(width: 8),
              Text(
                'Agregar Item',
                style: TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColorsUnified.pureWhite,
      foregroundColor: AppColorsUnified.textPrimary,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColorsUnified.grey200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorsUnified.grey300),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColorsUnified.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        // Botón de elementos de prueba
        if (_inventoryItems.isEmpty)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorsUnified.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.success, 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.science, color: AppColorsUnified.pureWhite),
              tooltip: 'Crear elementos de prueba',
              onPressed: _createTestItems,
            ),
          ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColorsUnified.goldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.assessment, color: AppColorsUnified.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyInventoryReportsPage(items: _inventoryItems),
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsUnified.grey300),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: AppColorsUnified.textPrimary),
            onPressed: _showFilterOptions,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColorsUnified.greySoftGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColorsUnified.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: AppColorsUnified.textPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inventario',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColorsUnified.textPrimary,
                              ),
                            ),
                            Text(
                              '${_inventoryItems.length} items registrados',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColorsUnified.textSecondary,
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
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: AppColorsUnified.pureWhite,
            border: Border(
              bottom: BorderSide(color: AppColorsUnified.grey300),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColorsUnified.gold,
            indicatorWeight: 3,
            labelColor: AppColorsUnified.gold,
            unselectedLabelColor: AppColorsUnified.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Herramientas'),
              Tab(text: 'Equipos'),
              Tab(text: 'Materiales'),
              Tab(text: 'Repuestos'),
              Tab(text: 'Consumibles'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalValue = _inventoryItems.fold<double>(0, (sum, item) => sum + item.totalValue);
    final lowStockCount = _inventoryItems.where((item) => 
      item.calculatedStatus == InventoryStatus.bajo || 
      item.calculatedStatus == InventoryStatus.critico
    ).length;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(
            'Total Items',
            '${_inventoryItems.length}',
            Icons.inventory,
            AppColorsUnified.companyBlue,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            'Valor Total',
            '\$${totalValue.toStringAsFixed(0)}',
            Icons.attach_money,
            AppColorsUnified.success,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            'Stock Bajo',
            '$lowStockCount',
            Icons.warning,
            AppColorsUnified.warning,
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorsUnified.fade(color, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avisos Importantes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAlertCard(
                  title: 'Próximos a Agotarse',
                  count: _criticalItems.length,
                  icon: Icons.warning_amber_rounded,
                  color: AppColorsUnified.error,
                  items: _criticalItems.take(3).toList(),
                  onTap: () => setState(() => _selectedStatus = InventoryStatus.critico),
                ),
                const SizedBox(width: 12),
                _buildAlertCard(
                  title: 'Favoritos',
                  count: _favoriteItems.length,
                  icon: Icons.favorite,
                  color: AppColorsUnified.gold,
                  items: _favoriteItems.take(3).toList(),
                  onTap: () => _showFavoriteItems(),
                ),
                const SizedBox(width: 12),
                _buildAlertCard(
                  title: 'Más Pedidos',
                  count: _mostRequestedItems.take(5).length,
                  icon: Icons.trending_up,
                  color: AppColorsUnified.copperDark,
                  items: _mostRequestedItems.take(3).toList(),
                  onTap: () => _showMostRequestedItems(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required List<InventoryItem> items,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColorsUnified.fade(color, 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.fade(color, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                      Text(
                        '$count items',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: color),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: AppColorsUnified.grey300,
              ),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (title == 'Más Pedidos')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.fade(color, 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.requestCount}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    if (title == 'Próximos a Agotarse')
                      Text(
                        '${item.quantity.toInt()}/${item.minStock.toInt()}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                  ],
                ),
              )),
            ] else ...[
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Sin elementos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFavoriteItems() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildItemsModal(
        title: 'Items Favoritos',
        icon: Icons.favorite,
        color: AppColorsUnified.gold,
        items: _favoriteItems,
      ),
    );
  }

  void _showMostRequestedItems() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildItemsModal(
        title: 'Items Más Pedidos',
        icon: Icons.trending_up,
        color: AppColorsUnified.copperDark,
        items: _mostRequestedItems.take(10).toList(),
      ),
    );
  }

  Widget _buildItemsModal({
    required String title,
    required IconData icon,
    required Color color,
    required List<InventoryItem> items,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColorsUnified.grey300)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.fade(color, 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColorsUnified.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColorsUnified.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 64, color: AppColorsUnified.grey400),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay items en esta categoría',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorsUnified.pureWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColorsUnified.grey300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColorsUnified.fade(color, 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsUnified.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} ${item.unit} • ${item.location}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColorsUnified.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (title.contains('Pedidos'))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppColorsUnified.goldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shopping_cart, size: 14, color: AppColorsUnified.textPrimary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.requestCount}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsUnified.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (item.isFavorite && title.contains('Favoritos'))
                              const Icon(Icons.favorite, color: AppColorsUnified.gold, size: 20),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final locations = ['Todas', ..._inventoryItems.map((e) => e.location).toSet()];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Ubicación',
                    _selectedLocation,
                    Icons.location_on,
                    () => _showLocationPicker(locations),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Estado',
                    _selectedStatus?.label ?? 'Todos',
                    Icons.filter_alt,
                    _showStatusPicker,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColorsUnified.grey200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColorsUnified.grey300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColorsUnified.textSecondary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20, color: AppColorsUnified.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    final items = _filteredItems;
    
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColorsUnified.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No hay items en esta categoría',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildInventoryCard(items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final status = item.calculatedStatus;
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showItemDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(item.category),
                        color: AppColorsUnified.textPrimary,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                          Text(
                            item.category.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColorsUnified.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.fade(statusColor, 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón de favorito
                    InkWell(
                      onTap: () => _toggleFavorite(item),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.isFavorite
                              ? AppColorsUnified.fade(AppColorsUnified.gold, 0.15)
                              : AppColorsUnified.grey200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.isFavorite
                                ? AppColorsUnified.gold
                                : AppColorsUnified.grey300,
                          ),
                        ),
                        child: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: item.isFavorite
                              ? AppColorsUnified.gold
                              : AppColorsUnified.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.grey200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn('Stock Actual', '${item.quantity} ${item.unit}', Icons.inventory),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColorsUnified.grey300,
                      ),
                      Expanded(
                        child: _buildInfoColumn('Stock Mínimo', '${item.minStock} ${item.unit}', Icons.warning_amber),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColorsUnified.grey300,
                      ),
                      Expanded(
                        child: _buildInfoColumn('Ubicación', item.location, Icons.location_on),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.cost != null)
                      Text(
                        'Valor Total: \$${item.totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.success,
                        ),
                      ),
                    if (item.cost != null)
                      Text(
                        'Costo unitario: \$${item.cost!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    if (item.requestCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColorsUnified.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              size: 14,
                              color: AppColorsUnified.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.requestCount} pedidos',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColorsUnified.textPrimary,
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
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColorsUnified.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColorsUnified.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.disponible:
        return AppColorsUnified.success;
      case InventoryStatus.bajo:
        return AppColorsUnified.warning;
      case InventoryStatus.critico:
        return AppColorsUnified.error;
      case InventoryStatus.agotado:
        return AppColorsUnified.error;
    }
  }

  IconData _getCategoryIcon(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.herramienta:
        return Icons.build;
      case InventoryCategory.equipo:
        return Icons.precision_manufacturing;
      case InventoryCategory.material:
        return Icons.inventory_2;
      case InventoryCategory.repuesto:
        return Icons.settings_suggest;
      case InventoryCategory.consumible:
        return Icons.battery_charging_full;
      case InventoryCategory.seguridad:
        return Icons.security;
    }
  }

  void _showFilterOptions() {
    // Implementar filtros avanzados
  }

  void _showLocationPicker(List<String> locations) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: locations.map((loc) => ListTile(
            title: Text(loc),
            selected: _selectedLocation == loc,
            trailing: _selectedLocation == loc ? const Icon(Icons.check, color: AppColorsUnified.gold) : null,
            onTap: () {
              setState(() => _selectedLocation = loc);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              selected: _selectedStatus == null,
              trailing: _selectedStatus == null ? const Icon(Icons.check, color: AppColorsUnified.gold) : null,
              onTap: () {
                setState(() => _selectedStatus = null);
                Navigator.pop(context);
              },
            ),
            ...InventoryStatus.values.map((status) => ListTile(
              title: Text(status.label),
              leading: Icon(Icons.circle, color: _getStatusColor(status)),
              selected: _selectedStatus == status,
              trailing: _selectedStatus == status ? const Icon(Icons.check, color: AppColorsUnified.gold) : null,
              onTap: () {
                setState(() => _selectedStatus = status);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() async {
    final result = await Navigator.push<InventoryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanyAddInventoryItemPage(),
      ),
    );

    if (result != null && mounted) {
      try {
        // Guardar en Supabase
        await _inventoryService.createItem(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} agregado al inventario'),
              backgroundColor: AppColorsUnified.success,
            ),
          );
        }
        // La lista se actualizará automáticamente por la suscripción en tiempo real
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: AppColorsUnified.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite(InventoryItem item) async {
    try {
      await _inventoryService.toggleFavorite(item.id, item.isFavorite);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.isFavorite 
                  ? '${item.name} eliminado de favoritos'
                  : '${item.name} agregado a favoritos',
            ),
            backgroundColor: AppColorsUnified.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // La lista se actualizará automáticamente por la suscripción en tiempo real
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar favorito: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  void _showItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColorsUnified.pureWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColorsUnified.goldGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(item.category),
                            color: AppColorsUnified.pureWhite,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsUnified.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item.calculatedStatus),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.calculatedStatus.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColorsUnified.pureWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Detalles',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Stock Actual', '${item.quantity} ${item.unit}'),
                    _buildDetailRow('Stock Mínimo', '${item.minStock} ${item.unit}'),
                    _buildDetailRow('Ubicación', item.location),
                    if (item.supplier != null)
                      _buildDetailRow('Proveedor', item.supplier!),
                    if (item.cost != null) ...[
                      _buildDetailRow('Costo Unitario', '\$${item.cost!.toStringAsFixed(2)}'),
                      _buildDetailRow('Valor Total', '\$${item.totalValue.toStringAsFixed(2)}'),
                    ],
                    _buildDetailRow(
                      'Última Actualización',
                      '${item.lastUpdated.day}/${item.lastUpdated.month}/${item.lastUpdated.year}',
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompanyInventoryMovementsPage(item: item),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Ver Historial'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColorsUnified.gold,
                              side: const BorderSide(color: AppColorsUnified.gold),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              final result = await Navigator.push<InventoryItem>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompanyAddInventoryItemPage(
                                    existingItem: item,
                                  ),
                                ),
                              );
                              if (result != null && mounted) {
                                try {
                                  // Actualizar en Supabase
                                  await _inventoryService.updateItem(result);
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${result.name} actualizado'),
                                        backgroundColor: AppColorsUnified.success,
                                      ),
                                    );
                                  }
                                  // La lista se actualizará automáticamente por la suscripción
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al actualizar: $e'),
                                        backgroundColor: AppColorsUnified.error,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColorsUnified.pureWhite,
                              backgroundColor: AppColorsUnified.gold,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

