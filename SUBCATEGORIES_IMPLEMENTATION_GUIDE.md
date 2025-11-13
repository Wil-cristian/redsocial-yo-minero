# 🚀 Sistema de Subcategorías - Tubos y Tierras

## ✅ COMPLETADO

### 1. Modelo de Datos
- ✅ Agregados campos: `subcategory`, `specifications`, `dimensions`, `weightPerUnit`
- ✅ Enum `MaterialSubcategory` con 16 opciones:
  - **Tubos**: PVC, Acero, Cobre, Fierro, HDPE
  - **Tierras**: Arena, Grava, Piedra, Tierra Agrícola, Arcilla, Ripio  
  - **Otros**: Cemento, Cal, Yeso

### 2. Base de Datos
- ✅ SQL creado: `database/add_subcategories_specs.sql`
- ✅ Columnas agregadas con índices optimizados
- ✅ Campo JSON para specifications
- ✅ Comentarios y ejemplos de uso

## 🔨 SIGUIENTE PASO: Implementar Formulario

### Ubicación de Cambios
**Archivo**: `lib/company_add_inventory_item_page.dart`

### Cambios Necesarios:

#### 1. Actualizar dispose() (línea ~85)
```dart
@override
void dispose() {
  _nameController.dispose();
  // ... controllers existentes
  _diametroController.dispose();
  _longitudController.dispose();
  _espesorController.dispose();
  _pesoController.dispose();
  _granulometriaController.dispose();
  _densidadController.dispose();
  super.dispose();
}
```

#### 2. Agregar Selector de Subcategoría (después de línea 156)
```dart
if (_selectedCategory == InventoryCategory.material) ...[
  const SizedBox(height: 16),
  _buildSubcategorySelector(),
  const SizedBox(height: 16),
],
```

#### 3. Agregar Campos Dinámicos Según Subcategoría

**Para TUBOS** (después del selector):
```dart
if (_selectedSubcategory != null && _selectedSubcategory!.isTubo) ...[
  _buildSectionHeader('📏 Especificaciones de Tubo', Icons.straighten),
  const SizedBox(height: 16),
  
  // Diámetro
  Row(
    children: [
      Expanded(
        flex: 2,
        child: _buildTextField(
          controller: _diametroController,
          label: 'Diámetro',
          hint: '2',
          icon: Icons.circle_outlined,
          keyboardType: TextInputType.number,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: _diametroUnit,
          items: ['pulgadas', 'mm', 'cm'].map((unit) =>
            DropdownMenuItem(value: unit, child: Text(unit))
          ).toList(),
          onChanged: (val) => setState(() => _diametroUnit = val!),
        ),
      ),
    ],
  ),
  
  // Longitud
  Row(
    children: [
      Expanded(
        flex: 2,
        child: _buildTextField(
          controller: _longitudController,
          label: 'Longitud',
          hint: '6',
          icon: Icons.straighten,
          keyboardType: TextInputType.number,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: _longitudUnit,
          items: ['metros', 'pies', 'cm'].map((unit) =>
            DropdownMenuItem(value: unit, child: Text(unit))
          ).toList(),
          onChanged: (val) => setState(() => _longitudUnit = val!),
        ),
      ),
    ],
  ),
  
  // Espesor
  _buildTextField(
    controller: _espesorController,
    label: 'Espesor/Schedule',
    hint: 'Schedule 40',
    icon: Icons.line_weight,
  ),
  
  const SizedBox(height: 24),
],
```

**Para TIERRAS** (alternativo):
```dart
if (_selectedSubcategory != null && _selectedSubcategory!.isTierra) ...[
  _buildSectionHeader('⛏️ Especificaciones de Material', Icons.landscape),
  const SizedBox(height: 16),
  
  // Granulometría
  _buildTextField(
    controller: _granulometriaController,
    label: 'Granulometría',
    hint: '2-5mm',
    icon: Icons.grain,
  ),
  
  // Densidad
  _buildTextField(
    controller: _densidadController,
    label: 'Densidad',
    hint: '1.6 ton/m³',
    icon: Icons.science,
  ),
  
  const SizedBox(height: 24),
],
```

#### 4. Campo de Peso Universal (para ambos)
```dart
if (_selectedSubcategory != null) ...[
  _buildSectionHeader('⚖️ Información de Peso', Icons.monitor_weight),
  const SizedBox(height: 16),
  
  Row(
    children: [
      Expanded(
        child: _buildTextField(
          controller: _pesoController,
          label: 'Peso por Unidad',
          hint: '8.5',
          icon: Icons.scale,
          keyboardType: TextInputType.number,
          suffix: 'kg',
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
              Text('Peso Total',
                style: TextStyle(fontSize: 12, color: AppColorsUnified.textSecondary)),
              const SizedBox(height: 4),
              Text(
                _calculateTotalWeight(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
  
  const SizedBox(height: 24),
],
```

#### 5. Métodos Auxiliares

```dart
Widget _buildSubcategorySelector() {
  final subcategories = _selectedCategory == InventoryCategory.material
      ? MaterialSubcategory.values
      : <MaterialSubcategory>[];
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tipo Específico',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: subcategories.map((sub) =>
          ChoiceChip(
            label: Text(sub.label),
            selected: _selectedSubcategory == sub,
            onSelected: (selected) {
              setState(() => _selectedSubcategory = selected ? sub : null);
            },
            selectedColor: AppColorsUnified.gold,
            backgroundColor: AppColorsUnified.grey200,
          ),
        ).toList(),
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

Map<String, dynamic> _buildSpecifications() {
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
  
  return specs.isNotEmpty ? specs : {};
}
```

#### 6. Actualizar _saveItem() (línea ~450)

```dart
void _saveItem() {
  // ... validación existente
  
  final specs = _buildSpecifications();
  final dimensions = _buildDimensionsString();
  final peso = double.tryParse(_pesoController.text);
  
  final item = InventoryItem(
    // ... campos existentes
    subcategory: _selectedSubcategory?.code,
    specifications: specs.isNotEmpty ? specs : null,
    dimensions: dimensions.isNotEmpty ? dimensions : null,
    weightPerUnit: peso,
  );
  
  Navigator.pop(context, item);
}
```

## 📊 Ejemplo de Uso

### Usuario agrega Tubo PVC:
1. Selecciona categoría: **Materiales**
2. Selecciona subcategoría: **Tubo PVC**
3. Aparecen campos:
   - Diámetro: `2` pulgadas
   - Longitud: `6` metros
   - Espesor: `Schedule 40`
   - Peso unitario: `8.5` kg
4. Ingresa cantidad: `50` unidades
5. Cálculo automático: **Peso total: 425 kg**
6. Preview: "Tubo PVC 2\" × 6m"

### Usuario agrega Arena:
1. Selecciona categoría: **Materiales**
2. Selecciona subcategoría: **Arena**
3. Aparecen campos:
   - Granulometría: `2-5mm`
   - Densidad: `1.6 ton/m³`
   - Peso unitario: `1600` kg (por m³)
4. Ingresa cantidad: `10` m³
5. Cálculo automático: **Peso total: 16000 kg**

## 🎯 Beneficios

✅ **Interfaz adaptativa**: Muestra solo campos relevantes
✅ **Cálculos automáticos**: Peso total se actualiza en tiempo real
✅ **Búsqueda mejorada**: Filtra por subcategoría y especificaciones
✅ **Datos estructurados**: JSON permite búsquedas avanzadas
✅ **Escalable**: Fácil agregar más subcategorías

## 📝 Siguiente Implementación

¿Quieres que:
1. **Implemente todo el código ahora** (formulario completo funcional)
2. **Solo agregue la sección de tubos** (paso a paso)
3. **Solo agregue la sección de tierras** (paso a paso)
4. **Agregue ambas con ejemplo mínimo** (funcional básico)

**Dime cuál prefieres y lo implemento! 🚀**
