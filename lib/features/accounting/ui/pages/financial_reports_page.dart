import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/financial_entry.dart';
import '../../models/financial_metrics.dart';
import '../../data/accounting_repository.dart';
import '../../data/financial_calculator.dart';

/// Página de reportes financieros
class FinancialReportsPage extends StatefulWidget {
  final String companyId;
  final String companyName;

  const FinancialReportsPage({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<FinancialReportsPage> createState() => _FinancialReportsPageState();
}

class _FinancialReportsPageState extends State<FinancialReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = AccountingRepository();

  bool _isLoading = true;
  String? _errorMessage;

  // Datos para reportes
  FinancialSummary? _dailySummary;
  FinancialSummary? _weeklySummary;
  FinancialSummary? _monthlySummary;
  List<DailyCashFlow> _weeklyFlow = [];
  List<DailyCashFlow> _monthlyFlow = [];
  List<CategoryBreakdown> _incomeBreakdown = [];
  List<CategoryBreakdown> _expenseBreakdown = [];
  List<FinancialEntry> _todayEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Cargar datos en paralelo
      final results = await Future.wait([
        // Resumen diario
        _repository.getSummary(
          widget.companyId,
          startDate: today,
          endDate: now,
        ),
        // Resumen semanal
        _repository.getSummary(
          widget.companyId,
          startDate: startOfWeek,
          endDate: now,
        ),
        // Resumen mensual
        _repository.getSummary(
          widget.companyId,
          startDate: startOfMonth,
          endDate: now,
        ),
        // Flujo semanal
        _repository.getDailyCashFlow(widget.companyId, days: 7),
        // Flujo mensual
        _repository.getDailyCashFlow(widget.companyId, days: 30),
        // Desglose ingresos del mes
        _repository.getCategoryBreakdown(
          widget.companyId,
          startDate: startOfMonth,
          endDate: now,
          type: EntryType.income,
        ),
        // Desglose gastos del mes
        _repository.getCategoryBreakdown(
          widget.companyId,
          startDate: startOfMonth,
          endDate: now,
          type: EntryType.expense,
        ),
        // Transacciones de hoy
        _repository.getEntries(
          widget.companyId,
          startDate: today,
          endDate: now,
        ),
      ]);

      setState(() {
        _dailySummary = results[0] as FinancialSummary;
        _weeklySummary = results[1] as FinancialSummary;
        _monthlySummary = results[2] as FinancialSummary;
        _weeklyFlow = results[3] as List<DailyCashFlow>;
        _monthlyFlow = results[4] as List<DailyCashFlow>;
        _incomeBreakdown = results[5] as List<CategoryBreakdown>;
        _expenseBreakdown = results[6] as List<CategoryBreakdown>;
        _todayEntries = results[7] as List<FinancialEntry>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar reportes: $e';
        _isLoading = false;
      });
    }
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
                    _buildDailyReport(),
                    _buildWeeklyReport(),
                    _buildMonthlyReport(),
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
        'Reportes Financieros',
        style: TextStyle(
          color: AppColorsUnified.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColorsUnified.charcoal),
          onPressed: _loadReportData,
        ),
        IconButton(
          icon: Icon(Icons.share, color: AppColorsUnified.charcoal),
          onPressed: _shareReport,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColorsUnified.companyBlue,
        unselectedLabelColor: AppColorsUnified.textSecondary,
        indicatorColor: AppColorsUnified.companyBlue,
        tabs: const [
          Tab(text: 'Diario'),
          Tab(text: 'Semanal'),
          Tab(text: 'Mensual'),
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
            onPressed: _loadReportData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ==================== REPORTE DIARIO ====================
  Widget _buildDailyReport() {
    return RefreshIndicator(
      onRefresh: _loadReportData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha del reporte
            _buildReportHeader(
              title: 'Reporte del Día',
              date: DateTime.now(),
              icon: Icons.today,
            ),
            const SizedBox(height: 16),

            // Resumen rápido
            _buildDailySummaryCard(),
            const SizedBox(height: 16),

            // Transacciones del día
            _buildDayTransactionsSection(),
            const SizedBox(height: 16),

            // Comparativa con ayer
            _buildDailyComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader({
    required String title,
    required DateTime date,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.companyBlue,
            AppColorsUnified.companyBlue.withOpacity(0.8),
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
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatFullDate(date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.companyName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
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

  Widget _buildDailySummaryCard() {
    final summary = _dailySummary ?? FinancialSummary.empty();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Ingresos',
                  value: FinancialCalculator.formatCurrency(summary.totalIncome),
                  color: AppColorsUnified.success,
                  icon: Icons.arrow_downward,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColorsUnified.grey200,
              ),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Gastos',
                  value: FinancialCalculator.formatCurrency(summary.totalExpenses),
                  color: AppColorsUnified.error,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Balance del Día',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                FinancialCalculator.formatCurrency(summary.netProfit),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: summary.netProfit >= 0 
                      ? AppColorsUnified.success 
                      : AppColorsUnified.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: summary.totalIncome > 0 
                ? (summary.totalExpenses / summary.totalIncome).clamp(0.0, 1.0)
                : 0,
            backgroundColor: AppColorsUnified.success.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(AppColorsUnified.error),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            'Gastos: ${summary.totalIncome > 0 ? ((summary.totalExpenses / summary.totalIncome) * 100).toStringAsFixed(1) : '0'}% de ingresos',
            style: TextStyle(
              fontSize: 11,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColorsUnified.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDayTransactionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transacciones de Hoy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
              Text(
                '${_todayEntries.length} movimientos',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_todayEntries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColorsUnified.grey300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin transacciones hoy',
                      style: TextStyle(color: AppColorsUnified.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(
              _todayEntries.length.clamp(0, 5),
              (index) => _buildTransactionRow(_todayEntries[index]),
            ),
          if (_todayEntries.length > 5)
            TextButton(
              onPressed: () {},
              child: Text('Ver ${_todayEntries.length - 5} más...'),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(FinancialEntry entry) {
    final isIncome = entry.type == EntryType.income;
    final color = isIncome ? AppColorsUnified.success : AppColorsUnified.error;
    final sign = isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  entry.categoryDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${FinancialCalculator.formatCurrency(entry.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyComparison() {
    final today = _dailySummary ?? FinancialSummary.empty();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparación con Ayer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            label: 'Ingresos',
            change: today.incomeChange,
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            label: 'Gastos',
            change: today.expenseChange,
            invertColors: true,
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            label: 'Ganancia',
            change: today.profitChange,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required double change,
    bool invertColors = false,
  }) {
    final isPositive = change >= 0;
    Color color;
    if (invertColors) {
      color = isPositive ? AppColorsUnified.error : AppColorsUnified.success;
    } else {
      color = isPositive ? AppColorsUnified.success : AppColorsUnified.error;
    }
    
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ),
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ==================== REPORTE SEMANAL ====================
  Widget _buildWeeklyReport() {
    return RefreshIndicator(
      onRefresh: _loadReportData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildReportHeader(
              title: 'Reporte Semanal',
              date: DateTime.now(),
              icon: Icons.date_range,
            ),
            const SizedBox(height: 16),

            // Resumen semanal
            _buildWeeklySummaryCards(),
            const SizedBox(height: 16),

            // Gráfico de flujo semanal
            _buildWeeklyChart(),
            const SizedBox(height: 16),

            // Top categorías
            _buildWeeklyTopCategories(),
            const SizedBox(height: 16),

            // Indicadores de rendimiento
            _buildWeeklyKPIs(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCards() {
    final summary = _weeklySummary ?? FinancialSummary.empty();
    
    return Row(
      children: [
        Expanded(
          child: _buildMiniSummaryCard(
            label: 'Ingresos',
            value: FinancialCalculator.formatCurrency(summary.totalIncome),
            icon: Icons.arrow_downward,
            color: AppColorsUnified.success,
            change: summary.incomeChange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniSummaryCard(
            label: 'Gastos',
            value: FinancialCalculator.formatCurrency(summary.totalExpenses),
            icon: Icons.arrow_upward,
            color: AppColorsUnified.error,
            change: summary.expenseChange,
            invertChangeColor: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double change,
    bool invertChangeColor = false,
  }) {
    final isPositive = change >= 0;
    Color changeColor;
    if (invertChangeColor) {
      changeColor = isPositive ? AppColorsUnified.error : AppColorsUnified.success;
    } else {
      changeColor = isPositive ? AppColorsUnified.success : AppColorsUnified.error;
    }
    
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
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppColorsUnified.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: changeColor,
              ),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' vs semana ant.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (_weeklyFlow.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Sin datos')),
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
            'Flujo de Efectivo Semanal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(_weeklyFlow),
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
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _weeklyFlow.length) {
                          final day = _weeklyFlow[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getDayShort(day.weekday),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColorsUnified.textSecondary,
                              ),
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
                barGroups: List.generate(_weeklyFlow.length, (index) {
                  final data = _weeklyFlow[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.income,
                        color: AppColorsUnified.success,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: data.expense,
                        color: AppColorsUnified.error,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Ingresos', AppColorsUnified.success),
              const SizedBox(width: 24),
              _buildLegendItem('Gastos', AppColorsUnified.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTopCategories() {
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
            'Top Categorías de la Semana',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Top 3 ingresos
          Text(
            'Mayores Ingresos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.success,
            ),
          ),
          const SizedBox(height: 8),
          if (_incomeBreakdown.isEmpty)
            Text(
              'Sin datos',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            )
          else
            ...List.generate(
              _incomeBreakdown.length.clamp(0, 3),
              (index) => _buildCategoryBar(_incomeBreakdown[index], AppColorsUnified.success),
            ),
          
          const SizedBox(height: 16),
          
          // Top 3 gastos
          Text(
            'Mayores Gastos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.error,
            ),
          ),
          const SizedBox(height: 8),
          if (_expenseBreakdown.isEmpty)
            Text(
              'Sin datos',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            )
          else
            ...List.generate(
              _expenseBreakdown.length.clamp(0, 3),
              (index) => _buildCategoryBar(_expenseBreakdown[index], AppColorsUnified.error),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(CategoryBreakdown category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category.categoryName,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                FinancialCalculator.formatCurrency(category.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: category.percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyKPIs() {
    final summary = _weeklySummary ?? FinancialSummary.empty();
    
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
            'Indicadores Clave',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKPIItem(
                  label: 'Margen de Ganancia',
                  value: '${summary.profitMargin.toStringAsFixed(1)}%',
                  icon: Icons.show_chart,
                  color: summary.profitMargin >= 20 
                      ? AppColorsUnified.success 
                      : AppColorsUnified.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPIItem(
                  label: 'Transacciones',
                  value: '${summary.transactionCount}',
                  icon: Icons.receipt_long,
                  color: AppColorsUnified.companyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKPIItem(
                  label: 'Ingreso Promedio',
                  value: summary.transactionCount > 0 
                      ? FinancialCalculator.formatCurrency(summary.totalIncome / (summary.transactionCount > 0 ? summary.transactionCount : 1))
                      : '\$0',
                  icon: Icons.trending_up,
                  color: AppColorsUnified.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPIItem(
                  label: 'Ratio Gasto/Ingreso',
                  value: summary.totalIncome > 0 
                      ? '${((summary.totalExpenses / summary.totalIncome) * 100).toStringAsFixed(0)}%'
                      : '0%',
                  icon: Icons.pie_chart,
                  color: summary.totalExpenses < summary.totalIncome 
                      ? AppColorsUnified.success 
                      : AppColorsUnified.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REPORTE MENSUAL ====================
  Widget _buildMonthlyReport() {
    return RefreshIndicator(
      onRefresh: _loadReportData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildReportHeader(
              title: 'Reporte Mensual',
              date: DateTime.now(),
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 16),

            // Resumen principal
            _buildMonthlySummary(),
            const SizedBox(height: 16),

            // Gráfico de tendencias
            _buildMonthlyTrendChart(),
            const SizedBox(height: 16),

            // Desglose por categorías
            _buildMonthlyCategoryBreakdown(),
            const SizedBox(height: 16),

            // Estado de resultados simplificado
            _buildSimpleIncomeStatement(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    final summary = _monthlySummary ?? FinancialSummary.empty();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Balance neto grande
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: summary.netProfit >= 0
                    ? [AppColorsUnified.success.withOpacity(0.1), AppColorsUnified.success.withOpacity(0.05)]
                    : [AppColorsUnified.error.withOpacity(0.1), AppColorsUnified.error.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Balance Neto del Mes',
                  style: TextStyle(
                    color: AppColorsUnified.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FinancialCalculator.formatCurrency(summary.netProfit),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: summary.netProfit >= 0 
                        ? AppColorsUnified.success 
                        : AppColorsUnified.error,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      summary.profitChange >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: summary.profitChange >= 0 
                          ? AppColorsUnified.success 
                          : AppColorsUnified.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.profitChange >= 0 ? '+' : ''}${summary.profitChange.toStringAsFixed(1)}% vs mes anterior',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Total Ingresos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FinancialCalculator.formatCurrency(summary.totalIncome),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.success,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColorsUnified.grey200,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Total Gastos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FinancialCalculator.formatCurrency(summary.totalExpenses),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColorsUnified.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart() {
    if (_monthlyFlow.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Sin datos')),
      );
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia del Mes',
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
                  horizontalInterval: _calculateIntervalForLine(_monthlyFlow),
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
                          final day = _monthlyFlow[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColorsUnified.textSecondary,
                              ),
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
                      reservedSize: 45,
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
                  // Balance acumulado
                  LineChartBarData(
                    spots: List.generate(
                      _monthlyFlow.length,
                      (index) => FlSpot(index.toDouble(), _monthlyFlow[index].balance),
                    ),
                    isCurved: true,
                    color: AppColorsUnified.companyBlue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColorsUnified.companyBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Balance acumulado del mes',
              style: TextStyle(
                fontSize: 11,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCategoryBreakdown() {
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
            'Distribución por Categorías',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Ingresos
          if (_incomeBreakdown.isNotEmpty) ...[
            _buildCategorySection(
              title: 'Ingresos',
              breakdown: _incomeBreakdown,
              color: AppColorsUnified.success,
            ),
            const SizedBox(height: 16),
          ],
          
          // Gastos
          if (_expenseBreakdown.isNotEmpty)
            _buildCategorySection(
              title: 'Gastos',
              breakdown: _expenseBreakdown,
              color: AppColorsUnified.error,
            ),
            
          if (_incomeBreakdown.isEmpty && _expenseBreakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sin datos de categorías',
                  style: TextStyle(color: AppColorsUnified.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required List<CategoryBreakdown> breakdown,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...breakdown.take(5).map((cat) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color.withOpacity(1 - (breakdown.indexOf(cat) * 0.15)),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat.categoryName,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                '${cat.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FinancialCalculator.formatCurrency(cat.amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )),
        if (breakdown.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${breakdown.length - 5} categorías más',
              style: TextStyle(
                fontSize: 12,
                color: AppColorsUnified.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSimpleIncomeStatement() {
    final summary = _monthlySummary ?? FinancialSummary.empty();
    
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
            'Estado de Resultados Simplificado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatementRow('Ingresos Totales', summary.totalIncome, isBold: true),
          const Divider(),
          _buildStatementRow('(-) Gastos Operacionales', summary.totalExpenses, isNegative: true),
          const Divider(height: 24, thickness: 2),
          _buildStatementRow(
            'Utilidad Neta',
            summary.netProfit,
            isBold: true,
            color: summary.netProfit >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
          ),
          const SizedBox(height: 8),
          _buildStatementRow(
            'Margen de Ganancia',
            summary.profitMargin,
            suffix: '%',
            color: summary.profitMargin >= 20 ? AppColorsUnified.success : AppColorsUnified.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildStatementRow(
    String label,
    double value, {
    bool isBold = false,
    bool isNegative = false,
    String suffix = '',
    Color? color,
  }) {
    final displayValue = suffix == '%' 
        ? value.toStringAsFixed(1) + suffix
        : FinancialCalculator.formatCurrency(value);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? AppColorsUnified.error : null,
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isNegative ? AppColorsUnified.error : null),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  String _formatFullDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} ${date.year}';
  }

  String _getDayShort(int weekday) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  double _calculateInterval(List<DailyCashFlow> data) {
    if (data.isEmpty) return 1000;
    final maxValue = data.map((d) => d.income > d.expense ? d.income : d.expense).reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return 1000;
    return (maxValue / 4).ceilToDouble();
  }

  double _calculateIntervalForLine(List<DailyCashFlow> data) {
    if (data.isEmpty) return 1000;
    final values = data.map((d) => d.balance.abs()).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return 1000;
    return (maxValue / 4).ceilToDouble();
  }

  void _shareReport() {
    // TODO: Implementar compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartir reporte próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
