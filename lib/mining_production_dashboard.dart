import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../shared/models/mining_production.dart';
import 'core/theme/app_colors_unified.dart';

import 'core/theme/dashboard_colors.dart';

class MiningProductionDashboard extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const MiningProductionDashboard({
    super.key,
    this.currentUser,
  });

  @override
  State<MiningProductionDashboard> createState() => _MiningProductionDashboardState();
}

class _MiningProductionDashboardState extends State<MiningProductionDashboard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  String _selectedPeriod = 'Hoy';
  String _selectedZone = 'Todas';

  // Datos de ejemplo (luego se cargarán desde Supabase)
  final List<MiningProduction> _productionData = [];
  ProductionStats? _stats;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _loadProductionData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _loadProductionData() async {
    // TODO: Cargar desde repositorio
    await Future.delayed(const Duration(seconds: 1));
    
    // Generar datos de ejemplo
    _generateSampleData();
  }

  void _generateSampleData() {
    // Datos de ejemplo para demostración
    final now = DateTime.now();
    _productionData.clear();
    
    _productionData.addAll([
      MiningProduction(
        id: '1',
        companyId: widget.currentUser?['id'] ?? '',
        zoneName: 'Zona Norte',
        mineralType: 'Oro',
        tonnage: 45.5,
        purity: 85.0,
        grade: 12.5,
        productionDate: now,
        shift: 'morning',
        workersCount: 25,
        status: 'completed',
        createdAt: now,
      ),
      MiningProduction(
        id: '2',
        companyId: widget.currentUser?['id'] ?? '',
        zoneName: 'Zona Sur',
        mineralType: 'Plata',
        tonnage: 120.0,
        purity: 92.0,
        grade: 850.0,
        productionDate: now,
        shift: 'afternoon',
        workersCount: 30,
        status: 'active',
        createdAt: now,
      ),
      MiningProduction(
        id: '3',
        companyId: widget.currentUser?['id'] ?? '',
        zoneName: 'Zona Este',
        mineralType: 'Cobre',
        tonnage: 380.0,
        purity: 78.0,
        grade: 2.8,
        productionDate: now.subtract(const Duration(days: 1)),
        shift: 'night',
        workersCount: 40,
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // Calcular estadísticas
    _calculateStats();
  }

  void _calculateStats() {
    if (_productionData.isEmpty) {
      _stats = ProductionStats.empty();
      return;
    }

    double totalTonnage = 0;
    double totalPurity = 0;
    double totalGrade = 0;
    Map<String, double> byMineral = {};
    Map<String, double> byZone = {};
    Map<String, double> byShift = {};

    for (var prod in _productionData) {
      totalTonnage += prod.tonnage;
      totalPurity += prod.purity;
      totalGrade += prod.grade;

      byMineral[prod.mineralType] = (byMineral[prod.mineralType] ?? 0) + prod.tonnage;
      byZone[prod.zoneName] = (byZone[prod.zoneName] ?? 0) + prod.tonnage;
      byShift[prod.shift] = (byShift[prod.shift] ?? 0) + prod.tonnage;
    }

    _stats = ProductionStats(
      totalTonnage: totalTonnage,
      averagePurity: totalPurity / _productionData.length,
      averageGrade: totalGrade / _productionData.length,
      totalRecords: _productionData.length,
      byMineral: byMineral,
      byZone: byZone,
      byShift: byShift,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      body: CustomScrollView(
        slivers: [
          // App Bar épico con gradiente minero
          _buildEpicAppBar(),

          // Filtros de período y zona
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildFilters(),
            ),
          ),

          // Métricas principales con animación
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMainMetrics(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Gráficos de producción
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProductionCharts(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Lista de producciones recientes
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildRecentProductions(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEpicAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColorsUnified.orangeDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradiente minero
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsUnified.charcoal,
                    AppColorsUnified.darken(AppColorsUnified.charcoal, 0.1),
                    DashboardColors.wood,
                    AppColorsUnified.gold,
                  ],
                ),
              ),
            ),

            // Patrón animado
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _MiningPatternPainter(
                      animation: _rotateController.value,
                    ),
                  );
                },
              ),
            ),

            // Contenido
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.6 * _pulseController.value),
                                    blurRadius: 20 * _pulseController.value,
                                    spreadRadius: 5 * _pulseController.value,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.show_chart,
                                color: AppColorsUnified.pureWhite,
                                size: 32,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⛏️ Producción Minera',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsUnified.pureWhite,
                                  shadows: [
                                    Shadow(
                                      color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.45),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Dashboard en Tiempo Real',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColorsUnified.gold,
                                  fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsUnified.pureWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            label: _selectedPeriod,
            icon: Icons.calendar_today,
            onTap: () => _showPeriodPicker(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFilterChip(
            label: _selectedZone,
            icon: Icons.place,
            onTap: () => _showZonePicker(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColorsUnified.orange,
              AppColorsUnified.lighten(AppColorsUnified.orange, 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColorsUnified.fade(AppColorsUnified.orange, 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColorsUnified.pureWhite, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColorsUnified.pureWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: AppColorsUnified.pureWhite, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMetrics() {
    if (_stats == null) return const SizedBox();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Toneladas Totales',
                value: '${_stats!.totalTonnage.toStringAsFixed(1)}t',
                icon: Icons.fitness_center,
                color: AppColorsUnified.gold,
                trend: '+12%',
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                label: 'Pureza Promedio',
                value: '${_stats!.averagePurity.toStringAsFixed(1)}%',
                icon: Icons.verified,
                color: AppColorsUnified.orange,
                trend: '+5%',
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Ley Promedio',
                value: _stats!.averageGrade.toStringAsFixed(2),
                icon: Icons.analytics,
                color: DashboardColors.wood,
                trend: '+8%',
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                label: 'Registros',
                value: '${_stats!.totalRecords}',
                icon: Icons.description,
                color: DashboardColors.cardBlue,
                trend: 'Hoy',
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.9), color],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: color.withOpacity((0.2 * _pulseController.value).clamp(0.0, 1.0)),
                      blurRadius: 25 * _pulseController.value,
                      spreadRadius: 3 * _pulseController.value,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: AppColorsUnified.pureWhite, size: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            trend,
                            style: TextStyle(
                              color: AppColorsUnified.pureWhite,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.pureWhite,
                        shadows: [
                          Shadow(
                            color: AppColorsUnified.fade(AppColorsUnified.charcoal, 0.26),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductionCharts() {
    if (_stats == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Producción por Mineral',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DashboardColors.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        _buildMineralChart(),
        const SizedBox(height: 24),
        Text(
          'Producción por Zona',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DashboardColors.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        _buildZoneChart(),
      ],
    );
  }

  Widget _buildMineralChart() {
    final minerals = _stats!.byMineral.entries.toList();
    final maxValue = minerals.map((e) => e.value).reduce(math.max);

    return Column(
      children: minerals.map((entry) {
        final percentage = (entry.value / maxValue);
        return _buildChartBar(
          label: entry.key,
          value: entry.value,
          percentage: percentage,
          color: _getMineralColor(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildZoneChart() {
    final zones = _stats!.byZone.entries.toList();
    final maxValue = zones.map((e) => e.value).reduce(math.max);

    return Column(
      children: zones.map((entry) {
        final percentage = (entry.value / maxValue);
        return _buildChartBar(
          label: entry.key,
          value: entry.value,
          percentage: percentage,
          color: DashboardColors.wood,
        );
      }).toList(),
    );
  }

  Widget _buildChartBar({
    required String label,
    required double value,
    required double percentage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percentage),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.charcoal,
                    ),
                  ),
                  Text(
                    '${value.toStringAsFixed(1)}t',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: DashboardColors.gray200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animValue,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentProductions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registros Recientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DashboardColors.charcoal,
          ),
        ),
        const SizedBox(height: 16),
        ..._productionData.map((prod) => _buildProductionCard(prod)),
      ],
    );
  }

  Widget _buildProductionCard(MiningProduction production) {
    final mineralColor = _getMineralColor(production.mineralType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.fade(mineralColor, 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.fade(mineralColor, 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mineralColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.diamond, color: mineralColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      production.mineralType,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mineralColor,
                      ),
                    ),
                    Text(
                      production.zoneName,
                      style: TextStyle(
                        fontSize: 14,
                        color: DashboardColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: mineralColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  production.shiftDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mineralColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProductionDetail(
                Icons.fitness_center,
                '${production.tonnage.toStringAsFixed(1)}t',
                'Toneladas',
              ),
              const SizedBox(width: 16),
              _buildProductionDetail(
                Icons.verified,
                '${production.purity.toStringAsFixed(1)}%',
                'Pureza',
              ),
              const SizedBox(width: 16),
              _buildProductionDetail(
                Icons.people,
                '${production.workersCount}',
                'Trabajadores',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductionDetail(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: DashboardColors.gray600, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DashboardColors.charcoal,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: DashboardColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMineralColor(String mineral) {
    switch (mineral.toLowerCase()) {
      case 'oro':
      case 'gold':
        return AppColorsUnified.gold;
      case 'plata':
      case 'silver':
        return AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.5);
      case 'cobre':
      case 'copper':
        return AppColorsUnified.copperDark;
      case 'hierro':
      case 'iron':
        return AppColorsUnified.textSecondary;
      default:
        return DashboardColors.wood;
    }
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Período',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColorsUnified.charcoal),
            ),
            const SizedBox(height: 20),
            ...['Hoy', 'Esta Semana', 'Este Mes', 'Este Año'].map((period) {
              return ListTile(
                title: Text(period),
                leading: const Icon(
                  Icons.calendar_today,
                  color: AppColorsUnified.orange,
                ),
                onTap: () {
                  setState(() => _selectedPeriod = period);
                  Navigator.pop(context);
                  _loadProductionData();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showZonePicker() {
    final zones = ['Todas', 'Zona Norte', 'Zona Sur', 'Zona Este', 'Zona Oeste'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Zona',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColorsUnified.charcoal),
            ),
            const SizedBox(height: 20),
            ...zones.map((zone) {
              return ListTile(
                title: Text(zone),
                leading: Icon(
                  Icons.place,
                  color: DashboardColors.wood,
                ),
                onTap: () {
                  setState(() => _selectedZone = zone);
                  Navigator.pop(context);
                  _loadProductionData();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Custom Painter para el patrón minero animado
class _MiningPatternPainter extends CustomPainter {
  final double animation;

  _MiningPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Picos de montaña estilizados
    final mountainPaint = Paint()
      ..color = AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final x = (size.width / 4) * i + (animation * 50);
      path.moveTo(x - 40, size.height);
      path.lineTo(x, size.height * 0.3);
      path.lineTo(x + 40, size.height);
      path.close();
    }
    canvas.drawPath(path, mountainPaint);

    // Círculos dorados rotando (pepitas de oro)
    final goldPaint = Paint()
      ..color = AppColorsUnified.fade(AppColorsUnified.gold, 0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (animation * 2 * math.pi) + (i * math.pi / 4);
      final x = size.width * 0.5 + math.cos(angle) * 80;
      final y = size.height * 0.5 + math.sin(angle) * 80;
      canvas.drawCircle(Offset(x, y), 8, goldPaint);
    }
  }

  @override
  bool shouldRepaint(_MiningPatternPainter oldDelegate) => true;
}
