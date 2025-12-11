import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/financial_entry.dart';
import '../../models/financial_metrics.dart';
import '../../data/accounting_repository.dart';
import '../../data/financial_calculator.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/chart_widgets.dart';
import 'add_transaction_page.dart';
import 'transactions_list_page.dart';
import 'financial_reports_page.dart';
import 'financial_statements_page.dart';
import 'mining_kpis_page.dart';
import 'accounts_payable_receivable_page.dart';
import 'budget_management_page.dart';
import 'mining_payroll_page.dart';
import 'accounting_inventory_page.dart';
import 'export_reports_page.dart';

/// Dashboard principal de contabilidad para empresas mineras
class AccountingDashboardPage extends StatefulWidget {
  final String companyId;
  final String companyName;

  const AccountingDashboardPage({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<AccountingDashboardPage> createState() => _AccountingDashboardPageState();
}

class _AccountingDashboardPageState extends State<AccountingDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AccountingRepository _repository;
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Datos financieros
  FinancialSummary? _summary;
  List<DailyCashFlow> _cashFlowData = [];
  List<CategoryBreakdown> _incomeBreakdown = [];
  List<CategoryBreakdown> _expenseBreakdown = [];
  List<FinancialAlert> _alerts = [];
  List<FinancialEntry> _recentTransactions = [];

  // Datos integrados (antes en company_metrics)
  List<ProjectPerformance> _projects = [];
  List<EmployeeProductivity> _topEmployees = [];
  List<ResourceUsage> _resourceUsage = [];

  // Métricas de publicaciones
  PublicationsSummary? _publicationsSummary;

  // Período seleccionado
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repository = AccountingRepository();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      DateTime startDate;
      int days;
      
      switch (_selectedPeriod) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          days = 7;
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          days = now.difference(startDate).inDays;
          break;
        case 'quarter':
          startDate = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
          days = now.difference(startDate).inDays;
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          days = now.difference(startDate).inDays;
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
          days = 30;
      }

      // Cargar datos en paralelo
      final results = await Future.wait([
        _repository.getSummary(
          widget.companyId,
          startDate: startDate,
          endDate: now,
        ),
        _repository.getDailyCashFlow(
          widget.companyId,
          days: days,
        ),
        _repository.getCategoryBreakdown(
          widget.companyId,
          type: EntryType.income,
          startDate: startDate,
          endDate: now,
        ),
        _repository.getCategoryBreakdown(
          widget.companyId,
          type: EntryType.expense,
          startDate: startDate,
          endDate: now,
        ),
        _repository.generateAlerts(widget.companyId),
        _repository.getEntries(widget.companyId, limit: 10),
        // Nuevos datos integrados
        _repository.getProjectsPerformance(widget.companyId),
        _repository.getTopEmployees(widget.companyId),
        _repository.getResourceUsage(widget.companyId),
        // Métricas de publicaciones
        _repository.getPublicationsSummary(widget.companyId),
      ]);

      setState(() {
        _summary = results[0] as FinancialSummary;
        _cashFlowData = results[1] as List<DailyCashFlow>;
        _incomeBreakdown = results[2] as List<CategoryBreakdown>;
        _expenseBreakdown = results[3] as List<CategoryBreakdown>;
        _alerts = results[4] as List<FinancialAlert>;
        _recentTransactions = results[5] as List<FinancialEntry>;
        // Datos integrados
        _projects = results[6] as List<ProjectPerformance>;
        _topEmployees = results[7] as List<EmployeeProductivity>;
        _resourceUsage = results[8] as List<ResourceUsage>;
        // Publicaciones
        _publicationsSummary = results[9] as PublicationsSummary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
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
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        backgroundColor: AppColorsUnified.companyBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Transacción',
          style: TextStyle(color: Colors.white),
        ),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Financiero',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            widget.companyName,
            style: const TextStyle(
              color: AppColorsUnified.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        // Selector de período
        PopupMenuButton<String>(
          icon: Icon(Icons.calendar_today, color: AppColorsUnified.charcoal),
          onSelected: (value) {
            setState(() => _selectedPeriod = value);
            _loadDashboardData();
          },
          itemBuilder: (context) => [
            _buildPeriodMenuItem('week', 'Última Semana'),
            _buildPeriodMenuItem('month', 'Este Mes'),
            _buildPeriodMenuItem('quarter', 'Este Trimestre'),
            _buildPeriodMenuItem('year', 'Este Año'),
          ],
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: AppColorsUnified.charcoal),
          onPressed: _loadDashboardData,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColorsUnified.charcoal),
          onPressed: _showOptionsMenu,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColorsUnified.companyBlue,
        unselectedLabelColor: AppColorsUnified.textSecondary,
        indicatorColor: AppColorsUnified.companyBlue,
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Análisis'),
          Tab(text: 'Alertas'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPeriodMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _selectedPeriod == value ? Icons.check : Icons.calendar_today,
            size: 18,
            color: _selectedPeriod == value
                ? AppColorsUnified.companyBlue
                : AppColorsUnified.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSummaryTab(),
        _buildAnalysisTab(),
        _buildAlertsTab(),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de resumen principal
            if (_summary != null)
              _buildMainSummaryCard(),
            
            const SizedBox(height: 24),

            // Métricas rápidas
            const DashboardSectionTitle(
              title: 'Métricas Clave',
            ),
            const SizedBox(height: 12),
            _buildQuickMetricsGrid(),
            
            const SizedBox(height: 24),

            // Gráfico de flujo de caja
            CashFlowChart(
              data: _cashFlowData,
              title: 'Flujo de Caja - ${_getPeriodLabel()}',
            ),
            
            const SizedBox(height: 24),

            // === NUEVA SECCIÓN: Desempeño por Proyecto ===
            _buildSectionHeader(
              title: 'Desempeño por Proyecto',
              icon: Icons.folder_open,
              onExpand: () => _showProjectsPopup(),
            ),
            const SizedBox(height: 12),
            _buildProjectsPerformanceCard(),
            
            const SizedBox(height: 24),

            // === NUEVA SECCIÓN: Top Empleados ===
            _buildSectionHeader(
              title: 'Top Empleados',
              icon: Icons.people,
              onExpand: () => _showEmployeesPopup(),
            ),
            const SizedBox(height: 12),
            _buildTopEmployeesCard(),
            
            const SizedBox(height: 24),

            // === NUEVA SECCIÓN: Uso de Recursos ===
            _buildSectionHeader(
              title: 'Uso de Recursos',
              icon: Icons.pie_chart,
              onExpand: () => _showResourcesPopup(),
            ),
            const SizedBox(height: 12),
            _buildResourceUsageCard(),
            
            const SizedBox(height: 24),

            // === NUEVA SECCIÓN: Rendimiento de Publicaciones ===
            _buildSectionHeader(
              title: 'Rendimiento de Publicaciones',
              icon: Icons.article,
              onExpand: () => _showPublicationsPopup(),
            ),
            const SizedBox(height: 12),
            _buildPublicationsPerformanceCard(),
            
            const SizedBox(height: 24),

            // Acciones rápidas
            const DashboardSectionTitle(
              title: 'Acciones Rápidas',
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),
            
            const SizedBox(height: 24),

            // Transacciones recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DashboardSectionTitle(
                  title: 'Transacciones Recientes',
                ),
                TextButton(
                  onPressed: () => _openTransactionsList(),
                  child: Text(
                    'Ver todo',
                    style: TextStyle(
                      color: AppColorsUnified.companyBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentTransactionsList(),
            
            const SizedBox(height: 80), // Espacio para FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMainSummaryCard() {
    return FinancialSummaryCard(
      title: 'Balance Neto',
      value: FinancialCalculator.formatCurrency(_summary!.netProfit),
      icon: Icons.account_balance_wallet,
      color: _summary!.netProfit >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
      change: _summary!.profitChange,
      subtitle: 'Período: ${_getPeriodLabel()}',
    );
  }

  Widget _buildQuickMetricsGrid() {
    final metrics = _calculateQuickMetrics();
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2, // Mejor ratio para acomodar contenido
      children: metrics.map((metric) {
        return QuickMetricCard(
          label: metric['title'] as String,
          value: metric['value'] as String,
          icon: metric['icon'] as IconData,
          color: metric['color'] as Color,
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _calculateQuickMetrics() {
    final totalIncome = _summary?.totalIncome ?? 0;
    final totalExpense = _summary?.totalExpense ?? 0;
    final netBalance = totalIncome - totalExpense;
    final profitMargin = totalIncome > 0 
        ? ((netBalance / totalIncome) * 100) 
        : 0.0;

    return [
      {
        'title': 'Ingresos',
        'value': FinancialCalculator.formatCurrency(totalIncome),
        'icon': Icons.trending_up,
        'color': AppColorsUnified.success,
        'subtitle': _summary?.incomeChange != null
            ? '${_summary!.incomeChange >= 0 ? '+' : ''}${_summary!.incomeChange.toStringAsFixed(1)}%'
            : null,
      },
      {
        'title': 'Gastos',
        'value': FinancialCalculator.formatCurrency(totalExpense),
        'icon': Icons.trending_down,
        'color': AppColorsUnified.error,
        'subtitle': _summary?.expenseChange != null
            ? '${_summary!.expenseChange >= 0 ? '+' : ''}${_summary!.expenseChange.toStringAsFixed(1)}%'
            : null,
      },
      {
        'title': 'Balance Neto',
        'value': FinancialCalculator.formatCurrency(netBalance),
        'icon': Icons.account_balance_wallet,
        'color': netBalance >= 0 ? AppColorsUnified.success : AppColorsUnified.error,
        'subtitle': null,
      },
      {
        'title': 'Margen',
        'value': '${profitMargin.toStringAsFixed(1)}%',
        'icon': Icons.percent,
        'color': profitMargin >= 20 
            ? AppColorsUnified.success 
            : profitMargin >= 10 
                ? AppColorsUnified.warning 
                : AppColorsUnified.error,
        'subtitle': null,
      },
    ];
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        DashboardActionButton(
          icon: Icons.add_circle_outline,
          label: 'Registrar Ingreso',
          color: AppColorsUnified.success,
          onTap: () => _showAddTransactionDialog(type: EntryType.income),
        ),
        DashboardActionButton(
          icon: Icons.remove_circle_outline,
          label: 'Registrar Gasto',
          color: AppColorsUnified.error,
          onTap: () => _showAddTransactionDialog(type: EntryType.expense),
        ),
        DashboardActionButton(
          icon: Icons.description,
          label: 'Generar Reporte',
          color: AppColorsUnified.companyBlue,
          onTap: _showReportOptions,
        ),
        DashboardActionButton(
          icon: Icons.search,
          label: 'Buscar',
          color: AppColorsUnified.textSecondary,
          onTap: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColorsUnified.pureWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: AppColorsUnified.grey300,
              ),
              const SizedBox(height: 12),
              Text(
                'No hay transacciones registradas',
                style: TextStyle(color: AppColorsUnified.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Presiona el botón + para agregar una',
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

    return Container(
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentTransactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _recentTransactions[index];
          return _buildTransactionTile(entry);
        },
      ),
    );
  }

  Widget _buildTransactionTile(FinancialEntry entry) {
    final isIncome = entry.type == EntryType.income;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    final color = isIncome ? AppColorsUnified.success : AppColorsUnified.error;
    final sign = isIncome ? '+' : '-';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        entry.description,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatDate(entry.date)} • ${entry.getCategoryDisplayName()}',
        style: const TextStyle(
          fontSize: 12,
          color: AppColorsUnified.textSecondary,
        ),
      ),
      trailing: Text(
        '$sign${FinancialCalculator.formatCurrency(entry.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
      onTap: () => _showTransactionDetails(entry),
    );
  }

  // === NUEVOS MÉTODOS PARA SECCIONES INTEGRADAS ===

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required VoidCallback onExpand,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColorsUnified.companyBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.open_in_full, size: 18, color: AppColorsUnified.companyBlue),
          onPressed: onExpand,
          tooltip: 'Ampliar',
        ),
      ],
    );
  }

  Widget _buildProjectsPerformanceCard() {
    if (_projects.isEmpty) {
      return _buildEmptyCard('No hay proyectos activos', Icons.folder_open);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: _projects.take(3).map((project) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProjectProgressBar(project),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectProgressBar(ProjectPerformance project) {
    final progressColor = project.progress >= 75
        ? AppColorsUnified.success
        : project.progress >= 50
            ? AppColorsUnified.warning
            : AppColorsUnified.companyBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                project.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColorsUnified.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${project.progress.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: project.progress / 100,
            minHeight: 6,
            backgroundColor: AppColorsUnified.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Presupuesto: ${FinancialCalculator.formatCurrency(project.budgetUsed)} / ${FinancialCalculator.formatCurrency(project.budgetTotal)}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColorsUnified.textSecondary,
              ),
            ),
            if (project.daysRemaining > 0)
              Text(
                '${project.daysRemaining} días',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopEmployeesCard() {
    if (_topEmployees.isEmpty) {
      return _buildEmptyCard('No hay datos de empleados', Icons.people);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: _topEmployees.take(3).map((employee) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEmployeeRow(employee),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmployeeRow(EmployeeProductivity employee) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsUnified.companyBlue.withOpacity(0.7),
                AppColorsUnified.companyBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              employee.avatarInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
                employee.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
              Text(
                employee.position,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColorsUnified.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${employee.productivity.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.success,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceUsageCard() {
    if (_resourceUsage.isEmpty) {
      return _buildEmptyCard('No hay datos de recursos', Icons.pie_chart);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: _resourceUsage.map((resource) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildResourceBar(resource),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResourceBar(ResourceUsage resource) {
    final percentage = (resource.usagePercentage * 100).clamp(0.0, 100.0);
    final color = percentage >= 80
        ? AppColorsUnified.error
        : percentage >= 60
            ? AppColorsUnified.warning
            : AppColorsUnified.companyBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              resource.displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: resource.usagePercentage.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColorsUnified.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColorsUnified.grey300),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === POPUPS PARA AMPLIAR SECCIONES ===

  void _showProjectsPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_open, color: AppColorsUnified.companyBlue),
                      SizedBox(width: 8),
                      Text(
                        'Desempeño por Proyecto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProjectProgressBar(project),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (project.roi > 0)
                                  _buildInfoChip('ROI: ${project.roi.toStringAsFixed(1)}%', AppColorsUnified.success),
                                _buildInfoChip(
                                  project.status == ProjectStatus.active ? 'Activo' : 'Pausado',
                                  project.status == ProjectStatus.active 
                                      ? AppColorsUnified.companyBlue 
                                      : AppColorsUnified.warning,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmployeesPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people, color: AppColorsUnified.companyBlue),
                      SizedBox(width: 8),
                      Text(
                        'Top Empleados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _topEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = _topEmployees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildEmployeeRow(employee),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Horas', '${employee.hoursWorked.toStringAsFixed(0)}h'),
                                _buildStatItem('Tareas', '${employee.tasksCompleted.toStringAsFixed(0)}'),
                                _buildStatItem('Eficiencia', '${(employee.efficiency * 100).toStringAsFixed(0)}%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResourcesPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart, color: AppColorsUnified.companyBlue),
                      SizedBox(width: 8),
                      Text(
                        'Uso de Recursos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _resourceUsage.length,
                  itemBuilder: (context, index) {
                    final resource = _resourceUsage[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildResourceBar(resource),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Asignado', FinancialCalculator.formatCurrency(resource.allocated)),
                                _buildStatItem('Usado', FinancialCalculator.formatCurrency(resource.used)),
                                _buildStatItem('Disponible', FinancialCalculator.formatCurrency(resource.available)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === SECCIÓN DE PUBLICACIONES ===

  Widget _buildPublicationsPerformanceCard() {
    if (_publicationsSummary == null || _publicationsSummary!.totalPublications == 0) {
      return _buildEmptyCard('No hay publicaciones aún', Icons.article);
    }

    final summary = _publicationsSummary!;
    final topItems = [
      if (summary.bestSeller != null && summary.bestSeller!.sales > 0)
        _TopItem('Más Vendido', summary.bestSeller!.title, '${summary.bestSeller!.sales} ventas', Icons.shopping_cart, AppColorsUnified.success),
      if (summary.mostLiked != null)
        _TopItem('Más Likes', summary.mostLiked!.title, '${summary.mostLiked!.likes} ❤', Icons.favorite, AppColorsUnified.error),
      if (summary.mostCommented != null)
        _TopItem('Más Comentado', summary.mostCommented!.title, '${summary.mostCommented!.comments} comentarios', Icons.comment, AppColorsUnified.companyBlue),
      if (summary.mostChatted != null && summary.mostChatted!.chats > 0)
        _TopItem('Más Chats', summary.mostChatted!.title, '${summary.mostChatted!.chats} chats', Icons.chat, AppColorsUnified.gold),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen rápido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPublicationStat('${summary.totalPublications}', 'Publicaciones', Icons.article),
              _buildPublicationStat('${summary.totalLikes}', 'Likes', Icons.favorite),
              _buildPublicationStat('${summary.totalComments}', 'Comentarios', Icons.comment),
              if (summary.totalSales > 0)
                _buildPublicationStat('${summary.totalSales}', 'Ventas', Icons.shopping_cart),
            ],
          ),
          if (topItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // Top items
            ...topItems.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTopItemRow(item),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildPublicationStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColorsUnified.companyBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTopItemRow(_TopItem item) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(item.icon, size: 16, color: item.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: item.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColorsUnified.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          item.value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: item.color,
          ),
        ),
      ],
    );
  }

  void _showPublicationsPopup() {
    if (_publicationsSummary == null) return;
    
    final summary = _publicationsSummary!;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.article, color: AppColorsUnified.companyBlue),
                      SizedBox(width: 8),
                      Text(
                        'Rendimiento de Publicaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Stats generales
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPopupStat('${summary.totalPublications}', 'Total', Icons.article),
                    _buildPopupStat('${summary.totalLikes}', 'Likes', Icons.favorite),
                    _buildPopupStat('${summary.totalComments}', 'Comentarios', Icons.comment),
                    _buildPopupStat('${summary.totalSales}', 'Ventas', Icons.shopping_cart),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Top Items detallados
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary.bestSeller != null && summary.bestSeller!.sales > 0)
                        _buildTopPublicationCard(
                          '🏆 Más Vendido',
                          summary.bestSeller!,
                          '${summary.bestSeller!.sales} ventas',
                          AppColorsUnified.success,
                        ),
                      if (summary.mostLiked != null)
                        _buildTopPublicationCard(
                          '❤️ Más Likes',
                          summary.mostLiked!,
                          '${summary.mostLiked!.likes} likes',
                          AppColorsUnified.error,
                        ),
                      if (summary.mostCommented != null)
                        _buildTopPublicationCard(
                          '💬 Más Comentado',
                          summary.mostCommented!,
                          '${summary.mostCommented!.comments} comentarios',
                          AppColorsUnified.companyBlue,
                        ),
                      if (summary.mostViewed != null)
                        _buildTopPublicationCard(
                          '👁️ Más Visto',
                          summary.mostViewed!,
                          '${summary.mostViewed!.views} vistas',
                          AppColorsUnified.grey500,
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Ingresos por publicaciones
                      if (summary.totalRevenue > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColorsUnified.gold.withOpacity(0.2),
                                AppColorsUnified.gold.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, color: AppColorsUnified.gold, size: 32),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ingresos Generados',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColorsUnified.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    FinancialCalculator.formatCurrency(summary.totalRevenue),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsUnified.gold,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColorsUnified.companyBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPublicationCard(
    String title,
    PublicationPerformance pub,
    String highlight,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Imagen o placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: pub.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(pub.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: pub.imageUrl == null
                ? Icon(Icons.article, color: color, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pub.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColorsUnified.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  pub.typeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              highlight,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColorsUnified.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gráfico de tendencia
          TrendLineChart(
            data: _cashFlowData,
            title: 'Tendencia de Balance',
          ),
          
          const SizedBox(height: 24),

          // Desglose de ingresos
          CategoryPieChart(
            data: _incomeBreakdown,
            title: 'Desglose de Ingresos',
            colors: const [
              Color(0xFF4CAF50),
              Color(0xFF8BC34A),
              Color(0xFFCDDC39),
              Color(0xFFFFEB3B),
              Color(0xFFFFC107),
            ],
          ),
          
          const SizedBox(height: 24),

          // Desglose de gastos
          CategoryPieChart(
            data: _expenseBreakdown,
            title: 'Desglose de Gastos',
            colors: const [
              Color(0xFFF44336),
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
              Color(0xFF673AB7),
              Color(0xFF3F51B5),
              Color(0xFF2196F3),
              Color(0xFF03A9F4),
              Color(0xFF00BCD4),
            ],
          ),
          
          const SizedBox(height: 24),

          // Top categorías de gasto
          _buildTopExpenseCategories(),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTopExpenseCategories() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.charcoal.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: AppColorsUnified.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Top Categorías de Gasto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_expenseBreakdown.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Sin datos de gastos',
                  style: TextStyle(color: AppColorsUnified.textSecondary),
                ),
              ),
            )
          else
            ...(_expenseBreakdown.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final maxAmount = _expenseBreakdown.first.amount;
              final progress = maxAmount > 0 ? category.amount / maxAmount : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColorsUnified.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsUnified.error,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.categoryName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          FinancialCalculator.formatCurrency(category.amount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColorsUnified.grey200,
                        valueColor: AlwaysStoppedAnimation(
                          AppColorsUnified.error.withOpacity(0.7 - (index * 0.1)),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            })),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (_alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColorsUnified.success.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Todo en orden!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No hay alertas financieras pendientes',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FinancialAlertCard(
            title: alert.title,
            message: alert.message,
            severity: _convertSeverity(alert.severity),
            onDismiss: () {
              setState(() {
                _alerts.removeAt(index);
              });
            },
            onTap: () => _handleAlertAction(alert),
          ),
        );
      },
    );
  }

  AlertSeverityType _convertSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return AlertSeverityType.info;
      case AlertSeverity.warning:
        return AlertSeverityType.warning;
      case AlertSeverity.critical:
        return AlertSeverityType.critical;
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColorsUnified.companyBlue),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando datos financieros...',
            style: TextStyle(color: AppColorsUnified.textSecondary),
          ),
        ],
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColorsUnified.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColorsUnified.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsUnified.companyBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'Última Semana';
      case 'month':
        return 'Este Mes';
      case 'quarter':
        return 'Este Trimestre';
      case 'year':
        return 'Este Año';
      default:
        return 'Este Mes';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTransactionDialog({EntryType? type}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          companyId: widget.companyId,
          initialType: type,
        ),
      ),
    );

    // Recargar datos si se creó una transacción
    if (result == true) {
      _loadDashboardData();
    }
  }

  void _openTransactionsList({EntryType? filterType}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionsListPage(
          companyId: widget.companyId,
          filterType: filterType,
        ),
      ),
    );

    // Recargar datos si hubo cambios
    if (result == true) {
      _loadDashboardData();
    }
  }

  void _editTransaction(FinancialEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          companyId: widget.companyId,
          entryToEdit: entry,
        ),
      ),
    );

    // Recargar datos si se editó
    if (result == true) {
      _loadDashboardData();
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Módulos de Contabilidad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.gold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_balance, color: AppColorsUnified.gold),
                title: const Text('Estados Financieros', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('Balance, Resultados, Flujo de Efectivo', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openFinancialStatements();
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text('KPIs Mineros', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('Producción, Costos, Eficiencia', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openMiningKPIs();
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.green),
                title: const Text('Cuentas por Cobrar/Pagar', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('Gestión de cartera', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openAccountsPayableReceivable();
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart, color: Colors.orange),
                title: const Text('Presupuestos', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('Control presupuestal', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openBudgetManagement();
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.purple),
                title: const Text('Nómina Minera', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('Gestión de personal', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openMiningPayroll();
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory, color: Colors.teal),
                title: const Text('Inventario Contable', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('Valoración de inventario', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openAccountingInventory();
                },
              ),
              const Divider(color: AppColorsUnified.textSecondary),
              ListTile(
                leading: const Icon(Icons.file_download, color: Colors.red),
                title: const Text('Exportar Reportes', style: TextStyle(color: AppColorsUnified.textPrimary)),
                subtitle: const Text('PDF, Excel, CSV', style: TextStyle(color: AppColorsUnified.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _openExportReports();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppColorsUnified.textSecondary),
                title: const Text('Configuración', style: TextStyle(color: AppColorsUnified.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _openSettings();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openMiningKPIs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiningKPIsPage(
          companyId: widget.companyId,
          companyName: widget.companyName,
        ),
      ),
    );
  }

  void _openFinancialStatements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialStatementsPage(
          companyId: widget.companyId,
          companyName: widget.companyName,
        ),
      ),
    );
  }

  void _showReportOptions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialReportsPage(
          companyId: widget.companyId,
          companyName: widget.companyName,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    // Abrir lista de transacciones con búsqueda
    _openTransactionsList();
  }

  void _showTransactionDetails(FinancialEntry entry) {
    // Abrir página de edición para ver detalles
    _editTransaction(entry);
  }

  void _handleAlertAction(FinancialAlert alert) {
    // TODO: Implementar acciones de alerta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Acción para: ${alert.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAccountsPayableReceivable() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountsPayableReceivablePage(
          odooMineId: widget.companyId,
        ),
      ),
    );
  }

  void _openBudgetManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetManagementPage(
          odooMineId: widget.companyId,
        ),
      ),
    );
  }

  void _openMiningPayroll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiningPayrollPage(
          odooMineId: widget.companyId,
        ),
      ),
    );
  }

  void _openAccountingInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountingInventoryPage(
          odooMineId: widget.companyId,
        ),
      ),
    );
  }

  void _openExportReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportReportsPage(
          odooMineId: widget.companyId,
        ),
      ),
    );
  }

  void _openSettings() {
    // TODO: Implementar configuración
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Helper class para top items de publicaciones
class _TopItem {
  final String label;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _TopItem(this.label, this.title, this.value, this.icon, this.color);
}
