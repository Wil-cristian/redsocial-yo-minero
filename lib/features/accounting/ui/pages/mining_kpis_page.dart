import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/financial_entry.dart';
import '../../models/financial_metrics.dart';
import '../../data/accounting_repository.dart';
import '../../data/financial_calculator.dart';

/// Página de KPIs y métricas de eficiencia para minería
class MiningKPIsPage extends StatefulWidget {
  final String companyId;
  final String companyName;

  const MiningKPIsPage({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<MiningKPIsPage> createState() => _MiningKPIsPageState();
}

class _MiningKPIsPageState extends State<MiningKPIsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = AccountingRepository();

  bool _isLoading = true;
  String? _errorMessage;

  // Datos
  FinancialSummary? _summary;
  List<CategoryBreakdown> _incomeBreakdown = [];
  List<CategoryBreakdown> _expenseBreakdown = [];
  List<DailyCashFlow> _monthlyFlow = [];

  // KPIs calculados
  MiningKPIs? _kpis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadKPIs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadKPIs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final results = await Future.wait([
        _repository.getSummary(
          widget.companyId,
          startDate: startOfMonth,
          endDate: now,
        ),
        _repository.getCategoryBreakdown(
          widget.companyId,
          startDate: startOfMonth,
          endDate: now,
          type: EntryType.income,
        ),
        _repository.getCategoryBreakdown(
          widget.companyId,
          startDate: startOfMonth,
          endDate: now,
          type: EntryType.expense,
        ),
        _repository.getDailyCashFlow(widget.companyId, days: 30),
      ]);

      setState(() {
        _summary = results[0] as FinancialSummary;
        _incomeBreakdown = results[1] as List<CategoryBreakdown>;
        _expenseBreakdown = results[2] as List<CategoryBreakdown>;
        _monthlyFlow = results[3] as List<DailyCashFlow>;
        _kpis = _calculateMiningKPIs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar KPIs: $e';
        _isLoading = false;
      });
    }
  }

  MiningKPIs _calculateMiningKPIs() {
    final summary = _summary ?? FinancialSummary.empty();
    
    // Extraer ingresos por tipo de mineral
    double goldRevenue = 0;
    double silverRevenue = 0;
    double otherRevenue = 0;
    
    for (var cat in _incomeBreakdown) {
      if (cat.category == 'gold_sale') {
        goldRevenue = cat.amount;
      } else if (cat.category == 'silver_sale') {
        silverRevenue = cat.amount;
      } else {
        otherRevenue += cat.amount;
      }
    }

    // Extraer costos operacionales
    double laborCost = 0;
    double equipmentCost = 0;
    double fuelCost = 0;
    double explosivesCost = 0;
    double maintenanceCost = 0;
    double otherCosts = 0;

    for (var cat in _expenseBreakdown) {
      switch (cat.category) {
        case 'labor':
        case 'wages':
          laborCost += cat.amount;
          break;
        case 'equipment_rental':
        case 'equipment_purchase':
          equipmentCost += cat.amount;
          break;
        case 'fuel':
          fuelCost += cat.amount;
          break;
        case 'explosives':
          explosivesCost += cat.amount;
          break;
        case 'maintenance':
          maintenanceCost += cat.amount;
          break;
        default:
          otherCosts += cat.amount;
      }
    }

    // Simular datos de producción (en una implementación real vendrían de otra tabla)
    final daysInMonth = DateTime.now().day;
    final estimatedTonsExtracted = summary.totalIncome / 50; // Estimación basada en ingresos
    final estimatedGramsProduced = goldRevenue / 60 + silverRevenue / 0.8; // Precios aproximados

    return MiningKPIs(
      // Producción
      totalTonsExtracted: estimatedTonsExtracted,
      goldGramsProduced: goldRevenue / 60,
      silverGramsProduced: silverRevenue / 0.8,
      averageDailyProduction: estimatedTonsExtracted / daysInMonth,
      
      // Costos
      costPerTon: estimatedTonsExtracted > 0 
          ? summary.totalExpenses / estimatedTonsExtracted 
          : 0,
      laborCostPercentage: summary.totalExpenses > 0 
          ? (laborCost / summary.totalExpenses * 100) 
          : 0,
      fuelCostPercentage: summary.totalExpenses > 0 
          ? (fuelCost / summary.totalExpenses * 100) 
          : 0,
      maintenanceCostPercentage: summary.totalExpenses > 0 
          ? (maintenanceCost / summary.totalExpenses * 100) 
          : 0,
          
      // Eficiencia
      operatingMargin: summary.profitMargin,
      revenuePerTon: estimatedTonsExtracted > 0 
          ? summary.totalIncome / estimatedTonsExtracted 
          : 0,
      laborProductivity: laborCost > 0 
          ? summary.totalIncome / laborCost 
          : 0,
      equipmentEfficiency: equipmentCost > 0 
          ? summary.totalIncome / equipmentCost 
          : 0,
          
      // Detalles de costos
      laborCost: laborCost,
      equipmentCost: equipmentCost,
      fuelCost: fuelCost,
      explosivesCost: explosivesCost,
      maintenanceCost: maintenanceCost,
      otherCosts: otherCosts,
      
      // Ingresos
      goldRevenue: goldRevenue,
      silverRevenue: silverRevenue,
      otherRevenue: otherRevenue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.grey100,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductionKPIs(),
                    _buildCostEfficiency(),
                    _buildOperationalMetrics(),
                  ],
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColorsUnified.pureWhite,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColorsUnified.charcoal),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'KPIs Mineros',
        style: TextStyle(
          color: AppColorsUnified.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColorsUnified.charcoal),
          onPressed: _loadKPIs,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColorsUnified.companyBlue,
        unselectedLabelColor: AppColorsUnified.textSecondary,
        indicatorColor: AppColorsUnified.companyBlue,
        tabs: const [
          Tab(text: 'Producción'),
          Tab(text: 'Costos'),
          Tab(text: 'Eficiencia'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColorsUnified.error),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Error desconocido'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadKPIs,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ==================== PRODUCCIÓN ====================
  Widget _buildProductionKPIs() {
    final kpis = _kpis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de producción
          _buildProductionHeader(),
          const SizedBox(height: 16),

          // KPIs principales de producción
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  title: 'Toneladas Extraídas',
                  value: '${kpis.totalTonsExtracted.toStringAsFixed(0)}',
                  unit: 'TON',
                  icon: Icons.terrain,
                  color: AppColorsUnified.companyBlue,
                  trend: 5.2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  title: 'Producción Diaria',
                  value: '${kpis.averageDailyProduction.toStringAsFixed(1)}',
                  unit: 'TON/DÍA',
                  icon: Icons.speed,
                  color: AppColorsUnified.success,
                  trend: 3.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Producción por mineral
          _buildMineralProduction(kpis),
          const SizedBox(height: 16),

          // Gráfico de producción diaria
          _buildProductionChart(),
          const SizedBox(height: 16),

          // Ingresos por mineral
          _buildRevenueByMineral(kpis),
        ],
      ),
    );
  }

  Widget _buildProductionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.gold,
            AppColorsUnified.gold.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Indicadores de Producción',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.companyName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Mes actual',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    double? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend >= 0 
                        ? AppColorsUnified.success.withOpacity(0.1)
                        : AppColorsUnified.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: trend >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: trend >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: AppColorsUnified.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMineralProduction(MiningKPIs kpis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Producción por Mineral',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMineralRow(
            mineral: 'Oro',
            amount: kpis.goldGramsProduced,
            unit: 'gramos',
            color: AppColorsUnified.gold,
            icon: '🥇',
          ),
          const Divider(),
          _buildMineralRow(
            mineral: 'Plata',
            amount: kpis.silverGramsProduced,
            unit: 'gramos',
            color: const Color(0xFFC0C0C0),
            icon: '🥈',
          ),
        ],
      ),
    );
  }

  Widget _buildMineralRow({
    required String mineral,
    required double amount,
    required String unit,
    required Color color,
    required String icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mineral,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(2)} $unit',
                  style: TextStyle(
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${amount.toStringAsFixed(0)} g',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionChart() {
    if (_monthlyFlow.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Sin datos de producción')),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia de Ingresos (Producción)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColorsUnified.grey200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _monthlyFlow.length) {
                          return Text(
                            '${_monthlyFlow[index].date.day}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColorsUnified.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatShortCurrency(value),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsUnified.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _monthlyFlow.length,
                      (i) => FlSpot(i.toDouble(), _monthlyFlow[i].income),
                    ),
                    isCurved: true,
                    color: AppColorsUnified.gold,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColorsUnified.gold.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByMineral(MiningKPIs kpis) {
    final total = kpis.goldRevenue + kpis.silverRevenue + kpis.otherRevenue;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresos por Mineral',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (total > 0) ...[
            _buildRevenueBar('Oro', kpis.goldRevenue, total, AppColorsUnified.gold),
            const SizedBox(height: 12),
            _buildRevenueBar('Plata', kpis.silverRevenue, total, const Color(0xFFC0C0C0)),
            const SizedBox(height: 12),
            _buildRevenueBar('Otros', kpis.otherRevenue, total, AppColorsUnified.companyBlue),
          ] else
            const Center(child: Text('Sin datos de ingresos')),
        ],
      ),
    );
  }

  Widget _buildRevenueBar(String label, double amount, double total, Color color) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${FinancialCalculator.formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // ==================== COSTOS ====================
  Widget _buildCostEfficiency() {
    final kpis = _kpis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Costo por tonelada
          _buildCostPerTonCard(kpis),
          const SizedBox(height: 16),

          // Distribución de costos
          _buildCostDistribution(kpis),
          const SizedBox(height: 16),

          // Gráfico de pie de costos
          _buildCostPieChart(kpis),
          const SizedBox(height: 16),

          // Análisis de costos
          _buildCostAnalysis(kpis),
        ],
      ),
    );
  }

  Widget _buildCostPerTonCard(MiningKPIs kpis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.charcoal,
            AppColorsUnified.charcoal.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'COSTO POR TONELADA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FinancialCalculator.formatCurrency(kpis.costPerTon),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColorsUnified.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_down, color: AppColorsUnified.success, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '-2.3% vs mes anterior',
                  style: TextStyle(
                    color: AppColorsUnified.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCostMetric('Ingreso/Ton', FinancialCalculator.formatCurrency(kpis.revenuePerTon)),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildCostMetric('Margen', '${kpis.operatingMargin.toStringAsFixed(1)}%'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildCostMetric('Ganancia/Ton', FinancialCalculator.formatCurrency(kpis.revenuePerTon - kpis.costPerTon)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCostDistribution(MiningKPIs kpis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Costos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCostItem('Mano de Obra', kpis.laborCost, kpis.laborCostPercentage, AppColorsUnified.companyBlue),
          _buildCostItem('Combustible', kpis.fuelCost, kpis.fuelCostPercentage, AppColorsUnified.warning),
          _buildCostItem('Mantenimiento', kpis.maintenanceCost, kpis.maintenanceCostPercentage, AppColorsUnified.error),
          _buildCostItem('Equipos', kpis.equipmentCost, 
              _summary!.totalExpenses > 0 ? (kpis.equipmentCost / _summary!.totalExpenses * 100) : 0, 
              AppColorsUnified.success),
          _buildCostItem('Explosivos', kpis.explosivesCost,
              _summary!.totalExpenses > 0 ? (kpis.explosivesCost / _summary!.totalExpenses * 100) : 0,
              Colors.purple),
          _buildCostItem('Otros', kpis.otherCosts,
              _summary!.totalExpenses > 0 ? (kpis.otherCosts / _summary!.totalExpenses * 100) : 0,
              AppColorsUnified.grey400),
        ],
      ),
    );
  }

  Widget _buildCostItem(String label, double amount, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  FinancialCalculator.formatCurrency(amount),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostPieChart(MiningKPIs kpis) {
    final total = kpis.laborCost + kpis.fuelCost + kpis.maintenanceCost + 
                  kpis.equipmentCost + kpis.explosivesCost + kpis.otherCosts;
    
    if (total == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Sin datos de costos')),
      );
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estructura de Costos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  _buildPieSection('Mano de Obra', kpis.laborCost, total, AppColorsUnified.companyBlue),
                  _buildPieSection('Combustible', kpis.fuelCost, total, AppColorsUnified.warning),
                  _buildPieSection('Mantenimiento', kpis.maintenanceCost, total, AppColorsUnified.error),
                  _buildPieSection('Equipos', kpis.equipmentCost, total, AppColorsUnified.success),
                  _buildPieSection('Explosivos', kpis.explosivesCost, total, Colors.purple),
                  _buildPieSection('Otros', kpis.otherCosts, total, AppColorsUnified.grey400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(String label, double value, double total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 50,
      title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }

  Widget _buildCostAnalysis(MiningKPIs kpis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Costos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem(
            icon: Icons.people,
            title: 'Costo Laboral',
            value: '${kpis.laborCostPercentage.toStringAsFixed(1)}%',
            status: kpis.laborCostPercentage <= 40 ? 'Óptimo' : kpis.laborCostPercentage <= 50 ? 'Moderado' : 'Alto',
            statusColor: kpis.laborCostPercentage <= 40 
                ? AppColorsUnified.success 
                : kpis.laborCostPercentage <= 50 
                    ? AppColorsUnified.warning 
                    : AppColorsUnified.error,
          ),
          const Divider(),
          _buildAnalysisItem(
            icon: Icons.local_gas_station,
            title: 'Consumo de Combustible',
            value: '${kpis.fuelCostPercentage.toStringAsFixed(1)}%',
            status: kpis.fuelCostPercentage <= 15 ? 'Eficiente' : kpis.fuelCostPercentage <= 25 ? 'Normal' : 'Elevado',
            statusColor: kpis.fuelCostPercentage <= 15 
                ? AppColorsUnified.success 
                : kpis.fuelCostPercentage <= 25 
                    ? AppColorsUnified.warning 
                    : AppColorsUnified.error,
          ),
          const Divider(),
          _buildAnalysisItem(
            icon: Icons.build,
            title: 'Mantenimiento',
            value: '${kpis.maintenanceCostPercentage.toStringAsFixed(1)}%',
            status: kpis.maintenanceCostPercentage <= 10 ? 'Bajo' : kpis.maintenanceCostPercentage <= 15 ? 'Normal' : 'Revisar',
            statusColor: kpis.maintenanceCostPercentage <= 10 
                ? AppColorsUnified.success 
                : kpis.maintenanceCostPercentage <= 15 
                    ? AppColorsUnified.warning 
                    : AppColorsUnified.error,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String title,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColorsUnified.textSecondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EFICIENCIA ====================
  Widget _buildOperationalMetrics() {
    final kpis = _kpis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicadores de eficiencia principal
          Row(
            children: [
              Expanded(
                child: _buildEfficiencyGauge(
                  title: 'Productividad Laboral',
                  value: kpis.laborProductivity,
                  maxValue: 5,
                  unit: 'x ROI',
                  color: AppColorsUnified.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEfficiencyGauge(
                  title: 'Eficiencia Equipos',
                  value: kpis.equipmentEfficiency,
                  maxValue: 10,
                  unit: 'x ROI',
                  color: AppColorsUnified.companyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Métricas operativas
          _buildOperationalMetricsList(kpis),
          const SizedBox(height: 16),

          // Benchmarks de la industria
          _buildIndustryBenchmarks(kpis),
          const SizedBox(height: 16),

          // Recomendaciones
          _buildRecommendations(kpis),
        ],
      ),
    );
  }

  Widget _buildEfficiencyGauge({
    required String title,
    required double value,
    required double maxValue,
    required String unit,
    required Color color,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 10,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalMetricsList(MiningKPIs kpis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas Operativas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Margen Operativo', '${kpis.operatingMargin.toStringAsFixed(1)}%', 
              kpis.operatingMargin >= 20 ? AppColorsUnified.success : AppColorsUnified.warning),
          _buildMetricRow('Ingreso por Tonelada', FinancialCalculator.formatCurrency(kpis.revenuePerTon), 
              AppColorsUnified.companyBlue),
          _buildMetricRow('Costo por Tonelada', FinancialCalculator.formatCurrency(kpis.costPerTon), 
              AppColorsUnified.error),
          _buildMetricRow('Producción Diaria', '${kpis.averageDailyProduction.toStringAsFixed(1)} TON', 
              AppColorsUnified.success),
          _buildMetricRow('Productividad Laboral', '${kpis.laborProductivity.toStringAsFixed(2)}x', 
              kpis.laborProductivity >= 2 ? AppColorsUnified.success : AppColorsUnified.warning),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColorsUnified.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryBenchmarks(MiningKPIs kpis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: AppColorsUnified.companyBlue),
              const SizedBox(width: 8),
              Text(
                'Comparación con Industria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenchmarkItem('Margen Operativo', kpis.operatingMargin, 25, '%'),
          _buildBenchmarkItem('Costo por Tonelada', kpis.costPerTon, 45, '\$', invertComparison: true),
          _buildBenchmarkItem('Productividad Laboral', kpis.laborProductivity, 2.5, 'x'),
        ],
      ),
    );
  }

  Widget _buildBenchmarkItem(String label, double yourValue, double benchmarkValue, String unit, {bool invertComparison = false}) {
    final isAbove = invertComparison ? yourValue < benchmarkValue : yourValue > benchmarkValue;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Row(
                children: [
                  Icon(
                    isAbove ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isAbove ? AppColorsUnified.success : AppColorsUnified.error,
                  ),
                  Text(
                    isAbove ? 'Sobre promedio' : 'Bajo promedio',
                    style: TextStyle(
                      fontSize: 11,
                      color: isAbove ? AppColorsUnified.success : AppColorsUnified.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu empresa', style: TextStyle(fontSize: 10, color: AppColorsUnified.textSecondary)),
                    Text(
                      '${unit == '\$' ? unit : ''}${yourValue.toStringAsFixed(1)}${unit != '\$' ? unit : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Industria', style: TextStyle(fontSize: 10, color: AppColorsUnified.textSecondary)),
                    Text(
                      '${unit == '\$' ? unit : ''}${benchmarkValue.toStringAsFixed(1)}${unit != '\$' ? unit : ''}',
                      style: TextStyle(color: AppColorsUnified.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: (yourValue / (benchmarkValue * 1.5)).clamp(0.0, 1.0),
                  backgroundColor: AppColorsUnified.grey200,
                  valueColor: AlwaysStoppedAnimation(
                    isAbove ? AppColorsUnified.success : AppColorsUnified.error,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(MiningKPIs kpis) {
    final recommendations = <String>[];
    
    if (kpis.laborCostPercentage > 45) {
      recommendations.add('Optimizar costos laborales - Representan ${kpis.laborCostPercentage.toStringAsFixed(0)}% del total');
    }
    if (kpis.fuelCostPercentage > 20) {
      recommendations.add('Revisar eficiencia de combustible - Alto consumo detectado');
    }
    if (kpis.laborProductivity < 2) {
      recommendations.add('Mejorar productividad laboral - Actual ${kpis.laborProductivity.toStringAsFixed(1)}x vs 2x recomendado');
    }
    if (kpis.operatingMargin < 15) {
      recommendations.add('Incrementar margen operativo - Actual ${kpis.operatingMargin.toStringAsFixed(1)}%');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('✓ Todos los indicadores están dentro de rangos saludables');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColorsUnified.warning),
              const SizedBox(width: 8),
              Text(
                'Recomendaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  rec.startsWith('✓') ? Icons.check_circle : Icons.info,
                  size: 18,
                  color: rec.startsWith('✓') ? AppColorsUnified.success : AppColorsUnified.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  String _formatShortCurrency(double value) {
    if (value.abs() >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }
}

/// Clase para almacenar KPIs mineros
class MiningKPIs {
  // Producción
  final double totalTonsExtracted;
  final double goldGramsProduced;
  final double silverGramsProduced;
  final double averageDailyProduction;
  
  // Costos
  final double costPerTon;
  final double laborCostPercentage;
  final double fuelCostPercentage;
  final double maintenanceCostPercentage;
  
  // Eficiencia
  final double operatingMargin;
  final double revenuePerTon;
  final double laborProductivity;
  final double equipmentEfficiency;
  
  // Detalles de costos
  final double laborCost;
  final double equipmentCost;
  final double fuelCost;
  final double explosivesCost;
  final double maintenanceCost;
  final double otherCosts;
  
  // Ingresos
  final double goldRevenue;
  final double silverRevenue;
  final double otherRevenue;

  MiningKPIs({
    required this.totalTonsExtracted,
    required this.goldGramsProduced,
    required this.silverGramsProduced,
    required this.averageDailyProduction,
    required this.costPerTon,
    required this.laborCostPercentage,
    required this.fuelCostPercentage,
    required this.maintenanceCostPercentage,
    required this.operatingMargin,
    required this.revenuePerTon,
    required this.laborProductivity,
    required this.equipmentEfficiency,
    required this.laborCost,
    required this.equipmentCost,
    required this.fuelCost,
    required this.explosivesCost,
    required this.maintenanceCost,
    required this.otherCosts,
    required this.goldRevenue,
    required this.silverRevenue,
    required this.otherRevenue,
  });
}
