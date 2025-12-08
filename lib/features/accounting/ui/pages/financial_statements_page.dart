import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/financial_entry.dart';
import '../../models/financial_metrics.dart';
import '../../data/accounting_repository.dart';
import '../../data/financial_calculator.dart';

/// Página de Estados Financieros completos
class FinancialStatementsPage extends StatefulWidget {
  final String companyId;
  final String companyName;

  const FinancialStatementsPage({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<FinancialStatementsPage> createState() => _FinancialStatementsPageState();
}

class _FinancialStatementsPageState extends State<FinancialStatementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = AccountingRepository();

  bool _isLoading = true;
  String? _errorMessage;
  
  // Período seleccionado
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  // Datos financieros
  FinancialSummary? _currentPeriod;
  FinancialSummary? _previousPeriod;
  List<CategoryBreakdown> _incomeBreakdown = [];
  List<CategoryBreakdown> _expenseBreakdown = [];
  
  // Para Balance General (simulado)
  double _totalAssets = 0;
  double _totalLiabilities = 0;
  double _totalEquity = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Calcular período anterior
      final periodDuration = _endDate.difference(_startDate);
      final prevStartDate = _startDate.subtract(periodDuration);
      final prevEndDate = _startDate.subtract(const Duration(days: 1));

      final results = await Future.wait([
        _repository.getSummary(
          widget.companyId,
          startDate: _startDate,
          endDate: _endDate,
        ),
        _repository.getSummary(
          widget.companyId,
          startDate: prevStartDate,
          endDate: prevEndDate,
        ),
        _repository.getCategoryBreakdown(
          widget.companyId,
          startDate: _startDate,
          endDate: _endDate,
          type: EntryType.income,
        ),
        _repository.getCategoryBreakdown(
          widget.companyId,
          startDate: _startDate,
          endDate: _endDate,
          type: EntryType.expense,
        ),
      ]);

      setState(() {
        _currentPeriod = results[0] as FinancialSummary;
        _previousPeriod = results[1] as FinancialSummary;
        _incomeBreakdown = results[2] as List<CategoryBreakdown>;
        _expenseBreakdown = results[3] as List<CategoryBreakdown>;
        
        // Calcular balance general simulado
        _calculateBalanceSheet();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estados financieros: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateBalanceSheet() {
    final summary = _currentPeriod ?? FinancialSummary.empty();
    
    // Simulación de Balance General basado en transacciones
    // En una implementación real, esto vendría de cuentas contables específicas
    _totalAssets = summary.totalIncome * 0.7; // Activos corrientes (efectivo + cuentas por cobrar)
    _totalLiabilities = summary.totalExpenses * 0.3; // Pasivos estimados
    _totalEquity = _totalAssets - _totalLiabilities; // Patrimonio
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
              : Column(
                  children: [
                    _buildPeriodSelector(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildIncomeStatement(),
                          _buildBalanceSheet(),
                          _buildCashFlowStatement(),
                        ],
                      ),
                    ),
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
        'Estados Financieros',
        style: TextStyle(
          color: AppColorsUnified.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.print, color: AppColorsUnified.charcoal),
          onPressed: _printStatement,
        ),
        IconButton(
          icon: Icon(Icons.share, color: AppColorsUnified.charcoal),
          onPressed: _shareStatement,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColorsUnified.companyBlue,
        unselectedLabelColor: AppColorsUnified.textSecondary,
        indicatorColor: AppColorsUnified.companyBlue,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Estado de\nResultados'),
          Tab(text: 'Balance\nGeneral'),
          Tab(text: 'Flujo de\nEfectivo'),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      color: AppColorsUnified.pureWhite,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDateRange(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColorsUnified.grey200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, 
                        size: 18, 
                        color: AppColorsUnified.companyBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, 
                        color: AppColorsUnified.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildQuickPeriodButton('Mes', () {
            final now = DateTime.now();
            setState(() {
              _startDate = DateTime(now.year, now.month, 1);
              _endDate = now;
            });
            _loadStatements();
          }),
          const SizedBox(width: 8),
          _buildQuickPeriodButton('Trimestre', () {
            final now = DateTime.now();
            setState(() {
              _startDate = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
              _endDate = now;
            });
            _loadStatements();
          }),
          const SizedBox(width: 8),
          _buildQuickPeriodButton('Año', () {
            final now = DateTime.now();
            setState(() {
              _startDate = DateTime(now.year, 1, 1);
              _endDate = now;
            });
            _loadStatements();
          }),
        ],
      ),
    );
  }

  Widget _buildQuickPeriodButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColorsUnified.companyBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColorsUnified.companyBlue,
          ),
        ),
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
            onPressed: _loadStatements,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ==================== ESTADO DE RESULTADOS ====================
  Widget _buildIncomeStatement() {
    final current = _currentPeriod ?? FinancialSummary.empty();
    final previous = _previousPeriod ?? FinancialSummary.empty();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del estado
          _buildStatementHeader(
            title: 'Estado de Resultados',
            subtitle: 'Período: ${_formatDate(_startDate)} al ${_formatDate(_endDate)}',
          ),
          const SizedBox(height: 16),

          // Sección de Ingresos
          _buildStatementSection(
            title: 'INGRESOS',
            items: [
              ..._incomeBreakdown.map((cat) => StatementItem(
                label: cat.categoryName,
                current: cat.amount,
                previous: _getPreviousCategoryAmount(cat.category, true),
              )),
            ],
            total: StatementItem(
              label: 'Total Ingresos',
              current: current.totalIncome,
              previous: previous.totalIncome,
              isBold: true,
            ),
            color: AppColorsUnified.success,
          ),
          const SizedBox(height: 16),

          // Sección de Gastos
          _buildStatementSection(
            title: 'GASTOS OPERACIONALES',
            items: [
              ..._expenseBreakdown.take(10).map((cat) => StatementItem(
                label: cat.categoryName,
                current: cat.amount,
                previous: _getPreviousCategoryAmount(cat.category, false),
              )),
              if (_expenseBreakdown.length > 10)
                StatementItem(
                  label: 'Otros gastos (${_expenseBreakdown.length - 10} categorías)',
                  current: _expenseBreakdown.skip(10).fold(0.0, (sum, cat) => sum + cat.amount),
                  previous: 0,
                ),
            ],
            total: StatementItem(
              label: 'Total Gastos',
              current: current.totalExpenses,
              previous: previous.totalExpenses,
              isBold: true,
            ),
            color: AppColorsUnified.error,
          ),
          const SizedBox(height: 16),

          // Utilidad
          _buildResultSection(current, previous),
          const SizedBox(height: 24),

          // Análisis comparativo
          _buildComparativeAnalysis(current, previous),
        ],
      ),
    );
  }

  Widget _buildStatementHeader({
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.charcoal,
            AppColorsUnified.charcoal.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.companyName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementSection({
    required String title,
    required List<StatementItem> items,
    required StatementItem total,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  'Actual',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(width: 40),
                Text(
                  'Anterior',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.map((item) => _buildStatementRow(item)),
          // Total
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: _buildStatementTotalRow(total, color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementRow(StatementItem item) {
    // ignore: unused_local_variable
    final change = item.previous > 0 
        ? ((item.current - item.previous) / item.previous * 100)
        : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              FinancialCalculator.formatCurrency(item.current),
              style: TextStyle(
                fontSize: 13,
                fontWeight: item.isBold ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 70,
            child: Text(
              FinancialCalculator.formatCurrency(item.previous),
              style: TextStyle(
                fontSize: 12,
                color: AppColorsUnified.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementTotalRow(StatementItem item, Color color) {
    final change = item.previous > 0 
        ? ((item.current - item.previous) / item.previous * 100)
        : 0.0;
    
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            item.label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            FinancialCalculator.formatCurrency(item.current),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (change != 0)
                Icon(
                  change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: change >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                ),
              Text(
                '${change.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: change >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(FinancialSummary current, FinancialSummary previous) {
    final grossProfit = current.netProfit;
    final prevGrossProfit = previous.netProfit;
    final profitChange = prevGrossProfit != 0 
        ? ((grossProfit - prevGrossProfit) / prevGrossProfit.abs() * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: grossProfit >= 0
              ? [AppColorsUnified.success.withOpacity(0.1), AppColorsUnified.success.withOpacity(0.05)]
              : [AppColorsUnified.error.withOpacity(0.1), AppColorsUnified.error.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: grossProfit >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'UTILIDAD NETA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: profitChange >= 0 
                      ? AppColorsUnified.success.withOpacity(0.2)
                      : AppColorsUnified.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profitChange >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: profitChange >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profitChange >= 0 ? '+' : ''}${profitChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: profitChange >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            FinancialCalculator.formatCurrency(grossProfit),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: grossProfit >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Margen: ${current.profitMargin.toStringAsFixed(1)}%',
            style: TextStyle(
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeAnalysis(FinancialSummary current, FinancialSummary previous) {
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
            'Análisis Comparativo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCompareItem(
            label: 'Variación Ingresos',
            current: current.totalIncome,
            previous: previous.totalIncome,
          ),
          _buildCompareItem(
            label: 'Variación Gastos',
            current: current.totalExpenses,
            previous: previous.totalExpenses,
            invertColors: true,
          ),
          _buildCompareItem(
            label: 'Variación Utilidad',
            current: current.netProfit,
            previous: previous.netProfit,
          ),
          _buildCompareItem(
            label: 'Variación Margen',
            current: current.profitMargin,
            previous: previous.profitMargin,
            isPercentage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCompareItem({
    required String label,
    required double current,
    required double previous,
    bool invertColors = false,
    bool isPercentage = false,
  }) {
    final change = previous != 0 
        ? ((current - previous) / previous.abs() * 100)
        : 0.0;
    
    final isPositive = change >= 0;
    Color changeColor;
    if (invertColors) {
      changeColor = isPositive ? AppColorsUnified.error : AppColorsUnified.success;
    } else {
      changeColor = isPositive ? AppColorsUnified.success : AppColorsUnified.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            isPercentage 
                ? '${current.toStringAsFixed(1)}%'
                : FinancialCalculator.formatCurrency(current),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: changeColor,
                ),
                Text(
                  '${change.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BALANCE GENERAL ====================
  Widget _buildBalanceSheet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatementHeader(
            title: 'Balance General',
            subtitle: 'Al ${_formatDate(_endDate)}',
          ),
          const SizedBox(height: 16),

          // Activos
          _buildBalanceSection(
            title: 'ACTIVOS',
            items: [
              BalanceItem(name: 'Efectivo y Equivalentes', amount: _totalAssets * 0.4),
              BalanceItem(name: 'Cuentas por Cobrar', amount: _totalAssets * 0.25),
              BalanceItem(name: 'Inventario de Minerales', amount: _totalAssets * 0.2),
              BalanceItem(name: 'Equipos y Maquinaria', amount: _totalAssets * 0.1),
              BalanceItem(name: 'Otros Activos', amount: _totalAssets * 0.05),
            ],
            total: _totalAssets,
            color: AppColorsUnified.success,
          ),
          const SizedBox(height: 16),

          // Pasivos
          _buildBalanceSection(
            title: 'PASIVOS',
            items: [
              BalanceItem(name: 'Cuentas por Pagar', amount: _totalLiabilities * 0.5),
              BalanceItem(name: 'Obligaciones Laborales', amount: _totalLiabilities * 0.3),
              BalanceItem(name: 'Impuestos por Pagar', amount: _totalLiabilities * 0.15),
              BalanceItem(name: 'Otros Pasivos', amount: _totalLiabilities * 0.05),
            ],
            total: _totalLiabilities,
            color: AppColorsUnified.error,
          ),
          const SizedBox(height: 16),

          // Patrimonio
          _buildBalanceSection(
            title: 'PATRIMONIO',
            items: [
              BalanceItem(name: 'Capital Social', amount: _totalEquity * 0.6),
              BalanceItem(name: 'Utilidades Retenidas', amount: _totalEquity * 0.25),
              BalanceItem(name: 'Utilidad del Período', amount: _totalEquity * 0.15),
            ],
            total: _totalEquity,
            color: AppColorsUnified.companyBlue,
          ),
          const SizedBox(height: 16),

          // Ecuación contable
          _buildAccountingEquation(),
          const SizedBox(height: 16),

          // Indicadores del balance
          _buildBalanceIndicators(),
        ],
      ),
    );
  }

  Widget _buildBalanceSection({
    required String title,
    required List<BalanceItem> items,
    required double total,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 13)),
                Text(
                  FinancialCalculator.formatCurrency(item.amount),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total $title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  FinancialCalculator.formatCurrency(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountingEquation() {
    final isBalanced = (_totalAssets - _totalLiabilities - _totalEquity).abs() < 0.01;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBalanced ? AppColorsUnified.success : AppColorsUnified.warning,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ecuación Contable',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEquationPart('Activos', _totalAssets, AppColorsUnified.success),
              const Text(' = ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildEquationPart('Pasivos', _totalLiabilities, AppColorsUnified.error),
              const Text(' + ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildEquationPart('Patrimonio', _totalEquity, AppColorsUnified.companyBlue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBalanced ? Icons.check_circle : Icons.warning,
                color: isBalanced ? AppColorsUnified.success : AppColorsUnified.warning,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isBalanced ? 'Balance cuadrado' : 'Diferencia detectada',
                style: TextStyle(
                  color: isBalanced ? AppColorsUnified.success : AppColorsUnified.warning,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquationPart(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          _formatShortCurrency(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceIndicators() {
    final currentRatio = _totalLiabilities > 0 
        ? (_totalAssets * 0.65 / _totalLiabilities) // Activos corrientes / Pasivos corrientes
        : 0.0;
    final debtRatio = _totalAssets > 0 
        ? (_totalLiabilities / _totalAssets * 100)
        : 0.0;
    final equityRatio = _totalAssets > 0 
        ? (_totalEquity / _totalAssets * 100)
        : 0.0;

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
            'Indicadores del Balance',
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
                child: _buildIndicatorCard(
                  label: 'Razón Corriente',
                  value: currentRatio.toStringAsFixed(2),
                  description: currentRatio >= 1.5 ? 'Buena' : currentRatio >= 1 ? 'Aceptable' : 'Baja',
                  color: currentRatio >= 1.5 
                      ? AppColorsUnified.success 
                      : currentRatio >= 1 
                          ? AppColorsUnified.warning 
                          : AppColorsUnified.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorCard(
                  label: 'Endeudamiento',
                  value: '${debtRatio.toStringAsFixed(1)}%',
                  description: debtRatio <= 40 ? 'Bajo' : debtRatio <= 60 ? 'Moderado' : 'Alto',
                  color: debtRatio <= 40 
                      ? AppColorsUnified.success 
                      : debtRatio <= 60 
                          ? AppColorsUnified.warning 
                          : AppColorsUnified.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorCard(
                  label: 'Patrimonio',
                  value: '${equityRatio.toStringAsFixed(1)}%',
                  description: equityRatio >= 60 ? 'Sólido' : equityRatio >= 40 ? 'Adecuado' : 'Débil',
                  color: equityRatio >= 60 
                      ? AppColorsUnified.success 
                      : equityRatio >= 40 
                          ? AppColorsUnified.warning 
                          : AppColorsUnified.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard({
    required String label,
    required String value,
    required String description,
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
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColorsUnified.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FLUJO DE EFECTIVO ====================
  Widget _buildCashFlowStatement() {
    final summary = _currentPeriod ?? FinancialSummary.empty();
    
    // Simulación de flujo de efectivo
    final operatingCash = summary.netProfit * 1.1; // Ajuste por depreciación
    final investingCash = -summary.totalExpenses * 0.1; // Inversiones
    final financingCash = 0.0; // Sin financiamiento
    final netCash = operatingCash + investingCash + financingCash;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatementHeader(
            title: 'Estado de Flujo de Efectivo',
            subtitle: 'Del ${_formatDate(_startDate)} al ${_formatDate(_endDate)}',
          ),
          const SizedBox(height: 16),

          // Actividades de Operación
          _buildCashFlowSection(
            title: 'ACTIVIDADES DE OPERACIÓN',
            items: [
              CashFlowItem(name: 'Utilidad del período', amount: summary.netProfit),
              CashFlowItem(name: 'Depreciación y amortización', amount: summary.totalExpenses * 0.05),
              CashFlowItem(name: 'Variación en cuentas por cobrar', amount: -summary.totalIncome * 0.1),
              CashFlowItem(name: 'Variación en inventarios', amount: -summary.totalExpenses * 0.05),
              CashFlowItem(name: 'Variación en cuentas por pagar', amount: summary.totalExpenses * 0.08),
            ],
            total: operatingCash,
            color: AppColorsUnified.success,
          ),
          const SizedBox(height: 16),

          // Actividades de Inversión
          _buildCashFlowSection(
            title: 'ACTIVIDADES DE INVERSIÓN',
            items: [
              CashFlowItem(name: 'Adquisición de equipos', amount: investingCash),
            ],
            total: investingCash,
            color: AppColorsUnified.warning,
          ),
          const SizedBox(height: 16),

          // Actividades de Financiamiento
          _buildCashFlowSection(
            title: 'ACTIVIDADES DE FINANCIAMIENTO',
            items: [
              CashFlowItem(name: 'Sin movimientos', amount: 0),
            ],
            total: financingCash,
            color: AppColorsUnified.companyBlue,
          ),
          const SizedBox(height: 16),

          // Flujo neto
          _buildNetCashFlow(
            operatingCash: operatingCash,
            investingCash: investingCash,
            financingCash: financingCash,
            netCash: netCash,
          ),
          const SizedBox(height: 16),

          // Análisis de liquidez
          _buildLiquidityAnalysis(netCash, summary),
        ],
      ),
    );
  }

  Widget _buildCashFlowSection({
    required String title,
    required List<CashFlowItem> items,
    required double total,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontSize: 13)),
                ),
                Text(
                  FinancialCalculator.formatCurrency(item.amount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: item.amount >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                  ),
                ),
              ],
            ),
          )),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flujo Neto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  FinancialCalculator.formatCurrency(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: total >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetCashFlow({
    required double operatingCash,
    required double investingCash,
    required double financingCash,
    required double netCash,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: netCash >= 0
              ? [AppColorsUnified.success.withOpacity(0.1), AppColorsUnified.success.withOpacity(0.05)]
              : [AppColorsUnified.error.withOpacity(0.1), AppColorsUnified.error.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: netCash >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'FLUJO DE EFECTIVO NETO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FinancialCalculator.formatCurrency(netCash),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: netCash >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCashSummaryChip('Operación', operatingCash, AppColorsUnified.success),
              _buildCashSummaryChip('Inversión', investingCash, AppColorsUnified.warning),
              _buildCashSummaryChip('Financiamiento', financingCash, AppColorsUnified.companyBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashSummaryChip(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          _formatShortCurrency(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: amount >= 0 ? color : AppColorsUnified.error,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidityAnalysis(double netCash, FinancialSummary summary) {
    final burnRate = summary.totalExpenses > 0 
        ? summary.totalExpenses / 30 // Gasto diario
        : 0.0;
    final runway = burnRate > 0 
        ? (netCash.abs() / burnRate).toInt()
        : 0;

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
            'Análisis de Liquidez',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLiquidityRow(
            label: 'Gasto Promedio Diario',
            value: FinancialCalculator.formatCurrency(burnRate),
            description: 'Burn rate',
          ),
          const Divider(),
          _buildLiquidityRow(
            label: 'Cobertura de Efectivo',
            value: '$runway días',
            description: netCash >= 0 ? 'Runway positivo' : 'Déficit',
            color: runway > 90 
                ? AppColorsUnified.success 
                : runway > 30 
                    ? AppColorsUnified.warning 
                    : AppColorsUnified.error,
          ),
          const Divider(),
          _buildLiquidityRow(
            label: 'Efectivo Generado',
            value: FinancialCalculator.formatCurrency(netCash),
            description: netCash >= 0 ? 'Positivo' : 'Negativo',
            color: netCash >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidityRow({
    required String label,
    required String value,
    required String description,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
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

  // ==================== HELPERS ====================
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatShortCurrency(double value) {
    if (value.abs() >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadStatements();
    }
  }

  double _getPreviousCategoryAmount(String category, bool isIncome) {
    // En una implementación real, esto obtendría datos del período anterior
    return 0;
  }

  void _printStatement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impresión próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareStatement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartir próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Clases auxiliares
class StatementItem {
  final String label;
  final double current;
  final double previous;
  final bool isBold;

  StatementItem({
    required this.label,
    required this.current,
    required this.previous,
    this.isBold = false,
  });
}

class BalanceItem {
  final String name;
  final double amount;

  BalanceItem({required this.name, required this.amount});
}

class CashFlowItem {
  final String name;
  final double amount;

  CashFlowItem({required this.name, required this.amount});
}
