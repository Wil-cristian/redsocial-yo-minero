import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors_unified.dart';
import '../../models/financial_entry.dart';
import '../../data/accounting_repository.dart';

/// Página para agregar/editar transacciones financieras
class AddTransactionPage extends StatefulWidget {
  final String companyId;
  final EntryType? initialType;
  final FinancialEntry? entryToEdit;

  const AddTransactionPage({
    super.key,
    required this.companyId,
    this.initialType,
    this.entryToEdit,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AccountingRepository();
  
  // Controladores
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Estado del formulario
  late EntryType _selectedType;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String? _recurringFrequency;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? EntryType.expense;
    _isEditing = widget.entryToEdit != null;
    
    if (_isEditing) {
      _loadEntryData();
    }
  }

  void _loadEntryData() {
    final entry = widget.entryToEdit!;
    _amountController.text = entry.amount.toStringAsFixed(2);
    _descriptionController.text = entry.description;
    _referenceController.text = entry.reference ?? '';
    _notesController.text = entry.notes ?? '';
    _selectedType = entry.type;
    _selectedCategory = entry.category;
    _selectedDate = entry.entryDate;
    _isRecurring = entry.isRecurring;
    _recurringFrequency = entry.recurringFrequency;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.grey100,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de tipo
              _buildTypeSelector(),
              const SizedBox(height: 20),
              
              // Monto
              _buildAmountField(),
              const SizedBox(height: 20),
              
              // Categoría
              _buildCategorySelector(),
              const SizedBox(height: 20),
              
              // Descripción
              _buildDescriptionField(),
              const SizedBox(height: 20),
              
              // Fecha
              _buildDateSelector(),
              const SizedBox(height: 20),
              
              // Referencia (opcional)
              _buildReferenceField(),
              const SizedBox(height: 20),
              
              // Notas (opcional)
              _buildNotesField(),
              const SizedBox(height: 20),
              
              // Recurrente
              _buildRecurringSection(),
              const SizedBox(height: 32),
              
              // Botón guardar
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _selectedType == EntryType.income 
          ? AppColorsUnified.success 
          : AppColorsUnified.error,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _isEditing 
            ? 'Editar ${_selectedType == EntryType.income ? 'Ingreso' : 'Gasto'}'
            : 'Nuevo ${_selectedType == EntryType.income ? 'Ingreso' : 'Gasto'}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _confirmDelete,
          ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              type: EntryType.income,
              icon: Icons.arrow_downward,
              label: 'Ingreso',
              color: AppColorsUnified.success,
            ),
          ),
          Expanded(
            child: _buildTypeOption(
              type: EntryType.expense,
              icon: Icons.arrow_upward,
              label: 'Gasto',
              color: AppColorsUnified.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required EntryType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null; // Reset categoría al cambiar tipo
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColorsUnified.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColorsUnified.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Monto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _selectedType == EntryType.income 
                      ? AppColorsUnified.success 
                      : AppColorsUnified.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _selectedType == EntryType.income 
                        ? AppColorsUnified.success 
                        : AppColorsUnified.error,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Monto inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = _selectedType == EntryType.income
        ? MiningIncomeCategory.values
        : MiningExpenseCategory.values;

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
            'Categoría',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedType == EntryType.income
                ? MiningIncomeCategory.values.map((cat) {
                    return _buildCategoryChip(
                      code: cat.code,
                      label: cat.displayName,
                      icon: _getIncomeIcon(cat),
                    );
                  }).toList()
                : _buildExpenseCategoryChips(),
          ),
          if (_selectedCategory == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecciona una categoría',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColorsUnified.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseCategoryChips() {
    final widgets = <Widget>[];
    
    for (var group in ExpenseGroup.values) {
      final categories = MiningExpenseCategory.byGroup(group);
      if (categories.isNotEmpty) {
        widgets.add(
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                group.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
            ),
          ),
        );
        widgets.addAll(
          categories.map((cat) => _buildCategoryChip(
            code: cat.code,
            label: cat.displayName,
            icon: _getExpenseIcon(cat),
          )),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildCategoryChip({
    required String code,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == code;
    final color = _selectedType == EntryType.income 
        ? AppColorsUnified.success 
        : AppColorsUnified.error;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColorsUnified.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColorsUnified.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColorsUnified.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return _buildInputContainer(
      label: 'Descripción',
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Ej: Venta de oro lote #001',
          hintStyle: TextStyle(color: AppColorsUnified.grey300),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa una descripción';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return _buildInputContainer(
      label: 'Fecha',
      child: InkWell(
        onTap: _selectDate,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColorsUnified.companyBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_drop_down,
                color: AppColorsUnified.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceField() {
    return _buildInputContainer(
      label: 'Número de Referencia (opcional)',
      child: TextFormField(
        controller: _referenceController,
        decoration: InputDecoration(
          hintText: 'Ej: FAC-001, REC-2024',
          hintStyle: TextStyle(color: AppColorsUnified.grey300),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.tag,
            color: AppColorsUnified.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return _buildInputContainer(
      label: 'Notas adicionales (opcional)',
      child: TextFormField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Notas o comentarios...',
          hintStyle: TextStyle(color: AppColorsUnified.grey300),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRecurringSection() {
    return _buildInputContainer(
      label: 'Transacción Recurrente',
      child: Column(
        children: [
          SwitchListTile(
            value: _isRecurring,
            onChanged: (value) => setState(() => _isRecurring = value),
            title: const Text('Es recurrente'),
            subtitle: Text(
              'Se repetirá automáticamente',
              style: TextStyle(
                fontSize: 12,
                color: AppColorsUnified.textSecondary,
              ),
            ),
            activeColor: AppColorsUnified.companyBlue,
            contentPadding: EdgeInsets.zero,
          ),
          if (_isRecurring) ...[
            const Divider(),
            DropdownButtonFormField<String>(
              value: _recurringFrequency,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                border: InputBorder.none,
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Diario')),
                DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                DropdownMenuItem(value: 'biweekly', child: Text('Quincenal')),
                DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                DropdownMenuItem(value: 'yearly', child: Text('Anual')),
              ],
              onChanged: (value) => setState(() => _recurringFrequency = value),
              validator: (value) {
                if (_isRecurring && value == null) {
                  return 'Selecciona la frecuencia';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputContainer({
    required String label,
    required Widget child,
  }) {
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
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final color = _selectedType == EntryType.income 
        ? AppColorsUnified.success 
        : AppColorsUnified.error;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isEditing ? Icons.save : Icons.add_circle_outline),
                  const SizedBox(width: 8),
                  Text(
                    _isEditing ? 'Guardar Cambios' : 'Registrar ${_selectedType == EntryType.income ? 'Ingreso' : 'Gasto'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColorsUnified.companyBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final entry = FinancialEntry(
        id: _isEditing ? widget.entryToEdit!.id : '',
        companyId: widget.companyId,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        entryDate: _selectedDate,
        reference: _referenceController.text.trim().isNotEmpty 
            ? _referenceController.text.trim() 
            : null,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        isRecurring: _isRecurring,
        recurringFrequency: _isRecurring ? _recurringFrequency : null,
      );

      FinancialEntry? result;
      if (_isEditing) {
        result = await _repository.updateEntry(widget.entryToEdit!.id, entry);
      } else {
        result = await _repository.createEntry(entry);
      }

      if (result != null && mounted) {
        Navigator.pop(context, true); // Retorna true para indicar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Transacción actualizada' : 'Transacción registrada'),
            backgroundColor: AppColorsUnified.success,
          ),
        );
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColorsUnified.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Estás seguro de que quieres eliminar esta transacción? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTransaction();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColorsUnified.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _repository.deleteEntry(widget.entryToEdit!.id);
      
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción eliminada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: AppColorsUnified.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  IconData _getIncomeIcon(MiningIncomeCategory category) {
    switch (category) {
      case MiningIncomeCategory.goldSale:
        return Icons.monetization_on;
      case MiningIncomeCategory.silverSale:
        return Icons.diamond;
      case MiningIncomeCategory.copperSale:
        return Icons.circle;
      case MiningIncomeCategory.mineralSale:
        return Icons.landscape;
      case MiningIncomeCategory.thirdPartyServices:
        return Icons.engineering;
      case MiningIncomeCategory.equipmentRental:
        return Icons.agriculture;
      case MiningIncomeCategory.otherIncome:
        return Icons.more_horiz;
    }
  }

  IconData _getExpenseIcon(MiningExpenseCategory category) {
    switch (category) {
      case MiningExpenseCategory.fuel:
        return Icons.local_gas_station;
      case MiningExpenseCategory.explosives:
        return Icons.whatshot;
      case MiningExpenseCategory.chemicals:
        return Icons.science;
      case MiningExpenseCategory.safetyEquipment:
        return Icons.health_and_safety;
      case MiningExpenseCategory.maintenanceEquipment:
        return Icons.build;
      case MiningExpenseCategory.spareParts:
        return Icons.settings;
      case MiningExpenseCategory.transport:
        return Icons.local_shipping;
      case MiningExpenseCategory.tools:
        return Icons.handyman;
      case MiningExpenseCategory.salaries:
        return Icons.people;
      case MiningExpenseCategory.bonuses:
        return Icons.card_giftcard;
      case MiningExpenseCategory.socialSecurity:
        return Icons.security;
      case MiningExpenseCategory.training:
        return Icons.school;
      case MiningExpenseCategory.benefits:
        return Icons.favorite;
      case MiningExpenseCategory.licenses:
        return Icons.badge;
      case MiningExpenseCategory.taxes:
        return Icons.account_balance;
      case MiningExpenseCategory.utilities:
        return Icons.electrical_services;
      case MiningExpenseCategory.rent:
        return Icons.home;
      case MiningExpenseCategory.insurance:
        return Icons.shield;
      case MiningExpenseCategory.legal:
        return Icons.gavel;
      case MiningExpenseCategory.accounting:
        return Icons.calculate;
      case MiningExpenseCategory.otherExpense:
        return Icons.more_horiz;
    }
  }
}
