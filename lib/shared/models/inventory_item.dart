
/// Modelo de datos para items del inventario empresarial
/// Soporta diferentes tipos de items: herramientas, equipos, materiales, repuestos
class InventoryItem {
  final String id;
  final String companyId;
  final String name;
  final InventoryCategory category;
  final double quantity;
  final String unit; // kg, unidades, litros, m3, toneladas, etc.
  final double minStock; // Stock mínimo antes de alerta
  final String location; // Almacén, bodega, ubicación física
  final DateTime lastUpdated;
  final String? supplier; // Proveedor opcional
  final double? cost; // Costo unitario opcional
  final InventoryStatus status;
  final String? description;
  final String? imageUrl;
  final bool isFavorite;
  final int requestCount; // Contador de veces que se ha solicitado
  
  // Nuevos campos para especificaciones técnicas
  final String? subcategory; // 'tubo_pvc', 'tubo_acero', 'tierra_arena', etc.
  final Map<String, dynamic>? specifications; // JSON con specs técnicas
  final String? dimensions; // "2\" x 6m" o "10m³"
  final double? weightPerUnit; // Peso por unidad en kg

  InventoryItem({
    required this.id,
    required this.companyId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    required this.location,
    required this.lastUpdated,
    this.supplier,
    this.cost,
    required this.status,
    this.description,
    this.imageUrl,
    this.isFavorite = false,
    this.requestCount = 0,
    this.subcategory,
    this.specifications,
    this.dimensions,
    this.weightPerUnit,
  });

  /// Calcula el status automáticamente basado en quantity vs minStock
  InventoryStatus get calculatedStatus {
    if (quantity <= 0) return InventoryStatus.agotado;
    if (quantity <= minStock) return InventoryStatus.critico;
    if (quantity <= minStock * 1.5) return InventoryStatus.bajo;
    return InventoryStatus.disponible;
  }

  /// Valor total del stock (quantity * cost)
  double get totalValue => (cost ?? 0) * quantity;

  /// Porcentaje de stock disponible vs mínimo
  double get stockPercentage {
    if (minStock == 0) return 100;
    return (quantity / minStock * 100).clamp(0, 200);
  }

  /// Indica si necesita reposición urgente
  bool get needsRestock => calculatedStatus == InventoryStatus.critico || 
                            calculatedStatus == InventoryStatus.agotado;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      category: InventoryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => InventoryCategory.material,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      minStock: (json['min_stock'] as num).toDouble(),
      location: json['location'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      supplier: json['supplier'] as String?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      status: InventoryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InventoryStatus.disponible,
      ),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      requestCount: json['request_count'] as int? ?? 0,
      subcategory: json['subcategory'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      dimensions: json['dimensions'] as String?,
      weightPerUnit: json['weight_per_unit'] != null ? (json['weight_per_unit'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'min_stock': minStock,
      'location': location,
      'last_updated': lastUpdated.toIso8601String(),
      'supplier': supplier,
      'cost': cost,
      'status': status.name,
      'description': description,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
      'request_count': requestCount,
      'subcategory': subcategory,
      'specifications': specifications,
      'dimensions': dimensions,
      'weight_per_unit': weightPerUnit,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? companyId,
    String? name,
    InventoryCategory? category,
    double? quantity,
    String? unit,
    double? minStock,
    String? location,
    DateTime? lastUpdated,
    String? supplier,
    double? cost,
    InventoryStatus? status,
    String? description,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minStock: minStock ?? this.minStock,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      supplier: supplier ?? this.supplier,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Categorías de items del inventario
enum InventoryCategory {
  herramienta('Herramientas', 'build'),
  equipo('Equipos', 'precision_manufacturing'),
  material('Materiales', 'inventory_2'),
  repuesto('Repuestos', 'settings_suggest'),
  consumible('Consumibles', 'battery_charging_full'),
  seguridad('Seguridad', 'security');

  final String label;
  final String iconName;
  
  const InventoryCategory(this.label, this.iconName);
}

/// Estados posibles del inventario
enum InventoryStatus {
  disponible('Disponible', 'check_circle'),
  bajo('Stock Bajo', 'warning'),
  critico('Crítico', 'error'),
  agotado('Agotado', 'cancel');

  final String label;
  final String iconName;
  
  const InventoryStatus(this.label, this.iconName);
}

/// Subcategorías de materiales
enum MaterialSubcategory {
  // Tubos
  tuboPVC('Tubo PVC', 'pvc'),
  tuboAcero('Tubo Acero', 'acero'),
  tuboCobre('Tubo Cobre', 'cobre'),
  tuboFierro('Tubo Fierro', 'fierro'),
  tuboHDPE('Tubo HDPE', 'hdpe'),
  
  // Tierras y Agregados
  arena('Arena', 'arena'),
  grava('Grava', 'grava'),
  piedra('Piedra', 'piedra'),
  tierraAgricola('Tierra Agrícola', 'tierra'),
  arcilla('Arcilla', 'arcilla'),
  ripio('Ripio', 'ripio'),
  
  // Otros materiales comunes
  cemento('Cemento', 'cemento'),
  cal('Cal', 'cal'),
  yeso('Yeso', 'yeso'),
  otro('Otro', 'otro');

  final String label;
  final String code;
  
  const MaterialSubcategory(this.label, this.code);
  
  /// Retorna si es un tipo de tubo
  bool get isTubo => code.contains('pvc') || code.contains('acero') || 
                     code.contains('cobre') || code.contains('fierro') || code.contains('hdpe');
  
  /// Retorna si es tierra/agregado
  bool get isTierra => ['arena', 'grava', 'piedra', 'tierra', 'arcilla', 'ripio'].contains(code);
}

/// Modelo para movimientos de inventario (entradas/salidas)
class InventoryMovement {
  final String id;
  final String itemId;
  final InventoryMovementType type;
  final double quantity;
  final DateTime date;
  final String? responsibleUserId;
  final String? reason;

  InventoryMovement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.date,
    this.responsibleUserId,
    this.reason,
  });

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      type: InventoryMovementType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      quantity: (json['quantity'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      responsibleUserId: json['responsible_user_id'] as String?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'type': type.name,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'responsible_user_id': responsibleUserId,
      'reason': reason,
    };
  }
}

/// Tipos de movimientos de inventario
enum InventoryMovementType {
  entrada('Entrada', 'add_circle', 'Nueva adquisición o reposición'),
  salida('Salida', 'remove_circle', 'Consumo o uso'),
  ajuste('Ajuste', 'edit', 'Corrección de inventario'),
  transferencia('Transferencia', 'swap_horiz', 'Entre ubicaciones'),
  devolucion('Devolución', 'undo', 'Retorno al inventario'),
  merma('Merma', 'trending_down', 'Pérdida o deterioro');

  final String label;
  final String iconName;
  final String description;
  
  const InventoryMovementType(this.label, this.iconName, this.description);
}
