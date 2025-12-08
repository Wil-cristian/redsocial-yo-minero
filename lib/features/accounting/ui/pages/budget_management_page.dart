import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors_unified.dart';

class BudgetManagementPage extends StatefulWidget {
  final String odooMineId;

  const BudgetManagementPage({
    super.key,
    required this.odooMineId,
  });

  @override
  State<BudgetManagementPage> createState() => _BudgetManagementPageState();
}

class _BudgetManagementPageState extends State<BudgetManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  bool _isLoading = true;
  List<Budget> _budgets = [];
  BudgetSummary? _summary;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    
    _budgets = _generateSampleBudgets();
    _calculateSummary();
    
    setState(() => _isLoading = false);
  }

  void _calculateSummary() {
    double totalBudgeted = 0;
    double totalSpent = 0;
    int alertCount = 0;

    for (var budget in _budgets) {
      totalBudgeted += budget.budgetedAmount;
      totalSpent += budget.spentAmount;
      if (budget.usagePercentage > 80) alertCount++;
    }

    _summary = BudgetSummary(
      totalBudgeted: totalBudgeted,
      totalSpent: totalSpent,
      alertCount: alertCount,
    );
  }

  List<Budget> _generateSampleBudgets() {
    return [
      // Presupuestos operativos
      Budget(
        id: '1',
        name: 'Explosivos y Voladura',
        category: 'Operaciones',
        budgetedAmount: 500000,
        spentAmount: 425000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '2',
        name: 'Combustibles',
        category: 'Operaciones',
        budgetedAmount: 300000,
        spentAmount: 285000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '3',
        name: 'Mantenimiento Maquinaria',
        category: 'Operaciones',
        budgetedAmount: 400000,
        spentAmount: 180000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '4',
        name: 'Equipos de Seguridad',
        category: 'Seguridad',
        budgetedAmount: 150000,
        spentAmount: 75000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '5',
        name: 'Nómina Operadores',
        category: 'Personal',
        budgetedAmount: 800000,
        spentAmount: 780000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '6',
        name: 'Capacitación',
        category: 'Personal',
        budgetedAmount: 100000,
        spentAmount: 45000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '7',
        name: 'Servicios Públicos',
        category: 'Administración',
        budgetedAmount: 120000,
        spentAmount: 118000,
        period: BudgetPeriod.monthly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      Budget(
        id: '8',
        name: 'Permisos y Licencias',
        category: 'Legal',
        budgetedAmount: 200000,
        spentAmount: 50000,
        period: BudgetPeriod.quarterly,
        year: _selectedYear,
        month: _selectedMonth,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.backgroundDark,
        title: const Text(
          'Gestión de Presupuestos',
          style: TextStyle(color: AppColorsUnified.gold),
        ),
        iconTheme: const IconThemeData(color: AppColorsUnified.gold),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColorsUnified.gold,
          labelColor: AppColorsUnified.gold,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.list_alt), text: 'Detalle'),
            Tab(icon: Icon(Icons.compare_arrows), text: 'Comparativo'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showPeriodSelector,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBudgetDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColorsUnified.gold),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildDetailTab(),
                _buildComparativeTab(),
              ],
            ),
    );
  }

  Widget _buildSummaryTab() {
    if (_summary == null) {
      return const Center(child: Text('No hay datos'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Período actual
          _buildPeriodHeader(),
          const SizedBox(height: 16),
          
          // Tarjeta principal de resumen
          _buildMainSummaryCard(),
          const SizedBox(height: 16),
          
          // Alertas
          if (_summary!.alertCount > 0) _buildAlertsCard(),
          const SizedBox(height: 16),
          
          // Gráfico de distribución
          _buildDistributionChart(),
          const SizedBox(height: 16),
          
          // Top consumos
          _buildTopConsumption(),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader() {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColorsUnified.gold),
            onPressed: () {
              setState(() {
                if (_selectedMonth == 1) {
                  _selectedMonth = 12;
                  _selectedYear--;
                } else {
                  _selectedMonth--;
                }
              });
              _loadData();
            },
          ),
          Text(
            '${monthNames[_selectedMonth - 1]} $_selectedYear',
            style: const TextStyle(
              color: AppColorsUnified.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColorsUnified.gold),
            onPressed: () {
              setState(() {
                if (_selectedMonth == 12) {
                  _selectedMonth = 1;
                  _selectedYear++;
                } else {
                  _selectedMonth++;
                }
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainSummaryCard() {
    final percentage = _summary!.usagePercentage;
    final remaining = _summary!.remainingAmount;
    
    Color progressColor;
    if (percentage < 60) {
      progressColor = Colors.green;
    } else if (percentage < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.backgroundDark,
            AppColorsUnified.backgroundDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Presupuesto Total',
                    style: TextStyle(color: AppColorsUnified.textSecondary),
                  ),
                  Text(
                    _currencyFormat.format(_summary!.totalBudgeted),
                    style: const TextStyle(
                      color: AppColorsUnified.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: AppColorsUnified.backgroundDark,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Ejecutado', _summary!.totalSpent, Colors.blue),
              _buildSummaryItem('Disponible', remaining, remaining >= 0 ? Colors.green : Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
        ),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsCard() {
    final alertBudgets = _budgets.where((b) => b.usagePercentage > 80).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                '${alertBudgets.length} presupuestos en alerta',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alertBudgets.map((budget) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budget.name,
                      style: const TextStyle(color: AppColorsUnified.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: budget.usagePercentage > 95
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${budget.usagePercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: budget.usagePercentage > 95 ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDistributionChart() {
    // Agrupar por categoría
    final categoryTotals = <String, double>{};
    for (var budget in _budgets) {
      categoryTotals[budget.category] = (categoryTotals[budget.category] ?? 0) + budget.budgetedAmount;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución por Categoría',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categoryTotals.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final total = categoryTotals.values.reduce((a, b) => a + b);
                        final percentage = (category.value / total) * 100;
                        
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: category.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryTotals.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.key,
                            style: const TextStyle(
                              color: AppColorsUnified.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopConsumption() {
    final sorted = List<Budget>.from(_budgets)
      ..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Consumos del Mes',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((budget) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            budget.name,
                            style: const TextStyle(color: AppColorsUnified.textPrimary),
                          ),
                        ),
                        Text(
                          _currencyFormat.format(budget.spentAmount),
                          style: const TextStyle(
                            color: AppColorsUnified.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: budget.usagePercentage / 100,
                      backgroundColor: AppColorsUnified.backgroundDark,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.usagePercentage > 80 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailTab() {
    // Agrupar por categoría
    final grouped = <String, List<Budget>>{};
    for (var budget in _budgets) {
      grouped.putIfAbsent(budget.category, () => []).add(budget);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  color: AppColorsUnified.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...entry.value.map((budget) => _buildBudgetCard(budget)),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    Color progressColor;
    if (budget.usagePercentage < 60) {
      progressColor = Colors.green;
    } else if (budget.usagePercentage < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Card(
      color: AppColorsUnified.backgroundDark,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBudgetDetails(budget),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      style: const TextStyle(
                        color: AppColorsUnified.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${budget.usagePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Presupuestado: ${_currencyFormat.format(budget.budgetedAmount)}',
                    style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                  ),
                  Text(
                    'Gastado: ${_currencyFormat.format(budget.spentAmount)}',
                    style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: budget.usagePercentage / 100,
                  minHeight: 8,
                  backgroundColor: AppColorsUnified.backgroundDark,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disponible: ${_currencyFormat.format(budget.remainingAmount)}',
                    style: TextStyle(
                      color: budget.remainingAmount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    budget.periodText,
                    style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparativeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparativo Mensual',
            style: TextStyle(
              color: AppColorsUnified.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthlyComparisonChart(),
          const SizedBox(height: 24),
          const Text(
            'Variación vs Mes Anterior',
            style: TextStyle(
              color: AppColorsUnified.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildVariationList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparisonChart() {
    // Datos simulados de los últimos 6 meses
    final months = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final budgeted = [2400000.0, 2450000.0, 2500000.0, 2550000.0, 2600000.0, 2570000.0];
    final spent = [2200000.0, 2380000.0, 2350000.0, 2480000.0, 2420000.0, 1958000.0];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 3000000,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        months[value.toInt()],
                        style: const TextStyle(
                          color: AppColorsUnified.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: const TextStyle(
                      color: AppColorsUnified.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColorsUnified.textSecondary.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: budgeted[index],
                  color: AppColorsUnified.gold.withValues(alpha: 0.5),
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: spent[index],
                  color: Colors.blue,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildVariationList() {
    // Simulación de variaciones
    final variations = [
      {'name': 'Explosivos y Voladura', 'variation': 5.2},
      {'name': 'Combustibles', 'variation': -3.8},
      {'name': 'Mantenimiento Maquinaria', 'variation': 12.5},
      {'name': 'Nómina Operadores', 'variation': 2.1},
      {'name': 'Servicios Públicos', 'variation': -8.4},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: variations.map((item) {
          final variation = item['variation'] as double;
          final isPositive = variation > 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['name'] as String,
                    style: const TextStyle(color: AppColorsUnified.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.red : Colors.green).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Año',
              style: TextStyle(
                color: AppColorsUnified.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [2023, 2024, 2025].map((year) {
                return ChoiceChip(
                  label: Text('$year'),
                  selected: _selectedYear == year,
                  onSelected: (_) {
                    setState(() => _selectedYear = year);
                    Navigator.pop(context);
                    _loadData();
                  },
                  selectedColor: AppColorsUnified.gold.withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                    color: _selectedYear == year
                        ? AppColorsUnified.gold
                        : AppColorsUnified.textSecondary,
                  ),
                  backgroundColor: AppColorsUnified.backgroundDark,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDetails(Budget budget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.name,
              style: const TextStyle(
                color: AppColorsUnified.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Categoría: ${budget.category}',
              style: const TextStyle(color: AppColorsUnified.textSecondary),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Presupuestado', _currencyFormat.format(budget.budgetedAmount)),
            _buildDetailRow('Ejecutado', _currencyFormat.format(budget.spentAmount)),
            _buildDetailRow('Disponible', _currencyFormat.format(budget.remainingAmount),
                budget.remainingAmount >= 0 ? Colors.green : Colors.red),
            _buildDetailRow('Ejecución', '${budget.usagePercentage.toStringAsFixed(1)}%'),
            _buildDetailRow('Período', budget.periodText),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Editar presupuesto
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColorsUnified.gold,
                      side: const BorderSide(color: AppColorsUnified.gold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Ver transacciones
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Ver Gastos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.gold,
                      foregroundColor: Colors.black,
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

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColorsUnified.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColorsUnified.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Operaciones';
    BudgetPeriod selectedPeriod = BudgetPeriod.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColorsUnified.backgroundDark,
          title: const Text(
            'Nuevo Presupuesto',
            style: TextStyle(color: AppColorsUnified.gold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nombre del presupuesto',
                    labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Monto presupuestado',
                    labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(color: AppColorsUnified.gold),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: AppColorsUnified.backgroundDark,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.gold),
                    ),
                  ),
                  items: ['Operaciones', 'Personal', 'Seguridad', 'Administración', 'Legal', 'Otros']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BudgetPeriod>(
                  value: selectedPeriod,
                  dropdownColor: AppColorsUnified.backgroundDark,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Período',
                    labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.gold),
                    ),
                  ),
                  items: BudgetPeriod.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p == BudgetPeriod.monthly
                                ? 'Mensual'
                                : p == BudgetPeriod.quarterly
                                    ? 'Trimestral'
                                    : 'Anual'),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedPeriod = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColorsUnified.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Guardar presupuesto
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Presupuesto creado'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsUnified.gold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Modelos
enum BudgetPeriod { monthly, quarterly, annual }

class Budget {
  final String id;
  final String name;
  final String category;
  final double budgetedAmount;
  final double spentAmount;
  final BudgetPeriod period;
  final int year;
  final int month;

  Budget({
    required this.id,
    required this.name,
    required this.category,
    required this.budgetedAmount,
    required this.spentAmount,
    required this.period,
    required this.year,
    required this.month,
  });

  double get remainingAmount => budgetedAmount - spentAmount;
  double get usagePercentage => budgetedAmount > 0 ? (spentAmount / budgetedAmount) * 100 : 0;

  String get periodText {
    switch (period) {
      case BudgetPeriod.monthly:
        return 'Mensual';
      case BudgetPeriod.quarterly:
        return 'Trimestral';
      case BudgetPeriod.annual:
        return 'Anual';
    }
  }
}

class BudgetSummary {
  final double totalBudgeted;
  final double totalSpent;
  final int alertCount;

  BudgetSummary({
    required this.totalBudgeted,
    required this.totalSpent,
    required this.alertCount,
  });

  double get remainingAmount => totalBudgeted - totalSpent;
  double get usagePercentage => totalBudgeted > 0 ? (totalSpent / totalBudgeted) * 100 : 0;
}
