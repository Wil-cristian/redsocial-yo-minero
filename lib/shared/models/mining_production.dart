/// Modelo de producción minera
/// Representa datos de extracción y producción de minerales
class MiningProduction {
  final String id;
  final String companyId;
  final String zoneName; // Nombre de la zona minera
  final String mineralType; // Oro, Plata, Cobre, Hierro, etc.
  final double tonnage; // Toneladas extraídas
  final double purity; // Pureza del mineral (0-100%)
  final double grade; // Ley del mineral (gramos por tonelada para metales preciosos)
  final DateTime productionDate;
  final String shift; // Turno: morning, afternoon, night
  final int workersCount; // Cantidad de trabajadores en el turno
  final String status; // active, completed, paused
  final Map<String, dynamic>? metadata; // Datos adicionales
  final DateTime createdAt;

  MiningProduction({
    required this.id,
    required this.companyId,
    required this.zoneName,
    required this.mineralType,
    required this.tonnage,
    required this.purity,
    required this.grade,
    required this.productionDate,
    required this.shift,
    required this.workersCount,
    required this.status,
    this.metadata,
    required this.createdAt,
  });

  /// Crear desde JSON (Supabase)
  factory MiningProduction.fromJson(Map<String, dynamic> json) {
    return MiningProduction(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      zoneName: json['zone_name'] as String,
      mineralType: json['mineral_type'] as String,
      tonnage: (json['tonnage'] as num).toDouble(),
      purity: (json['purity'] as num).toDouble(),
      grade: (json['grade'] as num).toDouble(),
      productionDate: DateTime.parse(json['production_date'] as String),
      shift: json['shift'] as String,
      workersCount: json['workers_count'] as int,
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'zone_name': zoneName,
      'mineral_type': mineralType,
      'tonnage': tonnage,
      'purity': purity,
      'grade': grade,
      'production_date': productionDate.toIso8601String(),
      'shift': shift,
      'workers_count': workersCount,
      'status': status,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Calcular valor estimado (toneladas * pureza * ley)
  double get estimatedValue {
    return tonnage * (purity / 100) * grade;
  }

  /// Obtener nombre del turno en español
  String get shiftDisplayName {
    switch (shift) {
      case 'morning':
        return 'Mañana';
      case 'afternoon':
        return 'Tarde';
      case 'night':
        return 'Noche';
      default:
        return shift;
    }
  }

  /// Obtener color por tipo de mineral
  String get mineralColor {
    switch (mineralType.toLowerCase()) {
      case 'oro':
      case 'gold':
        return '#FFD700';
      case 'plata':
      case 'silver':
        return '#C0C0C0';
      case 'cobre':
      case 'copper':
        return '#B87333';
      case 'hierro':
      case 'iron':
        return '#808080';
      case 'carbón':
      case 'coal':
        return '#1A1A1A';
      case 'zinc':
        return '#7F8487';
      case 'plomo':
      case 'lead':
        return '#2F4F4F';
      default:
        return '#8B4513';
    }
  }

  /// Copiar con modificaciones
  MiningProduction copyWith({
    String? id,
    String? companyId,
    String? zoneName,
    String? mineralType,
    double? tonnage,
    double? purity,
    double? grade,
    DateTime? productionDate,
    String? shift,
    int? workersCount,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return MiningProduction(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      zoneName: zoneName ?? this.zoneName,
      mineralType: mineralType ?? this.mineralType,
      tonnage: tonnage ?? this.tonnage,
      purity: purity ?? this.purity,
      grade: grade ?? this.grade,
      productionDate: productionDate ?? this.productionDate,
      shift: shift ?? this.shift,
      workersCount: workersCount ?? this.workersCount,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Estadísticas agregadas de producción
class ProductionStats {
  final double totalTonnage;
  final double averagePurity;
  final double averageGrade;
  final int totalRecords;
  final Map<String, double> byMineral; // Toneladas por tipo de mineral
  final Map<String, double> byZone; // Toneladas por zona
  final Map<String, double> byShift; // Toneladas por turno

  ProductionStats({
    required this.totalTonnage,
    required this.averagePurity,
    required this.averageGrade,
    required this.totalRecords,
    required this.byMineral,
    required this.byZone,
    required this.byShift,
  });

  factory ProductionStats.empty() {
    return ProductionStats(
      totalTonnage: 0,
      averagePurity: 0,
      averageGrade: 0,
      totalRecords: 0,
      byMineral: {},
      byZone: {},
      byShift: {},
    );
  }
}
