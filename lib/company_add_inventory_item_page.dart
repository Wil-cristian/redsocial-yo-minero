import 'package:flutter/material.dart';
import 'core/theme/app_colors_unified.dart';
import 'shared/models/inventory_item.dart';

/// Página para agregar o editar items del inventario
/// Formulario completo con validación y preview
class CompanyAddInventoryItemPage extends StatefulWidget {
  final InventoryItem? existingItem;

  const CompanyAddInventoryItemPage({
    super.key,
    this.existingItem,
  });

  @override
  State<CompanyAddInventoryItemPage> createState() => _CompanyAddInventoryItemPageState();
}

class _CompanyAddInventoryItemPageState extends State<CompanyAddInventoryItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _unitController = TextEditingController();
  final _locationController = TextEditingController();
  final _supplierController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Nuevos controllers para especificaciones técnicas
  final _diametroController = TextEditingController();
  final _longitudController = TextEditingController();
  final _espesorController = TextEditingController();
  final _pesoController = TextEditingController();
  final _granulometriaController = TextEditingController();
  final _densidadController = TextEditingController();

  InventoryCategory _selectedCategory = InventoryCategory.material;
  MaterialSubcategory? _selectedSubcategory;
  String _selectedUnit = 'unidades';
  bool _isLoading = false;
  
  // Para tubos
  String _diametroUnit = 'pulgadas';
  String _longitudUnit = 'metros';

  final List<String> _commonUnits = [
    'unidades',
    'kg',
    'litros',
    'm3',
    'toneladas',
    'sacos',
    'pares',
    'metros',
    'cajas',
    'galones',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _loadExistingItem();
    }
  }

  void _loadExistingItem() {
    final item = widget.existingItem!;
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _minStockController.text = item.minStock.toString();
    _unitController.text = item.unit;
    _selectedUnit = item.unit;
    _locationController.text = item.location;
    _supplierController.text = item.supplier ?? '';
    _costController.text = item.cost?.toString() ?? '';
    _descriptionController.text = item.description ?? '';
    _selectedCategory = item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    _diametroController.dispose();
    _longitudController.dispose();
    _espesorController.dispose();
    _pesoController.dispose();
    _granulometriaController.dispose();
    _densidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Item' : 'Agregar Item'),
        backgroundColor: AppColorsUnified.pureWhite,
        foregroundColor: AppColorsUnified.textPrimary,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsUnified.grey300),
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: AppColorsUnified.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Información Básica', Icons.info_outline),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre del Item',
                      hint: 'Ej: Taladro Percutor Bosch',
                      icon: Icons.label,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(),
                    
                    // Selector de Subcategoría (solo para Materiales)
                    if (_selectedCategory == InventoryCategory.material) ...[
                      const SizedBox(height: 16),
                      _buildSubcategorySelector(),
                      
                      // Campos específicos para TUBOS
                      if (_selectedSubcategory != null && _selectedSubcategory!.isTubo) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader('📏 Especificaciones de Tubo', Icons.straighten),
                        const SizedBox(height: 16),
                        _buildTuboFields(),
                      ],
                      
                      // Campos específicos para TIERRAS
                      if (_selectedSubcategory != null && _selectedSubcategory!.isTierra) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader('⛏️ Especificaciones de Material', Icons.landscape),
                        const SizedBox(height: 16),
                        _buildTierraFields(),
                      ],
                      
                      // Campo de Peso (universal)
                      if (_selectedSubcategory != null) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader('⚖️ Información de Peso', Icons.monitor_weight),
                        const SizedBox(height: 16),
                        _buildPesoField(),
                      ],
                    ],
                    
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Descripción (opcional)',
                      hint: 'Detalles adicionales del item',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Stock e Inventario', Icons.inventory),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _quantityController,
                            label: 'Cantidad Actual',
                            hint: '0',
                            icon: Icons.numbers,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _minStockController,
                            label: 'Stock Mínimo',
                            hint: '0',
                            icon: Icons.warning_amber,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUnitSelector(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Ubicación',
                      hint: 'Ej: Almacén Central',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La ubicación es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Información Comercial', Icons.attach_money),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _costController,
                      label: 'Costo Unitario (opcional)',
                      hint: '0.00',
                      icon: Icons.price_change,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefix: '\$ ',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _supplierController,
                      label: 'Proveedor (opcional)',
                      hint: 'Ej: Ferretería Industrial',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 24),
                    if (_quantityController.text.isNotEmpty && 
                        _minStockController.text.isNotEmpty)
                      _buildStockPreview(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActions(isEditing),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColorsUnified.goldGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColorsUnified.textPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColorsUnified.textSecondary, size: 20),
            prefixText: prefix,
            filled: true,
            fillColor: AppColorsUnified.grey200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColorsUnified.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColorsUnified.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColorsUnified.gold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColorsUnified.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsUnified.grey300),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InventoryCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return InkWell(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColorsUnified.goldGradient : null,
                    color: isSelected ? null : AppColorsUnified.pureWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColorsUnified.gold : AppColorsUnified.grey300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: isSelected 
                            ? AppColorsUnified.textPrimary 
                            : AppColorsUnified.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? AppColorsUnified.textPrimary 
                              : AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unidad de Medida',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsUnified.grey300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColorsUnified.textPrimary),
              dropdownColor: AppColorsUnified.pureWhite,
              style: const TextStyle(
                fontSize: 15,
                color: AppColorsUnified.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              items: _commonUnits.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                  _unitController.text = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockPreview() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final minStock = double.tryParse(_minStockController.text) ?? 0;
    
    // ignore: unused_local_variable
    InventoryStatus status;
    Color statusColor;
    String statusText;
    
    if (quantity <= 0) {
      status = InventoryStatus.agotado;
      statusColor = AppColorsUnified.error;
      statusText = 'Agotado';
    } else if (quantity <= minStock) {
      status = InventoryStatus.critico;
      statusColor = AppColorsUnified.error;
      statusText = 'Crítico';
    } else if (quantity <= minStock * 1.5) {
      status = InventoryStatus.bajo;
      statusColor = AppColorsUnified.warning;
      statusText = 'Bajo';
    } else {
      status = InventoryStatus.disponible;
      statusColor = AppColorsUnified.success;
      statusText = 'Disponible';
    }

    final percentage = minStock > 0 ? (quantity / minStock * 100).clamp(0, 200) : 100.0;
    final cost = double.tryParse(_costController.text);
    final totalValue = cost != null ? cost * quantity : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorsUnified.fade(statusColor, 0.1),
            AppColorsUnified.fade(statusColor, 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: statusColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Preview del Stock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.pureWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nivel de Stock:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorsUnified.textSecondary,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 200).clamp(0, 1),
              minHeight: 12,
              backgroundColor: AppColorsUnified.grey300,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          if (totalValue != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Valor Total:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        border: Border(
          top: BorderSide(color: AppColorsUnified.grey300),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColorsUnified.grey300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColorsUnified.goldGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsUnified.fade(AppColorsUnified.gold, 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColorsUnified.textPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.save : Icons.add,
                            color: AppColorsUnified.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Guardar Cambios' : 'Agregar Item',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.herramienta:
        return Icons.build;
      case InventoryCategory.equipo:
        return Icons.precision_manufacturing;
      case InventoryCategory.material:
        return Icons.inventory_2;
      case InventoryCategory.repuesto:
        return Icons.settings_suggest;
      case InventoryCategory.consumible:
        return Icons.battery_charging_full;
      case InventoryCategory.seguridad:
        return Icons.security;
    }
  }

  Widget _buildSubcategorySelector() {
    const subcategories = MaterialSubcategory.values;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo Específico',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subcategories.map((sub) => ChoiceChip(
            label: Text(sub.label),
            selected: _selectedSubcategory == sub,
            onSelected: (selected) {
              setState(() {
                _selectedSubcategory = selected ? sub : null;
                // Limpiar campos cuando cambia
                _diametroController.clear();
                _longitudController.clear();
                _espesorController.clear();
                _granulometriaController.clear();
                _densidadController.clear();
              });
            },
            selectedColor: AppColorsUnified.gold,
            backgroundColor: AppColorsUnified.grey200,
            labelStyle: TextStyle(
              color: _selectedSubcategory == sub 
                  ? AppColorsUnified.textPrimary 
                  : AppColorsUnified.textSecondary,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTuboFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _diametroController,
                label: 'Diámetro',
                hint: '2',
                icon: Icons.circle_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _diametroUnit,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColorsUnified.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['pulgadas', 'mm', 'cm'].map((unit) =>
                  DropdownMenuItem(value: unit, child: Text(unit))
                ).toList(),
                onChanged: (val) => setState(() => _diametroUnit = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _longitudController,
                label: 'Longitud',
                hint: '6',
                icon: Icons.straighten,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _longitudUnit,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColorsUnified.grey200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['metros', 'pies', 'cm'].map((unit) =>
                  DropdownMenuItem(value: unit, child: Text(unit))
                ).toList(),
                onChanged: (val) => setState(() => _longitudUnit = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _espesorController,
          label: 'Espesor/Schedule',
          hint: 'Schedule 40',
          icon: Icons.line_weight,
        ),
      ],
    );
  }

  Widget _buildTierraFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _granulometriaController,
          label: 'Granulometría',
          hint: '2-5mm',
          icon: Icons.grain,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _densidadController,
          label: 'Densidad',
          hint: '1.6 ton/m³',
          icon: Icons.science,
        ),
      ],
    );
  }

  Widget _buildPesoField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _pesoController,
            label: 'Peso por Unidad',
            hint: '8.5',
            icon: Icons.scale,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsUnified.fade(AppColorsUnified.gold, 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorsUnified.gold),
            ),
            child: Column(
              children: [
                const Text(
                  'Peso Total',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _calculateTotalWeight(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorsUnified.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _calculateTotalWeight() {
    final peso = double.tryParse(_pesoController.text) ?? 0;
    final cantidad = double.tryParse(_quantityController.text) ?? 0;
    final total = peso * cantidad;
    return total > 0 ? '${total.toStringAsFixed(1)} kg' : '0 kg';
  }

  String _buildDimensionsString() {
    if (_selectedSubcategory?.isTubo == true) {
      final diam = _diametroController.text;
      final long = _longitudController.text;
      if (diam.isNotEmpty && long.isNotEmpty) {
        return '$diam$_diametroUnit × $long$_longitudUnit';
      }
    }
    return '';
  }

  Map<String, dynamic>? _buildSpecifications() {
    final specs = <String, dynamic>{};
    
    if (_selectedSubcategory?.isTubo == true) {
      if (_diametroController.text.isNotEmpty) {
        specs['diametro'] = _diametroController.text;
        specs['diametro_unidad'] = _diametroUnit;
      }
      if (_longitudController.text.isNotEmpty) {
        specs['longitud'] = _longitudController.text;
        specs['longitud_unidad'] = _longitudUnit;
      }
      if (_espesorController.text.isNotEmpty) {
        specs['espesor'] = _espesorController.text;
      }
    }
    
    if (_selectedSubcategory?.isTierra == true) {
      if (_granulometriaController.text.isNotEmpty) {
        specs['granulometria'] = _granulometriaController.text;
      }
      if (_densidadController.text.isNotEmpty) {
        specs['densidad'] = _densidadController.text;
      }
    }
    
    return specs.isNotEmpty ? specs : null;
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simular guardado
    await Future.delayed(const Duration(seconds: 1));

    final specs = _buildSpecifications();
    final dimensions = _buildDimensionsString();
    final peso = _pesoController.text.isEmpty ? null : double.tryParse(_pesoController.text);

    final item = InventoryItem(
      id: widget.existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      companyId: 'company1', // En producción vendría del auth
      name: _nameController.text,
      category: _selectedCategory,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit,
      minStock: double.parse(_minStockController.text),
      location: _locationController.text,
      lastUpdated: DateTime.now(),
      supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
      cost: _costController.text.isEmpty ? null : double.parse(_costController.text),
      status: InventoryStatus.disponible,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      // Nuevos campos
      subcategory: _selectedSubcategory?.code,
      specifications: specs,
      dimensions: dimensions.isNotEmpty ? dimensions : null,
      weightPerUnit: peso,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingItem != null 
                ? 'Item actualizado exitosamente' 
                : 'Item agregado exitosamente',
          ),
          backgroundColor: AppColorsUnified.success,
        ),
      );
    }
  }
}
