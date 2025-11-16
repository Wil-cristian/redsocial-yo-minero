import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_colors_unified.dart';
import 'shared/models/inventory_item.dart';
import 'core/services/inventory_service.dart';

class CompanyInventoryMovementsPage extends StatefulWidget {
  final InventoryItem item;

  const CompanyInventoryMovementsPage({
    super.key,
    required this.item,
  });

  @override
  State<CompanyInventoryMovementsPage> createState() =>
      _CompanyInventoryMovementsPageState();
}

class _CompanyInventoryMovementsPageState
    extends State<CompanyInventoryMovementsPage> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryMovement> _movements = [];
  InventoryMovementType? _filterType;
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  RealtimeChannel? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _realtimeSubscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMovements() async {
    try {
      setState(() => _isLoading = true);
      final movements = await _inventoryService.getMovementsByItem(widget.item.id);
      setState(() {
        _movements = movements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar movimientos: $e'),
            backgroundColor: AppColorsUnified.error,
          ),
        );
      }
    }
  }

  void _setupRealtimeSubscription() {
    _realtimeSubscription = _inventoryService.subscribeToMovementChanges(
      itemId: widget.item.id,
      onData: (movements) {
        if (mounted) {
          setState(() => _movements = movements);
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error en actualización: $error'),
              backgroundColor: AppColorsUnified.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColorsUnified.background,
        appBar: AppBar(
          backgroundColor: AppColorsUnified.pureWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColorsUnified.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Cargando...', style: TextStyle(color: AppColorsUnified.textPrimary)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColorsUnified.gold),
        ),
      );
    }

    final filteredMovements = _getFilteredMovements();

    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColorsUnified.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Movimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorsUnified.textPrimary,
              ),
            ),
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColorsUnified.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColorsUnified.greySoftGradient,
              border: Border(
                bottom: BorderSide(color: AppColorsUnified.grey300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Entradas',
                    _getTotalQuantityByType(InventoryMovementType.entrada),
                    Icons.arrow_downward,
                    AppColorsUnified.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Salidas',
                    _getTotalQuantityByType(InventoryMovementType.salida),
                    Icons.arrow_upward,
                    AppColorsUnified.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Balance',
                    _getNetChange(),
                    Icons.trending_up,
                    AppColorsUnified.gold,
                  ),
                ),
              ],
            ),
          ),

          // Filters
          if (_filterType != null || _dateRange != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColorsUnified.pureWhite,
              child: Row(
                children: [
                  if (_filterType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_filterType!.label),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _filterType = null;
                          });
                        },
                        backgroundColor: AppColorsUnified.grey200,
                      ),
                    ),
                  if (_dateRange != null)
                    Chip(
                      label: Text(
                        '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _dateRange = null;
                        });
                      },
                      backgroundColor: AppColorsUnified.grey200,
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterType = null;
                        _dateRange = null;
                      });
                    },
                    child: const Text(
                      'Limpiar filtros',
                      style: TextStyle(color: AppColorsUnified.gold),
                    ),
                  ),
                ],
              ),
            ),

          // Movements list
          Expanded(
            child: filteredMovements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColorsUnified.grey300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay movimientos',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMovements.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final movement = filteredMovements[index];
                      return _buildMovementCard(movement);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMovementDialog,
        backgroundColor: AppColorsUnified.gold,
        icon: Icon(Icons.add, color: AppColorsUnified.pureWhite),
        label: Text(
          'Nuevo Movimiento',
          style: TextStyle(color: AppColorsUnified.pureWhite),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsUnified.grey300),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementCard(InventoryMovement movement) {
    final typeColor = _getMovementTypeColor(movement.type);
    final typeIcon = _getMovementTypeIcon(movement.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.fade(typeColor, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          movement.type.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${movement.quantity > 0 ? '+' : ''}${movement.quantity} ${widget.item.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: movement.quantity > 0
                                ? AppColorsUnified.success
                                : AppColorsUnified.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movement.date.day}/${movement.date.month}/${movement.date.year} ${movement.date.hour}:${movement.date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColorsUnified.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (movement.reason != null && movement.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              movement.reason!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColorsUnified.textSecondary,
              ),
            ),
          ],
          if (movement.responsibleUserId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppColorsUnified.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Usuario: ${movement.responsibleUserId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Filtrar Movimientos',
          style: TextStyle(color: AppColorsUnified.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Movimiento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColorsUnified.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InventoryMovementType.values.map((type) {
                return FilterChip(
                  label: Text(type.label),
                  selected: _filterType == type,
                  onSelected: (selected) {
                    setState(() {
                      _filterType = selected ? type : null;
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (range != null) {
                  setState(() {
                    _dateRange = range;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: const Text('Seleccionar Rango de Fechas'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppColorsUnified.gold)),
          ),
        ],
      ),
    );
  }

  void _showAddMovementDialog() {
    final typeController = ValueNotifier<InventoryMovementType>(InventoryMovementType.entrada);
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Nuevo Movimiento',
          style: TextStyle(color: AppColorsUnified.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de Movimiento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<InventoryMovementType>(
                valueListenable: typeController,
                builder: (context, selectedType, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: InventoryMovementType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.label),
                        selected: selectedType == type,
                        onSelected: (selected) {
                          if (selected) {
                            typeController.value = type;
                          }
                        },
                        selectedColor: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad (${widget.item.unit})',
                  hintText: 'Ej: 10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColorsUnified.gold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Motivo (opcional)',
                  hintText: 'Ej: Compra de stock adicional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColorsUnified.gold),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColorsUnified.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity == null || quantity == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrese una cantidad válida'),
                    backgroundColor: AppColorsUnified.error,
                  ),
                );
                return;
              }

              final movement = InventoryMovement(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                itemId: widget.item.id,
                type: typeController.value,
                quantity: _isPositiveMovement(typeController.value) ? quantity : -quantity,
                date: DateTime.now(),
                reason: reasonController.text.isEmpty ? null : reasonController.text,
              );

              Navigator.pop(context);

              try {
                // Guardar en Supabase
                await _inventoryService.createMovement(movement);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Movimiento registrado: ${movement.type.label}'),
                      backgroundColor: AppColorsUnified.success,
                    ),
                  );
                }
                // La lista se actualizará automáticamente por la suscripción
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al guardar movimiento: $e'),
                      backgroundColor: AppColorsUnified.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsUnified.gold,
              foregroundColor: AppColorsUnified.pureWhite,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  bool _isPositiveMovement(InventoryMovementType type) {
    return type == InventoryMovementType.entrada ||
        type == InventoryMovementType.devolucion;
  }

  List<InventoryMovement> _getFilteredMovements() {
    return _movements.where((movement) {
      if (_filterType != null && movement.type != _filterType) {
        return false;
      }
      if (_dateRange != null) {
        if (movement.date.isBefore(_dateRange!.start) ||
            movement.date.isAfter(_dateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _getTotalQuantityByType(InventoryMovementType type) {
    final total = _movements
        .where((m) => m.type == type)
        .fold<double>(0.0, (sum, m) => sum + m.quantity.abs());
    return '${total.toStringAsFixed(0)} ${widget.item.unit}';
  }

  String _getNetChange() {
    final total = _movements.fold<double>(0.0, (sum, m) => sum + m.quantity);
    return '${total > 0 ? '+' : ''}${total.toStringAsFixed(0)} ${widget.item.unit}';
  }

  Color _getMovementTypeColor(InventoryMovementType type) {
    switch (type) {
      case InventoryMovementType.entrada:
      case InventoryMovementType.devolucion:
        return AppColorsUnified.success;
      case InventoryMovementType.salida:
      case InventoryMovementType.merma:
        return AppColorsUnified.error;
      case InventoryMovementType.ajuste:
        return AppColorsUnified.warning;
      case InventoryMovementType.transferencia:
        return AppColorsUnified.companyBlue;
    }
  }

  IconData _getMovementTypeIcon(InventoryMovementType type) {
    switch (type) {
      case InventoryMovementType.entrada:
        return Icons.arrow_downward;
      case InventoryMovementType.salida:
        return Icons.arrow_upward;
      case InventoryMovementType.ajuste:
        return Icons.tune;
      case InventoryMovementType.transferencia:
        return Icons.swap_horiz;
      case InventoryMovementType.devolucion:
        return Icons.undo;
      case InventoryMovementType.merma:
        return Icons.trending_down;
    }
  }

}
