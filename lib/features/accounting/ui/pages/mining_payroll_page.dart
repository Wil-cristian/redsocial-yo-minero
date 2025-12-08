import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors_unified.dart';

class MiningPayrollPage extends StatefulWidget {
  final String odooMineId;

  const MiningPayrollPage({
    super.key,
    required this.odooMineId,
  });

  @override
  State<MiningPayrollPage> createState() => _MiningPayrollPageState();
}

class _MiningPayrollPageState extends State<MiningPayrollPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  bool _isLoading = true;
  List<Employee> _employees = [];
  PayrollSummary? _summary;
  String _selectedPeriod = 'Diciembre 2024';
  String _filterDepartment = 'all';

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
    
    _employees = _generateSampleEmployees();
    _calculateSummary();
    
    setState(() => _isLoading = false);
  }

  void _calculateSummary() {
    double totalSalaries = 0;
    double totalDeductions = 0;
    double totalBonuses = 0;
    double totalOvertime = 0;

    for (var emp in _employees) {
      totalSalaries += emp.baseSalary;
      totalDeductions += emp.totalDeductions;
      totalBonuses += emp.productionBonus + emp.attendanceBonus;
      totalOvertime += emp.overtimePay;
    }

    _summary = PayrollSummary(
      totalEmployees: _employees.length,
      totalSalaries: totalSalaries,
      totalDeductions: totalDeductions,
      totalBonuses: totalBonuses,
      totalOvertime: totalOvertime,
    );
  }

  List<Employee> _generateSampleEmployees() {
    return [
      Employee(
        id: '1',
        name: 'Juan Carlos Rodríguez',
        position: 'Operador de Perforadora',
        department: 'Extracción',
        baseSalary: 18500,
        overtimeHours: 24,
        overtimePay: 3700,
        productionBonus: 2500,
        attendanceBonus: 500,
        imssDeduction: 925,
        isrDeduction: 1850,
        otherDeductions: 0,
        startDate: DateTime(2020, 3, 15),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '2',
        name: 'María Elena García',
        position: 'Ingeniera de Seguridad',
        department: 'Seguridad',
        baseSalary: 32000,
        overtimeHours: 8,
        overtimePay: 1600,
        productionBonus: 0,
        attendanceBonus: 500,
        imssDeduction: 1600,
        isrDeduction: 4800,
        otherDeductions: 1200,
        startDate: DateTime(2019, 8, 1),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '3',
        name: 'Roberto Hernández',
        position: 'Supervisor de Mina',
        department: 'Operaciones',
        baseSalary: 28000,
        overtimeHours: 16,
        overtimePay: 2800,
        productionBonus: 3500,
        attendanceBonus: 500,
        imssDeduction: 1400,
        isrDeduction: 4200,
        otherDeductions: 500,
        startDate: DateTime(2018, 1, 10),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '4',
        name: 'Ana Sofía Martínez',
        position: 'Operadora de Cargador',
        department: 'Extracción',
        baseSalary: 17000,
        overtimeHours: 32,
        overtimePay: 4533,
        productionBonus: 2000,
        attendanceBonus: 500,
        imssDeduction: 850,
        isrDeduction: 1700,
        otherDeductions: 0,
        startDate: DateTime(2021, 5, 20),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '5',
        name: 'Pedro Luis Sánchez',
        position: 'Técnico de Mantenimiento',
        department: 'Mantenimiento',
        baseSalary: 22000,
        overtimeHours: 20,
        overtimePay: 2750,
        productionBonus: 1500,
        attendanceBonus: 500,
        imssDeduction: 1100,
        isrDeduction: 2750,
        otherDeductions: 300,
        startDate: DateTime(2019, 11, 5),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '6',
        name: 'Laura Fernanda Díaz',
        position: 'Geóloga',
        department: 'Exploración',
        baseSalary: 35000,
        overtimeHours: 0,
        overtimePay: 0,
        productionBonus: 5000,
        attendanceBonus: 500,
        imssDeduction: 1750,
        isrDeduction: 5600,
        otherDeductions: 0,
        startDate: DateTime(2020, 7, 15),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '7',
        name: 'Miguel Ángel Torres',
        position: 'Chofer de Camión',
        department: 'Transporte',
        baseSalary: 16000,
        overtimeHours: 40,
        overtimePay: 5333,
        productionBonus: 1800,
        attendanceBonus: 0,
        imssDeduction: 800,
        isrDeduction: 1600,
        otherDeductions: 500,
        startDate: DateTime(2022, 2, 1),
        status: EmployeeStatus.active,
      ),
      Employee(
        id: '8',
        name: 'Carmen Jiménez',
        position: 'Auxiliar Administrativo',
        department: 'Administración',
        baseSalary: 14000,
        overtimeHours: 0,
        overtimePay: 0,
        productionBonus: 0,
        attendanceBonus: 500,
        imssDeduction: 700,
        isrDeduction: 1120,
        otherDeductions: 0,
        startDate: DateTime(2023, 1, 15),
        status: EmployeeStatus.active,
      ),
    ];
  }

  List<Employee> get _filteredEmployees {
    if (_filterDepartment == 'all') return _employees;
    return _employees.where((e) => e.department == _filterDepartment).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.backgroundDark,
        title: const Text(
          'Nómina Minera',
          style: TextStyle(color: AppColorsUnified.gold),
        ),
        iconTheme: const IconThemeData(color: AppColorsUnified.gold),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColorsUnified.gold,
          labelColor: AppColorsUnified.gold,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.people), text: 'Empleados'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Recibos'),
            Tab(icon: Icon(Icons.analytics), text: 'Análisis'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppColorsUnified.backgroundDark,
            onSelected: (value) {
              if (value == 'calculate') {
                _showCalculatePayrollDialog();
              } else if (value == 'export') {
                _exportPayroll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'calculate',
                child: Row(
                  children: [
                    Icon(Icons.calculate, color: AppColorsUnified.gold),
                    SizedBox(width: 8),
                    Text('Calcular Nómina', style: TextStyle(color: AppColorsUnified.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: AppColorsUnified.gold),
                    SizedBox(width: 8),
                    Text('Exportar', style: TextStyle(color: AppColorsUnified.textPrimary)),
                  ],
                ),
              ),
            ],
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
                _buildEmployeesTab(),
                _buildReceiptsTab(),
                _buildAnalysisTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppColorsUnified.gold,
        child: const Icon(Icons.person_add, color: Colors.black),
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
          // Selector de período
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          
          // Total nómina
          _buildTotalPayrollCard(),
          const SizedBox(height: 16),
          
          // Tarjetas de resumen
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Empleados', '${_summary!.totalEmployees}', Icons.people, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Horas Extra', '${_employees.fold<double>(0, (sum, e) => sum + e.overtimeHours).toStringAsFixed(0)}h', Icons.access_time, Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Bonos', _currencyFormat.format(_summary!.totalBonuses), Icons.star, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Deducciones', _currencyFormat.format(_summary!.totalDeductions), Icons.remove_circle, Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Distribución por departamento
          _buildDepartmentDistribution(),
          const SizedBox(height: 16),
          
          // Top salarios
          _buildTopSalaries(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Período:',
            style: TextStyle(color: AppColorsUnified.textSecondary),
          ),
          DropdownButton<String>(
            value: _selectedPeriod,
            dropdownColor: AppColorsUnified.backgroundDark,
            style: const TextStyle(color: AppColorsUnified.gold),
            underline: const SizedBox(),
            items: [
              'Octubre 2024',
              'Noviembre 2024',
              'Diciembre 2024',
            ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) {
              setState(() => _selectedPeriod = v!);
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPayrollCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.gold.withValues(alpha: 0.3),
            AppColorsUnified.backgroundDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Text(
            'Total Nómina del Período',
            style: TextStyle(color: AppColorsUnified.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(_summary!.netPayroll),
            style: const TextStyle(
              color: AppColorsUnified.gold,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPayrollItem('Salarios Base', _summary!.totalSalaries),
              _buildPayrollItem('+ Extras', _summary!.totalOvertime),
              _buildPayrollItem('+ Bonos', _summary!.totalBonuses),
              _buildPayrollItem('- Deducciones', _summary!.totalDeductions),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollItem(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 10),
        ),
        Text(
          _currencyFormat.format(amount),
          style: const TextStyle(
            color: AppColorsUnified.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
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
              fontSize: 20,
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

  Widget _buildDepartmentDistribution() {
    final deptTotals = <String, double>{};
    for (var emp in _employees) {
      deptTotals[emp.department] = (deptTotals[emp.department] ?? 0) + emp.netSalary;
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];

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
            'Distribución por Departamento',
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
                sections: deptTotals.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final dept = entry.value;
                  final total = deptTotals.values.reduce((a, b) => a + b);
                  final percentage = (dept.value / total) * 100;

                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: dept.value,
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
            children: deptTotals.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final dept = entry.value;
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
                    dept.key,
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

  Widget _buildTopSalaries() {
    final sorted = List<Employee>.from(_employees)..sort((a, b) => b.netSalary.compareTo(a.netSalary));

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
            'Top 5 Sueldos Netos',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((emp) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.2),
                      child: Text(
                        emp.name.substring(0, 1),
                        style: const TextStyle(color: AppColorsUnified.gold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp.name,
                            style: const TextStyle(color: AppColorsUnified.textPrimary, fontSize: 13),
                          ),
                          Text(
                            emp.position,
                            style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currencyFormat.format(emp.netSalary),
                      style: const TextStyle(
                        color: AppColorsUnified.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmployeesTab() {
    final employees = _filteredEmployees;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
        return _buildEmployeeCard(emp);
      },
    );
  }

  Widget _buildEmployeeCard(Employee emp) {
    return Card(
      color: AppColorsUnified.backgroundDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEmployeeDetails(emp),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.2),
                    child: Text(
                      emp.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                      style: const TextStyle(
                        color: AppColorsUnified.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp.name,
                          style: const TextStyle(
                            color: AppColorsUnified.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          emp.position,
                          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: emp.status == EmployeeStatus.active
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      emp.status == EmployeeStatus.active ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: emp.status == EmployeeStatus.active ? Colors.green : Colors.orange,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEmpDetail('Departamento', emp.department),
                  _buildEmpDetail('Antigüedad', '${emp.yearsOfService} años'),
                  _buildEmpDetail('Sueldo Neto', _currencyFormat.format(emp.netSalary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpDetail(String label, String value) {
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

  Widget _buildReceiptsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final emp = _employees[index];
        return _buildReceiptCard(emp);
      },
    );
  }

  Widget _buildReceiptCard(Employee emp) {
    return Card(
      color: AppColorsUnified.backgroundDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.2),
          child: const Icon(Icons.receipt, color: AppColorsUnified.gold, size: 20),
        ),
        title: Text(
          emp.name,
          style: const TextStyle(color: AppColorsUnified.textPrimary, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Neto: ${_currencyFormat.format(emp.netSalary)}',
          style: const TextStyle(color: AppColorsUnified.gold),
        ),
        iconColor: AppColorsUnified.gold,
        collapsedIconColor: AppColorsUnified.textSecondary,
        children: [
          const Divider(color: AppColorsUnified.textSecondary),
          const SizedBox(height: 8),
          _buildReceiptLine('Salario Base', emp.baseSalary),
          _buildReceiptLine('Horas Extra (${emp.overtimeHours}h)', emp.overtimePay),
          _buildReceiptLine('Bono Producción', emp.productionBonus),
          _buildReceiptLine('Bono Asistencia', emp.attendanceBonus),
          const Divider(color: AppColorsUnified.textSecondary),
          _buildReceiptLine('Total Percepciones', emp.grossSalary, bold: true),
          const SizedBox(height: 8),
          _buildReceiptLine('IMSS', -emp.imssDeduction, isDeduction: true),
          _buildReceiptLine('ISR', -emp.isrDeduction, isDeduction: true),
          if (emp.otherDeductions > 0)
            _buildReceiptLine('Otras Deducciones', -emp.otherDeductions, isDeduction: true),
          const Divider(color: AppColorsUnified.textSecondary),
          _buildReceiptLine('NETO A PAGAR', emp.netSalary, bold: true, highlight: true),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Descargar recibo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Descargando recibo de ${emp.name}'),
                      backgroundColor: AppColorsUnified.gold,
                    ),
                  );
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Descargar PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColorsUnified.gold,
                  side: const BorderSide(color: AppColorsUnified.gold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptLine(String label, double amount, {bool bold = false, bool isDeduction = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? AppColorsUnified.textPrimary : AppColorsUnified.textSecondary,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              color: highlight
                  ? AppColorsUnified.gold
                  : isDeduction
                      ? Colors.red
                      : AppColorsUnified.textPrimary,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOvertimeAnalysis(),
          const SizedBox(height: 16),
          _buildSalaryTrendChart(),
          const SizedBox(height: 16),
          _buildCostPerEmployee(),
        ],
      ),
    );
  }

  Widget _buildOvertimeAnalysis() {
    final empsByOvertime = List<Employee>.from(_employees)..sort((a, b) => b.overtimeHours.compareTo(a.overtimeHours));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Análisis de Horas Extra',
                style: TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...empsByOvertime.take(5).map((emp) {
            final maxHours = empsByOvertime.first.overtimeHours;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        emp.name.split(' ').take(2).join(' '),
                        style: const TextStyle(color: AppColorsUnified.textPrimary, fontSize: 13),
                      ),
                      Text(
                        '${emp.overtimeHours}h - ${_currencyFormat.format(emp.overtimePay)}',
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: maxHours > 0 ? emp.overtimeHours / maxHours : 0,
                    backgroundColor: AppColorsUnified.backgroundDark,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSalaryTrendChart() {
    // Datos simulados
    final months = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final totals = [245000.0, 252000.0, 248000.0, 260000.0, 255000.0, 268916.0];

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
            'Tendencia de Nómina (6 meses)',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColorsUnified.textSecondary.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 10),
                        );
                      },
                      reservedSize: 35,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: totals.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: AppColorsUnified.gold,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColorsUnified.gold.withValues(alpha: 0.1),
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

  Widget _buildCostPerEmployee() {
    final avgSalary = _summary!.netPayroll / _summary!.totalEmployees;
    final avgOvertime = _summary!.totalOvertime / _summary!.totalEmployees;
    final avgBonus = _summary!.totalBonuses / _summary!.totalEmployees;

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
            'Costo Promedio por Empleado',
            style: TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCostItem('Sueldo Neto Promedio', avgSalary, Icons.account_balance_wallet),
          _buildCostItem('Horas Extra Promedio', avgOvertime, Icons.access_time),
          _buildCostItem('Bono Promedio', avgBonus, Icons.star),
        ],
      ),
    );
  }

  Widget _buildCostItem(String label, double value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColorsUnified.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColorsUnified.textSecondary),
            ),
          ),
          Text(
            _currencyFormat.format(value),
            style: const TextStyle(
              color: AppColorsUnified.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final departments = ['all', ..._employees.map((e) => e.department).toSet()];
    
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
            const Text(
              'Filtrar por Departamento',
              style: TextStyle(
                color: AppColorsUnified.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: departments.map((dept) {
                final isSelected = _filterDepartment == dept;
                return FilterChip(
                  label: Text(dept == 'all' ? 'Todos' : dept),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _filterDepartment = dept);
                    Navigator.pop(context);
                  },
                  selectedColor: AppColorsUnified.gold.withValues(alpha: 0.3),
                  checkmarkColor: AppColorsUnified.gold,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
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

  void _showEmployeeDetails(Employee emp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColorsUnified.gold.withValues(alpha: 0.2),
                    child: Text(
                      emp.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                      style: const TextStyle(
                        color: AppColorsUnified.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp.name,
                          style: const TextStyle(
                            color: AppColorsUnified.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          emp.position,
                          style: const TextStyle(color: AppColorsUnified.gold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Departamento', emp.department),
              _buildInfoRow('Fecha de ingreso', DateFormat('dd/MM/yyyy').format(emp.startDate)),
              _buildInfoRow('Antigüedad', '${emp.yearsOfService} años'),
              _buildInfoRow('Estado', emp.status == EmployeeStatus.active ? 'Activo' : 'Inactivo'),
              const Divider(height: 32, color: AppColorsUnified.textSecondary),
              const Text(
                'Información Salarial',
                style: TextStyle(
                  color: AppColorsUnified.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Salario Base', _currencyFormat.format(emp.baseSalary)),
              _buildInfoRow('Horas Extra', '${emp.overtimeHours}h = ${_currencyFormat.format(emp.overtimePay)}'),
              _buildInfoRow('Bono Producción', _currencyFormat.format(emp.productionBonus)),
              _buildInfoRow('Bono Asistencia', _currencyFormat.format(emp.attendanceBonus)),
              _buildInfoRow('Total Percepciones', _currencyFormat.format(emp.grossSalary)),
              const SizedBox(height: 8),
              _buildInfoRow('IMSS', _currencyFormat.format(emp.imssDeduction)),
              _buildInfoRow('ISR', _currencyFormat.format(emp.isrDeduction)),
              _buildInfoRow('Otras Deducciones', _currencyFormat.format(emp.otherDeductions)),
              const Divider(height: 24, color: AppColorsUnified.textSecondary),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SUELDO NETO',
                    style: TextStyle(
                      color: AppColorsUnified.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currencyFormat.format(emp.netSalary),
                    style: const TextStyle(
                      color: AppColorsUnified.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
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
                        _tabController.animateTo(2);
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('Ver Recibo'),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  void _showCalculatePayrollDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsUnified.backgroundDark,
        title: const Text(
          'Calcular Nómina',
          style: TextStyle(color: AppColorsUnified.gold),
        ),
        content: const Text(
          '¿Desea calcular la nómina del período actual? Esta acción actualizará los cálculos de todos los empleados.',
          style: TextStyle(color: AppColorsUnified.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColorsUnified.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nómina calculada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColorsUnified.gold),
            child: const Text('Calcular', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _exportPayroll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando nómina...'),
        backgroundColor: AppColorsUnified.gold,
      ),
    );
  }

  void _showAddEmployeeDialog() {
    // Implementar formulario de agregar empleado
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función disponible próximamente'),
        backgroundColor: AppColorsUnified.gold,
      ),
    );
  }
}

// Modelos
enum EmployeeStatus { active, inactive }

class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final double baseSalary;
  final double overtimeHours;
  final double overtimePay;
  final double productionBonus;
  final double attendanceBonus;
  final double imssDeduction;
  final double isrDeduction;
  final double otherDeductions;
  final DateTime startDate;
  final EmployeeStatus status;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.baseSalary,
    required this.overtimeHours,
    required this.overtimePay,
    required this.productionBonus,
    required this.attendanceBonus,
    required this.imssDeduction,
    required this.isrDeduction,
    required this.otherDeductions,
    required this.startDate,
    required this.status,
  });

  double get grossSalary => baseSalary + overtimePay + productionBonus + attendanceBonus;
  double get totalDeductions => imssDeduction + isrDeduction + otherDeductions;
  double get netSalary => grossSalary - totalDeductions;
  int get yearsOfService => DateTime.now().difference(startDate).inDays ~/ 365;
}

class PayrollSummary {
  final int totalEmployees;
  final double totalSalaries;
  final double totalDeductions;
  final double totalBonuses;
  final double totalOvertime;

  PayrollSummary({
    required this.totalEmployees,
    required this.totalSalaries,
    required this.totalDeductions,
    required this.totalBonuses,
    required this.totalOvertime,
  });

  double get grossPayroll => totalSalaries + totalOvertime + totalBonuses;
  double get netPayroll => grossPayroll - totalDeductions;
}
