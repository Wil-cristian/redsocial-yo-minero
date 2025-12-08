import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/core/di/locator.dart';
import 'package:yominero/features/posts/domain/post_repository.dart';
import 'package:yominero/features/posts/ui/post_creation_sheet.dart';
import '../data/my_inventory_repository.dart';
import '../models/inventory_item.dart';
import 'widgets/inventory_item_card.dart';
import 'widgets/inventory_summary_card.dart';
import 'widgets/inventory_metrics_dialog.dart';

class MyInventoryPage extends StatefulWidget {
  const MyInventoryPage({super.key});

  @override
  State<MyInventoryPage> createState() => _MyInventoryPageState();
}

class _MyInventoryPageState extends State<MyInventoryPage> with SingleTickerProviderStateMixin {
  late final MyInventoryRepository _repository;
  late final PostRepository _postRepo;
  late TabController _tabController;
  
  List<InventoryItem> _allItems = [];
  InventorySummary? _summary;
  bool _isLoading = true;
  String? _error;
  
  // Filtros
  InventoryItemType? _selectedType;
  InventoryItemStatus? _selectedStatus;
  String _sortBy = 'created_at';
  bool _sortDescending = true;
  
  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Todo', 'icon': Icons.grid_view_rounded, 'type': null},
    {'label': 'Productos', 'icon': Icons.shopping_bag_rounded, 'type': InventoryItemType.product},
    {'label': 'Servicios', 'icon': Icons.build_circle_rounded, 'type': InventoryItemType.service},
    {'label': 'Preguntas', 'icon': Icons.help_rounded, 'type': InventoryItemType.request},
    {'label': 'Encuestas', 'icon': Icons.poll_rounded, 'type': InventoryItemType.poll},
    {'label': 'Noticias', 'icon': Icons.article_rounded, 'type': InventoryItemType.news},
    {'label': 'Ofertas', 'icon': Icons.local_offer_rounded, 'type': InventoryItemType.offer},
  ];

  @override
  void initState() {
    super.initState();
    _repository = MyInventoryRepository(SupabaseService.instance.client);
    _postRepo = sl<PostRepository>();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedType = _tabs[_tabController.index]['type'];
      });
    }
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _repository.getMyInventory(
        filterType: _selectedType,
        filterStatus: _selectedStatus,
        sortBy: _sortBy,
        descending: _sortDescending,
      );
      
      final summary = await _repository.getInventorySummary();

      setState(() {
        _allItems = items;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando inventario: $e';
        _isLoading = false;
      });
    }
  }

  List<InventoryItem> get _filteredItems {
    if (_selectedType == null) return _allItems;
    return _allItems.where((item) => item.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
          if (_summary != null) _buildSummarySliver(),
          _buildTabBar(),
        ],
        body: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOptions,
        backgroundColor: AppColorsUnified.gold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Publicar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      backgroundColor: AppColorsUnified.backgroundDark,
      pinned: true,
      floating: true,
      expandedHeight: 120,
      forceElevated: innerBoxIsScrolled,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterOptions,
        ),
        IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: _showSortOptions,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadInventory,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Inventario',
              style: TextStyle(
                color: AppColorsUnified.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_summary != null)
              Text(
                '${_summary!.totalItems} publicaciones • ${_summary!.activeItems} activas',
                style: TextStyle(
                  color: AppColorsUnified.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InventorySummaryCard(
          summary: _summary!,
          onTap: _showDetailedStats,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColorsUnified.gold,
          labelColor: AppColorsUnified.gold,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: _tabs.map((tab) {
            final count = _getCountForType(tab['type']);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab['icon'], size: 18),
                  const SizedBox(width: 6),
                  Text(tab['label']),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColorsUnified.gold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        backgroundColor: AppColorsUnified.backgroundDark,
      ),
    );
  }

  int _getCountForType(InventoryItemType? type) {
    if (type == null) return _allItems.length;
    return _allItems.where((item) => item.type == type).length;
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColorsUnified.gold),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadInventory,
      color: AppColorsUnified.gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InventoryItemCard(
              item: item,
              onTap: () => _showItemDetails(item),
              onMetricsTap: () => _showItemMetrics(item),
              onStatusChange: (newStatus) => _updateItemStatus(item, newStatus),
              onDelete: () => _confirmDelete(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final type = _selectedType;
    String title;
    String subtitle;
    IconData icon;

    if (type == null) {
      title = '¡Tu inventario está vacío!';
      subtitle = 'Comienza publicando productos, servicios, preguntas o más';
      icon = Icons.inventory_2_outlined;
    } else {
      title = 'Sin ${_tabs.firstWhere((t) => t['type'] == type)['label'].toString().toLowerCase()}';
      subtitle = 'No has publicado ningún item de este tipo';
      icon = _tabs.firstWhere((t) => t['type'] == type)['icon'] as IconData;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColorsUnified.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColorsUnified.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateOptions,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Crear Publicación',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsUnified.gold,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColorsUnified.error),
            const SizedBox(height: 24),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Ocurrió un error inesperado',
              style: TextStyle(
                fontSize: 14,
                color: AppColorsUnified.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInventory,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsUnified.gold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedStatus: _selectedStatus,
        onStatusSelected: (status) {
          setState(() => _selectedStatus = status);
          Navigator.pop(context);
          _loadInventory();
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SortBottomSheet(
        currentSort: _sortBy,
        isDescending: _sortDescending,
        onSortSelected: (sortBy, descending) {
          setState(() {
            _sortBy = sortBy;
            _sortDescending = descending;
          });
          Navigator.pop(context);
          _loadInventory();
        },
      ),
    );
  }

  void _showCreateOptions() {
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
          return _postRepo.create(
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
        onCreated: (post) {
          Navigator.pop(ctx);
          _loadInventory(); // Recargar el inventario
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Publicación creada exitosamente!'),
              backgroundColor: AppColorsUnified.success,
            ),
          );
        },
      ),
    );
  }

  void _showItemDetails(InventoryItem item) {
    // Navegar al detalle del post
    Navigator.pushNamed(
      context, 
      '/post-detail',
      arguments: {'postId': item.postId},
    );
  }

  void _showItemMetrics(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => InventoryMetricsDialog(item: item),
    );
  }

  void _showDetailedStats() {
    // Mostrar estadísticas detalladas del inventario
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
            color: AppColorsUnified.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _DetailedStatsSheet(
            summary: _summary!,
            items: _allItems,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }

  Future<void> _updateItemStatus(InventoryItem item, InventoryItemStatus newStatus) async {
    final success = await _repository.updateItemStatus(item.postId, newStatus);
    if (success) {
      _loadInventory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a ${newStatus.name}'),
          backgroundColor: AppColorsUnified.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al actualizar estado'),
          backgroundColor: AppColorsUnified.error,
        ),
      );
    }
  }

  void _confirmDelete(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsUnified.surface,
        title: Text(
          '¿Archivar publicación?',
          style: TextStyle(color: AppColorsUnified.textPrimary),
        ),
        content: Text(
          'La publicación "${item.title}" será archivada y ya no será visible.',
          style: TextStyle(color: AppColorsUnified.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repository.archiveItem(item.postId);
              _loadInventory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsUnified.error,
            ),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
  }
}

// Delegate para el TabBar sticky
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

// Bottom sheet para filtros
class _FilterBottomSheet extends StatelessWidget {
  final InventoryItemStatus? selectedStatus;
  final Function(InventoryItemStatus?) onStatusSelected;

  const _FilterBottomSheet({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'label': 'Todos', 'value': null, 'icon': Icons.all_inclusive},
      {'label': 'Activos', 'value': InventoryItemStatus.active, 'icon': Icons.check_circle},
      {'label': 'Vendidos', 'value': InventoryItemStatus.sold, 'icon': Icons.sell},
      {'label': 'Pausados', 'value': InventoryItemStatus.paused, 'icon': Icons.pause_circle},
      {'label': 'Archivados', 'value': InventoryItemStatus.archived, 'icon': Icons.archive},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColorsUnified.gold),
              const SizedBox(width: 12),
              Text(
                'Filtrar por Estado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...statuses.map((status) => ListTile(
            leading: Icon(
              status['icon'] as IconData,
              color: selectedStatus == status['value'] 
                  ? AppColorsUnified.gold 
                  : AppColorsUnified.textSecondary,
            ),
            title: Text(
              status['label'] as String,
              style: TextStyle(
                color: selectedStatus == status['value']
                    ? AppColorsUnified.gold
                    : AppColorsUnified.textPrimary,
                fontWeight: selectedStatus == status['value']
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            trailing: selectedStatus == status['value']
                ? Icon(Icons.check, color: AppColorsUnified.gold)
                : null,
            onTap: () => onStatusSelected(status['value'] as InventoryItemStatus?),
          )),
        ],
      ),
    );
  }
}

// Bottom sheet para ordenar
class _SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final bool isDescending;
  final Function(String, bool) onSortSelected;

  const _SortBottomSheet({
    required this.currentSort,
    required this.isDescending,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'label': 'Fecha de creación', 'value': 'created_at'},
      {'label': 'Título', 'value': 'title'},
      {'label': 'Likes', 'value': 'likes'},
      {'label': 'Comentarios', 'value': 'comments'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sort, color: AppColorsUnified.gold),
              const SizedBox(width: 12),
              Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortOptions.map((option) => ListTile(
            title: Text(
              option['label'] as String,
              style: TextStyle(
                color: currentSort == option['value']
                    ? AppColorsUnified.gold
                    : AppColorsUnified.textPrimary,
              ),
            ),
            trailing: currentSort == option['value']
                ? Icon(
                    isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    color: AppColorsUnified.gold,
                  )
                : null,
            onTap: () {
              if (currentSort == option['value']) {
                onSortSelected(option['value'] as String, !isDescending);
              } else {
                onSortSelected(option['value'] as String, true);
              }
            },
          )),
        ],
      ),
    );
  }
}

// Sheet de estadísticas detalladas
class _DetailedStatsSheet extends StatelessWidget {
  final InventorySummary summary;
  final List<InventoryItem> items;
  final ScrollController scrollController;

  const _DetailedStatsSheet({
    required this.summary,
    required this.items,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColorsUnified.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Título
        Text(
          'Estadísticas Detalladas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.gold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Métricas generales
        _buildMetricsGrid(),
        
        const SizedBox(height: 24),
        
        // Distribución por tipo
        _buildTypeDistribution(),
        
        const SizedBox(height: 24),
        
        // Top performers
        _buildTopPerformers(),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {'label': 'Total Vistas', 'value': summary.totalViews.toString(), 'icon': Icons.visibility},
      {'label': 'Total Likes', 'value': summary.totalLikes.toString(), 'icon': Icons.favorite},
      {'label': 'Total Comentarios', 'value': summary.totalComments.toString(), 'icon': Icons.comment},
      {'label': 'Chats Iniciados', 'value': summary.totalChats.toString(), 'icon': Icons.chat},
      {'label': 'Engagement Promedio', 'value': '${summary.avgEngagement.toStringAsFixed(1)}%', 'icon': Icons.trending_up},
      {'label': 'Ingresos Totales', 'value': '\$${summary.totalRevenue.toStringAsFixed(0)}', 'icon': Icons.attach_money},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: metrics.map((metric) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorsUnified.backgroundDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(metric['icon'] as IconData, color: AppColorsUnified.gold, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric['value'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.textPrimary,
                  ),
                ),
                Text(
                  metric['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTypeDistribution() {
    final types = [
      {'label': 'Productos', 'count': summary.totalProducts, 'color': Colors.orange},
      {'label': 'Servicios', 'count': summary.totalServices, 'color': Colors.blue},
      {'label': 'Preguntas', 'count': summary.totalQuestions, 'color': Colors.purple},
      {'label': 'Encuestas', 'count': summary.totalPolls, 'color': Colors.green},
      {'label': 'Noticias', 'count': summary.totalNews, 'color': Colors.red},
      {'label': 'Ofertas', 'count': summary.totalOffers, 'color': Colors.teal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución por Tipo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...types.where((t) => (t['count'] as int) > 0).map((type) {
          final percentage = summary.totalItems > 0 
              ? (type['count'] as int) / summary.totalItems * 100 
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type['label'] as String,
                      style: TextStyle(color: AppColorsUnified.textPrimary),
                    ),
                    Text(
                      '${type['count']} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: AppColorsUnified.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColorsUnified.backgroundDark,
                    valueColor: AlwaysStoppedAnimation(type['color'] as Color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTopPerformers() {
    // Ordenar por engagement
    final sorted = List<InventoryItem>.from(items);
    sorted.sort((a, b) => b.metrics.engagementRate.compareTo(a.metrics.engagementRate));
    final top5 = sorted.take(5).toList();

    if (top5.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Publicaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...top5.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColorsUnified.gold.withOpacity(0.2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColorsUnified.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColorsUnified.textPrimary),
            ),
            subtitle: Text(
              '${item.typeLabel} • ${item.metrics.engagementRate.toStringAsFixed(1)}% engagement',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 14, color: AppColorsUnified.error),
                    const SizedBox(width: 2),
                    Text(
                      '${item.metrics.likes}',
                      style: TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.comment, size: 14, color: AppColorsUnified.companyBlue),
                    const SizedBox(width: 2),
                    Text(
                      '${item.metrics.comments}',
                      style: TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
