import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/account_payable_receivable.dart';

class AccountsPayableReceivablePage extends StatefulWidget {
  final String odooMineId;

  const AccountsPayableReceivablePage({
    super.key,
    required this.odooMineId,
  });

  @override
  State<AccountsPayableReceivablePage> createState() => _AccountsPayableReceivablePageState();
}

class _AccountsPayableReceivablePageState extends State<AccountsPayableReceivablePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  bool _isLoading = true;
  List<AccountPayableReceivable> _receivables = [];
  List<AccountPayableReceivable> _payables = [];
  AccountsSummary? _summary;
  
  String _filterStatus = 'all';
  String _sortBy = 'dueDate';

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
    
    // Simular carga de datos - en producción esto vendría de Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Datos de ejemplo
    _receivables = _generateSampleReceivables();
    _payables = _generateSamplePayables();
    _calculateSummary();
    
    setState(() => _isLoading = false);
  }

  void _calculateSummary() {
    double totalReceivable = 0;
    double totalPayable = 0;
    double overdueReceivable = 0;
    double overduePayable = 0;
    int countOverdue = 0;

    for (var r in _receivables) {
      totalReceivable += r.remainingAmount;
      if (r.isOverdue) {
        overdueReceivable += r.remainingAmount;
        countOverdue++;
      }
    }

    for (var p in _payables) {
      totalPayable += p.remainingAmount;
      if (p.isOverdue) {
        overduePayable += p.remainingAmount;
        countOverdue++;
      }
    }

    _summary = AccountsSummary(
      totalReceivable: totalReceivable,
      totalPayable: totalPayable,
      overdueReceivable: overdueReceivable,
      overduePayable: overduePayable,
      countReceivable: _receivables.length,
      countPayable: _payables.length,
      countOverdue: countOverdue,
    );
  }

  List<AccountPayableReceivable> _generateSampleReceivables() {
    return [
      AccountPayableReceivable(
        id: '1',
        odooMineId: widget.odooMineId,
        type: AccountType.receivable,
        contactName: 'Refinadora Nacional S.A.',
        contactPhone: '+52 55 1234 5678',
        contactEmail: 'pagos@refinadora.com',
        description: 'Venta de concentrado de oro - Lote 2024-001',
        totalAmount: 850000,
        paidAmount: 425000,
        issueDate: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().add(const Duration(days: 15)),
        status: AccountStatus.partial,
        invoiceNumber: 'FAC-2024-0156',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AccountPayableReceivable(
        id: '2',
        odooMineId: widget.odooMineId,
        type: AccountType.receivable,
        contactName: 'Metalúrgica del Norte',
        description: 'Venta de mineral de plata - Embarque diciembre',
        totalAmount: 320000,
        paidAmount: 0,
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: AccountStatus.pending,
        invoiceNumber: 'FAC-2024-0162',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AccountPayableReceivable(
        id: '3',
        odooMineId: widget.odooMineId,
        type: AccountType.receivable,
        contactName: 'Procesadora Industrial',
        description: 'Servicios de procesamiento - Noviembre 2024',
        totalAmount: 175000,
        paidAmount: 0,
        issueDate: DateTime.now().subtract(const Duration(days: 45)),
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        status: AccountStatus.overdue,
        invoiceNumber: 'FAC-2024-0148',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }

  List<AccountPayableReceivable> _generateSamplePayables() {
    return [
      AccountPayableReceivable(
        id: '4',
        odooMineId: widget.odooMineId,
        type: AccountType.payable,
        contactName: 'Explosivos Industriales S.A.',
        contactPhone: '+52 81 9876 5432',
        description: 'Suministro de explosivos - Pedido #4521',
        totalAmount: 245000,
        paidAmount: 0,
        issueDate: DateTime.now().subtract(const Duration(days: 20)),
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: AccountStatus.pending,
        invoiceNumber: 'PROV-2024-0089',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      AccountPayableReceivable(
        id: '5',
        odooMineId: widget.odooMineId,
        type: AccountType.payable,
        contactName: 'Maquinaria Pesada México',
        description: 'Renta de excavadora - Diciembre 2024',
        totalAmount: 180000,
        paidAmount: 90000,
        issueDate: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().add(const Duration(days: 20)),
        status: AccountStatus.partial,
        invoiceNumber: 'PROV-2024-0095',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AccountPayableReceivable(
        id: '6',
        odooMineId: widget.odooMineId,
        type: AccountType.payable,
        contactName: 'Combustibles del Bajío',
        description: 'Diesel industrial - Noviembre 2024',
        totalAmount: 95000,
        paidAmount: 0,
        issueDate: DateTime.now().subtract(const Duration(days: 35)),
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: AccountStatus.overdue,
        invoiceNumber: 'PROV-2024-0078',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      AccountPayableReceivable(
        id: '7',
        odooMineId: widget.odooMineId,
        type: AccountType.payable,
        contactName: 'Equipos de Seguridad Industrial',
        description: 'EPP para personal - Q4 2024',
        totalAmount: 65000,
        paidAmount: 65000,
        issueDate: DateTime.now().subtract(const Duration(days: 60)),
        dueDate: DateTime.now().subtract(const Duration(days: 30)),
        status: AccountStatus.paid,
        invoiceNumber: 'PROV-2024-0065',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  List<AccountPayableReceivable> _getFilteredList(List<AccountPayableReceivable> list) {
    var filtered = list.where((item) {
      if (_filterStatus == 'all') return true;
      if (_filterStatus == 'pending') return item.status == AccountStatus.pending;
      if (_filterStatus == 'partial') return item.status == AccountStatus.partial;
      if (_filterStatus == 'overdue') return item.isOverdue;
      if (_filterStatus == 'paid') return item.status == AccountStatus.paid;
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'dueDate':
          return a.dueDate.compareTo(b.dueDate);
        case 'amount':
          return b.remainingAmount.compareTo(a.remainingAmount);
        case 'contact':
          return a.contactName.compareTo(b.contactName);
        default:
          return a.dueDate.compareTo(b.dueDate);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.backgroundDark,
        title: const Text(
          'Cuentas por Cobrar/Pagar',
          style: TextStyle(color: AppColorsUnified.gold),
        ),
        iconTheme: const IconThemeData(color: AppColorsUnified.gold),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColorsUnified.gold,
          labelColor: AppColorsUnified.gold,
          unselectedLabelColor: AppColorsUnified.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.summarize), text: 'Resumen'),
            Tab(icon: Icon(Icons.arrow_downward), text: 'Por Cobrar'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Por Pagar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAccountDialog,
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
                _buildAccountsList(_receivables, AccountType.receivable),
                _buildAccountsList(_payables, AccountType.payable),
              ],
            ),
    );
  }

  Widget _buildSummaryTab() {
    if (_summary == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posición neta
          _buildNetPositionCard(),
          const SizedBox(height: 16),
          
          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Por Cobrar',
                  _summary!.totalReceivable,
                  _summary!.countReceivable,
                  Colors.green,
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Por Pagar',
                  _summary!.totalPayable,
                  _summary!.countPayable,
                  Colors.red,
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Alertas de vencidos
          if (_summary!.countOverdue > 0) _buildOverdueAlert(),
          const SizedBox(height: 16),
          
          // Próximos vencimientos
          _buildUpcomingDueSection(),
          const SizedBox(height: 16),
          
          // Antigüedad de saldos
          _buildAgingAnalysis(),
        ],
      ),
    );
  }

  Widget _buildNetPositionCard() {
    final netPosition = _summary!.netPosition;
    final isPositive = netPosition >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [Colors.green.shade900, Colors.green.shade700]
              : [Colors.red.shade900, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Posición Neta',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(netPosition.abs()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isPositive ? 'A favor' : 'En contra',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    int count,
    Color color,
    IconData icon,
  ) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(amount),
            style: const TextStyle(
              color: AppColorsUnified.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count cuentas',
            style: const TextStyle(
              color: AppColorsUnified.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_summary!.countOverdue} cuentas vencidas',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Total vencido: ${_currencyFormat.format(_summary!.totalOverdue)}',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _filterStatus = 'overdue');
              _tabController.animateTo(1);
            },
            child: const Text(
              'Ver',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDueSection() {
    final allAccounts = [..._receivables, ..._payables]
        .where((a) => a.status != AccountStatus.paid && a.daysUntilDue >= 0 && a.daysUntilDue <= 7)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange.shade400),
              const SizedBox(width: 8),
              const Text(
                'Próximos Vencimientos (7 días)',
                style: TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (allAccounts.isEmpty)
            const Text(
              'No hay vencimientos próximos',
              style: TextStyle(color: AppColorsUnified.textSecondary),
            )
          else
            ...allAccounts.take(5).map((account) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        account.type == AccountType.receivable
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 16,
                        color: account.type == AccountType.receivable
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          account.contactName,
                          style: const TextStyle(color: AppColorsUnified.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(account.remainingAmount),
                        style: const TextStyle(
                          color: AppColorsUnified.gold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${account.daysUntilDue}d',
                          style: TextStyle(
                            color: Colors.orange.shade300,
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

  Widget _buildAgingAnalysis() {
    // Análisis de antigüedad
    final aging = _calculateAging();

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
              Icon(Icons.analytics, color: AppColorsUnified.gold),
              SizedBox(width: 8),
              Text(
                'Antigüedad de Saldos',
                style: TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAgingRow('Corriente (0-30 días)', aging['current']!, Colors.green),
          _buildAgingRow('30-60 días', aging['30-60']!, Colors.yellow),
          _buildAgingRow('60-90 días', aging['60-90']!, Colors.orange),
          _buildAgingRow('Más de 90 días', aging['90+']!, Colors.red),
        ],
      ),
    );
  }

  Map<String, double> _calculateAging() {
    double current = 0;
    double days30_60 = 0;
    double days60_90 = 0;
    double days90plus = 0;

    for (var account in [..._receivables, ..._payables]) {
      if (account.status == AccountStatus.paid) continue;
      
      final daysSinceIssue = DateTime.now().difference(account.issueDate).inDays;
      final amount = account.remainingAmount;

      if (daysSinceIssue <= 30) {
        current += amount;
      } else if (daysSinceIssue <= 60) {
        days30_60 += amount;
      } else if (daysSinceIssue <= 90) {
        days60_90 += amount;
      } else {
        days90plus += amount;
      }
    }

    return {
      'current': current,
      '30-60': days30_60,
      '60-90': days60_90,
      '90+': days90plus,
    };
  }

  Widget _buildAgingRow(String label, double amount, Color color) {
    final total = _calculateAging().values.reduce((a, b) => a + b);
    final percentage = total > 0 ? (amount / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColorsUnified.textSecondary),
              ),
              Text(
                _currencyFormat.format(amount),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColorsUnified.backgroundDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(List<AccountPayableReceivable> accounts, AccountType type) {
    final filtered = _getFilteredList(accounts);
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == AccountType.receivable ? Icons.arrow_downward : Icons.arrow_upward,
              size: 64,
              color: AppColorsUnified.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ${type == AccountType.receivable ? 'cuentas por cobrar' : 'cuentas por pagar'}',
              style: const TextStyle(color: AppColorsUnified.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final account = filtered[index];
        return _buildAccountCard(account);
      },
    );
  }

  Widget _buildAccountCard(AccountPayableReceivable account) {
    return Card(
      color: AppColorsUnified.backgroundDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: account.isOverdue
              ? Colors.red.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () => _showAccountDetails(account),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      account.contactName,
                      style: const TextStyle(
                        color: AppColorsUnified.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: account.statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          account.statusIcon,
                          size: 14,
                          color: account.statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          account.statusText,
                          style: TextStyle(
                            color: account.statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                account.description,
                style: const TextStyle(
                  color: AppColorsUnified.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (account.invoiceNumber != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Factura: ${account.invoiceNumber}',
                  style: TextStyle(
                    color: AppColorsUnified.textSecondary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Barra de progreso de pago
              if (account.paidAmount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pagado: ${account.paidPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColorsUnified.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_currencyFormat.format(account.paidAmount)} / ${_currencyFormat.format(account.totalAmount)}',
                      style: const TextStyle(
                        color: AppColorsUnified.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: account.paidPercentage / 100,
                  backgroundColor: AppColorsUnified.backgroundDark,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo pendiente',
                        style: TextStyle(
                          color: AppColorsUnified.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(account.remainingAmount),
                        style: const TextStyle(
                          color: AppColorsUnified.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        account.isOverdue ? 'Vencido hace' : 'Vence en',
                        style: const TextStyle(
                          color: AppColorsUnified.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        account.isOverdue
                            ? '${account.daysOverdue} días'
                            : '${account.daysUntilDue} días',
                        style: TextStyle(
                          color: account.isOverdue ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
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
              'Filtrar por estado',
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
              children: [
                _buildFilterChip('all', 'Todos'),
                _buildFilterChip('pending', 'Pendientes'),
                _buildFilterChip('partial', 'Pago Parcial'),
                _buildFilterChip('overdue', 'Vencidos'),
                _buildFilterChip('paid', 'Pagados'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Ordenar por',
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
              children: [
                _buildSortChip('dueDate', 'Fecha vencimiento'),
                _buildSortChip('amount', 'Monto'),
                _buildSortChip('contact', 'Contacto'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filterStatus = value);
        Navigator.pop(context);
      },
      selectedColor: AppColorsUnified.gold.withValues(alpha: 0.3),
      checkmarkColor: AppColorsUnified.gold,
      labelStyle: TextStyle(
        color: isSelected ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
      ),
      backgroundColor: AppColorsUnified.backgroundDark,
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
      selectedColor: AppColorsUnified.gold.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
      ),
      backgroundColor: AppColorsUnified.backgroundDark,
    );
  }

  void _showAccountDetails(AccountPayableReceivable account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      account.contactName,
                      style: const TextStyle(
                        color: AppColorsUnified.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: account.statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      account.statusText,
                      style: TextStyle(
                        color: account.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Descripción', account.description),
              if (account.invoiceNumber != null)
                _buildDetailRow('Factura', account.invoiceNumber!),
              _buildDetailRow('Fecha emisión', DateFormat('dd/MM/yyyy').format(account.issueDate)),
              _buildDetailRow('Fecha vencimiento', DateFormat('dd/MM/yyyy').format(account.dueDate)),
              if (account.contactPhone != null)
                _buildDetailRow('Teléfono', account.contactPhone!),
              if (account.contactEmail != null)
                _buildDetailRow('Email', account.contactEmail!),
              const Divider(color: AppColorsUnified.textSecondary, height: 32),
              _buildAmountRow('Monto total', account.totalAmount),
              _buildAmountRow('Pagado', account.paidAmount, Colors.green),
              _buildAmountRow('Pendiente', account.remainingAmount, AppColorsUnified.gold),
              const SizedBox(height: 24),
              if (account.status != AccountStatus.paid) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRegisterPaymentDialog(account),
                        icon: const Icon(Icons.payment),
                        label: const Text('Registrar Pago'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Editar cuenta
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsUnified.gold,
                          side: const BorderSide(color: AppColorsUnified.gold),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColorsUnified.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColorsUnified.textSecondary,
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              color: color ?? AppColorsUnified.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterPaymentDialog(AccountPayableReceivable account) {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    String paymentMethod = 'Transferencia';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColorsUnified.backgroundDark,
          title: const Text(
            'Registrar Pago',
            style: TextStyle(color: AppColorsUnified.gold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Saldo pendiente: ${_currencyFormat.format(account.remainingAmount)}',
                  style: const TextStyle(color: AppColorsUnified.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Monto del pago',
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
                  value: paymentMethod,
                  dropdownColor: AppColorsUnified.backgroundDark,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Método de pago',
                    labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColorsUnified.gold),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => paymentMethod = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  style: const TextStyle(color: AppColorsUnified.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Referencia (opcional)',
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Fecha de pago',
                    style: TextStyle(color: AppColorsUnified.textSecondary),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(paymentDate),
                    style: const TextStyle(color: AppColorsUnified.textPrimary),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColorsUnified.gold),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: paymentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() => paymentDate = date);
                    }
                  },
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
                // Registrar el pago
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0 && amount <= account.remainingAmount) {
                  // En producción, guardar en Supabase
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pago de ${_currencyFormat.format(amount)} registrado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: _AddAccountForm(
          odooMineId: widget.odooMineId,
          onSaved: () {
            Navigator.pop(context);
            _loadData();
          },
        ),
      ),
    );
  }
}

class _AddAccountForm extends StatefulWidget {
  final String odooMineId;
  final VoidCallback onSaved;

  const _AddAccountForm({
    required this.odooMineId,
    required this.onSaved,
  });

  @override
  State<_AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<_AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  AccountType _type = AccountType.receivable;
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _invoiceController = TextEditingController();
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva Cuenta',
              style: TextStyle(
                color: AppColorsUnified.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Tipo de cuenta
            Row(
              children: [
                Expanded(
                  child: RadioListTile<AccountType>(
                    title: const Text('Por Cobrar', style: TextStyle(color: AppColorsUnified.textPrimary)),
                    value: AccountType.receivable,
                    groupValue: _type,
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<AccountType>(
                    title: const Text('Por Pagar', style: TextStyle(color: AppColorsUnified.textPrimary)),
                    value: AccountType.payable,
                    groupValue: _type,
                    activeColor: Colors.red,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactController,
              style: const TextStyle(color: AppColorsUnified.textPrimary),
              decoration: _inputDecoration('Nombre del contacto *'),
              validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColorsUnified.textPrimary),
              decoration: _inputDecoration('Descripción *'),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              style: const TextStyle(color: AppColorsUnified.textPrimary),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Monto *', prefixText: '\$ '),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Requerido';
                if (double.tryParse(v!) == null) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _invoiceController,
              style: const TextStyle(color: AppColorsUnified.textPrimary),
              decoration: _inputDecoration('Número de factura'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Fecha emisión', _issueDate, (d) {
                    setState(() => _issueDate = d);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('Fecha vencimiento', _dueDate, (d) {
                    setState(() => _dueDate = d);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsUnified.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Guardar Cuenta'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColorsUnified.textSecondary),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: AppColorsUnified.gold),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColorsUnified.gold),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(color: AppColorsUnified.textPrimary),
        ),
      ),
    );
  }

  void _saveAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      // En producción, guardar en Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSaved();
    }
  }
}
