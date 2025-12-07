import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/financial_entry.dart';
import '../../data/accounting_repository.dart';
import '../../data/financial_calculator.dart';
import 'add_transaction_page.dart';

/// Página para listar y buscar transacciones
class TransactionsListPage extends StatefulWidget {
  final String companyId;
  final EntryType? filterType;

  const TransactionsListPage({
    super.key,
    required this.companyId,
    this.filterType,
  });

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  final _repository = AccountingRepository();
  final _searchController = TextEditingController();
  
  List<FinancialEntry> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filtros
  EntryType? _filterType;
  String? _filterCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'date'; // date, amount
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _filterType = widget.filterType;
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _repository.getEntries(
        widget.companyId,
        type: _filterType,
        category: _filterCategory,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Ordenar
      if (_sortBy == 'date') {
        entries.sort((a, b) => _sortAscending 
            ? a.entryDate.compareTo(b.entryDate)
            : b.entryDate.compareTo(a.entryDate));
      } else if (_sortBy == 'amount') {
        entries.sort((a, b) => _sortAscending 
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));
      }

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar transacciones: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchTransactions(String query) async {
    if (query.isEmpty) {
      _loadTransactions();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final entries = await _repository.searchTransactions(
        widget.companyId,
        query,
      );
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en la búsqueda: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.grey100,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildSummaryBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : _entries.isEmpty
                        ? _buildEmptyState()
                        : _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransaction(),
        backgroundColor: AppColorsUnified.companyBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva', style: TextStyle(color: Colors.white)),
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
        'Transacciones',
        style: TextStyle(
          color: AppColorsUnified.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.sort, color: AppColorsUnified.charcoal),
          onPressed: _showSortOptions,
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: AppColorsUnified.charcoal),
          onPressed: _showFilterOptions,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColorsUnified.pureWhite,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar transacciones...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadTransactions();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColorsUnified.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: _searchTransactions,
          ),
          const SizedBox(height: 12),
          
          // Chips de filtro rápido
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  isSelected: _filterType == null,
                  onTap: () {
                    setState(() => _filterType = null);
                    _loadTransactions();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Ingresos',
                  isSelected: _filterType == EntryType.income,
                  color: AppColorsUnified.success,
                  onTap: () {
                    setState(() => _filterType = EntryType.income);
                    _loadTransactions();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Gastos',
                  isSelected: _filterType == EntryType.expense,
                  color: AppColorsUnified.error,
                  onTap: () {
                    setState(() => _filterType = EntryType.expense);
                    _loadTransactions();
                  },
                ),
                if (_startDate != null || _endDate != null) ...[
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Fechas',
                    isSelected: true,
                    icon: Icons.calendar_today,
                    onTap: _showDateRangePicker,
                    onRemove: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _loadTransactions();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    IconData? icon,
    required VoidCallback onTap,
    VoidCallback? onRemove,
  }) {
    final chipColor = color ?? AppColorsUnified.companyBlue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColorsUnified.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? chipColor : AppColorsUnified.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? chipColor : AppColorsUnified.textSecondary,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 14, color: chipColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (var entry in _entries) {
      if (entry.type == EntryType.income) {
        totalIncome += entry.amount;
      } else if (entry.type == EntryType.expense) {
        totalExpense += entry.amount;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingresos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  FinancialCalculator.formatCurrency(totalIncome),
                  style: TextStyle(
                    fontSize: 16,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Gastos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  FinancialCalculator.formatCurrency(totalExpense),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.error,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  FinancialCalculator.formatCurrency(totalIncome - totalExpense),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: totalIncome >= totalExpense 
                        ? AppColorsUnified.success 
                        : AppColorsUnified.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Agrupar por fecha
    final Map<String, List<FinancialEntry>> groupedEntries = {};
    
    for (var entry in _entries) {
      final dateKey = _formatDateKey(entry.entryDate);
      groupedEntries.putIfAbsent(dateKey, () => []).add(entry);
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: groupedEntries.length,
        itemBuilder: (context, index) {
          final dateKey = groupedEntries.keys.elementAt(index);
          final dayEntries = groupedEntries[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  dateKey,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ),
              ...dayEntries.map((entry) => _buildTransactionTile(entry)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(FinancialEntry entry) {
    final isIncome = entry.type == EntryType.income;
    final color = isIncome ? AppColorsUnified.success : AppColorsUnified.error;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _openEditTransaction(entry),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          entry.description,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColorsUnified.grey100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.categoryDisplayName,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ),
            if (entry.reference != null) ...[
              const SizedBox(width: 8),
              Text(
                entry.reference!,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${FinancialCalculator.formatCurrency(entry.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
            if (entry.isRecurring)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _getRecurringLabel(entry.recurringFrequency),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColorsUnified.grey300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin transacciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona + para agregar una transacción',
            style: TextStyle(
              color: AppColorsUnified.textSecondary,
            ),
          ),
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
            onPressed: _loadTransactions,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha (más reciente)'),
              trailing: _sortBy == 'date' && !_sortAscending 
                  ? const Icon(Icons.check, color: AppColorsUnified.success)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'date';
                  _sortAscending = false;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha (más antigua)'),
              trailing: _sortBy == 'date' && _sortAscending 
                  ? const Icon(Icons.check, color: AppColorsUnified.success)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'date';
                  _sortAscending = true;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Monto (mayor a menor)'),
              trailing: _sortBy == 'amount' && !_sortAscending 
                  ? const Icon(Icons.check, color: AppColorsUnified.success)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'amount';
                  _sortAscending = false;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Monto (menor a mayor)'),
              trailing: _sortBy == 'amount' && _sortAscending 
                  ? const Icon(Icons.check, color: AppColorsUnified.success)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'amount';
                  _sortAscending = true;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Rango de fechas'),
              subtitle: _startDate != null || _endDate != null
                  ? Text('${_formatShortDate(_startDate)} - ${_formatShortDate(_endDate)}')
                  : null,
              onTap: () {
                Navigator.pop(context);
                _showDateRangePicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Por categoría'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryFilter();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Limpiar filtros'),
              onTap: () {
                setState(() {
                  _filterType = null;
                  _filterCategory = null;
                  _startDate = null;
                  _endDate = null;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadTransactions();
    }
  }

  void _showCategoryFilter() {
    // TODO: Implementar filtro por categoría
  }

  Future<void> _openAddTransaction({EntryType? type}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          companyId: widget.companyId,
          initialType: type ?? _filterType,
        ),
      ),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  Future<void> _openEditTransaction(FinancialEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          companyId: widget.companyId,
          entryToEdit: entry,
        ),
      ),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDay = DateTime(date.year, date.month, date.day);

    if (entryDay == today) {
      return 'Hoy';
    } else if (entryDay == yesterday) {
      return 'Ayer';
    } else {
      const months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatShortDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getRecurringLabel(String? frequency) {
    switch (frequency) {
      case 'daily': return 'Diario';
      case 'weekly': return 'Semanal';
      case 'biweekly': return 'Quincenal';
      case 'monthly': return 'Mensual';
      case 'yearly': return 'Anual';
      default: return '';
    }
  }
}
