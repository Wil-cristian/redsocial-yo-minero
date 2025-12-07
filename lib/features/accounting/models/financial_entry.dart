/// Modelo para entradas financieras (transacciones contables)
/// Representa ingresos, gastos y transferencias

enum EntryType {
  income,   // Ingreso
  expense,  // Gasto
  transfer, // Transferencia entre cuentas
}

enum MiningIncomeCategory {
  goldSale('Venta de Oro', 'gold_sale'),
  silverSale('Venta de Plata', 'silver_sale'),
  copperSale('Venta de Cobre', 'copper_sale'),
  mineralSale('Venta de Minerales', 'mineral_sale'),
  thirdPartyServices('Servicios a Terceros', 'third_party_services'),
  equipmentRental('Alquiler de Equipos', 'equipment_rental'),
  otherIncome('Otros Ingresos', 'other_income');

  final String displayName;
  final String code;
  const MiningIncomeCategory(this.displayName, this.code);

  static MiningIncomeCategory fromCode(String code) {
    return MiningIncomeCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MiningIncomeCategory.otherIncome,
    );
  }
}

enum MiningExpenseCategory {
  // Operativos
  fuel('Combustible', 'fuel', ExpenseGroup.operational),
  explosives('Explosivos', 'explosives', ExpenseGroup.operational),
  chemicals('Químicos y Reactivos', 'chemicals', ExpenseGroup.operational),
  safetyEquipment('Equipo de Protección', 'safety_equipment', ExpenseGroup.operational),
  maintenanceEquipment('Mantenimiento de Equipos', 'maintenance_equipment', ExpenseGroup.operational),
  spareParts('Repuestos', 'spare_parts', ExpenseGroup.operational),
  transport('Transporte', 'transport', ExpenseGroup.operational),
  tools('Herramientas', 'tools', ExpenseGroup.operational),
  
  // Personal
  salaries('Salarios', 'salaries', ExpenseGroup.personnel),
  bonuses('Bonificaciones', 'bonuses', ExpenseGroup.personnel),
  socialSecurity('Seguro Social', 'social_security', ExpenseGroup.personnel),
  training('Capacitación', 'training', ExpenseGroup.personnel),
  benefits('Beneficios', 'benefits', ExpenseGroup.personnel),
  
  // Administrativos
  licenses('Licencias y Permisos', 'licenses', ExpenseGroup.administrative),
  taxes('Impuestos', 'taxes', ExpenseGroup.administrative),
  utilities('Servicios Básicos', 'utilities', ExpenseGroup.administrative),
  rent('Alquiler', 'rent', ExpenseGroup.administrative),
  insurance('Seguros', 'insurance', ExpenseGroup.administrative),
  legal('Servicios Legales', 'legal', ExpenseGroup.administrative),
  accounting('Servicios Contables', 'accounting', ExpenseGroup.administrative),
  
  // Otros
  otherExpense('Otros Gastos', 'other_expense', ExpenseGroup.other);

  final String displayName;
  final String code;
  final ExpenseGroup group;
  const MiningExpenseCategory(this.displayName, this.code, this.group);

  static MiningExpenseCategory fromCode(String code) {
    return MiningExpenseCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MiningExpenseCategory.otherExpense,
    );
  }
  
  static List<MiningExpenseCategory> byGroup(ExpenseGroup group) {
    return MiningExpenseCategory.values.where((e) => e.group == group).toList();
  }
}

enum ExpenseGroup {
  operational('Operativos'),
  personnel('Personal'),
  administrative('Administrativos'),
  other('Otros');

  final String displayName;
  const ExpenseGroup(this.displayName);
}

class FinancialEntry {
  final String id;
  final String companyId;
  final EntryType type;
  final double amount;
  final String category; // Código de categoría
  final String description;
  final DateTime entryDate;
  final String? reference; // Número de factura/recibo
  final String? attachmentUrl; // URL de comprobante
  final String? projectId; // Proyecto asociado (opcional)
  final String? notes;
  final bool isRecurring;
  final String? recurringFrequency; // daily, weekly, monthly, yearly
  final DateTime createdAt;
  final String? createdBy;

  FinancialEntry({
    required this.id,
    required this.companyId,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.entryDate,
    this.reference,
    this.attachmentUrl,
    this.projectId,
    this.notes,
    this.isRecurring = false,
    this.recurringFrequency,
    DateTime? createdAt,
    this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FinancialEntry.fromJson(Map<String, dynamic> json) {
    return FinancialEntry(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      type: EntryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EntryType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      entryDate: DateTime.parse(json['entry_date'] as String),
      reference: json['reference'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      projectId: json['project_id'] as String?,
      notes: json['notes'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringFrequency: json['recurring_frequency'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'type': type.name,
      'amount': amount,
      'category': category,
      'description': description,
      'entry_date': entryDate.toIso8601String().split('T')[0],
      'reference': reference,
      'attachment_url': attachmentUrl,
      'project_id': projectId,
      'notes': notes,
      'is_recurring': isRecurring,
      'recurring_frequency': recurringFrequency,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toInsert() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    return json;
  }

  FinancialEntry copyWith({
    String? id,
    String? companyId,
    EntryType? type,
    double? amount,
    String? category,
    String? description,
    DateTime? entryDate,
    String? reference,
    String? attachmentUrl,
    String? projectId,
    String? notes,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return FinancialEntry(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      entryDate: entryDate ?? this.entryDate,
      reference: reference ?? this.reference,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      projectId: projectId ?? this.projectId,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Obtiene el nombre de la categoría para mostrar
  String get categoryDisplayName {
    if (type == EntryType.income) {
      return MiningIncomeCategory.fromCode(category).displayName;
    } else {
      return MiningExpenseCategory.fromCode(category).displayName;
    }
  }

  /// Alias para la fecha (compatibilidad)
  DateTime get date => entryDate;

  /// Método para obtener nombre de categoría (alias del getter)
  String getCategoryDisplayName() => categoryDisplayName;

  /// Verifica si la entrada es de hoy
  bool get isToday {
    final now = DateTime.now();
    return entryDate.year == now.year &&
        entryDate.month == now.month &&
        entryDate.day == now.day;
  }

  /// Verifica si la entrada es de esta semana
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        entryDate.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Verifica si la entrada es de este mes
  bool get isThisMonth {
    final now = DateTime.now();
    return entryDate.year == now.year && entryDate.month == now.month;
  }
}
