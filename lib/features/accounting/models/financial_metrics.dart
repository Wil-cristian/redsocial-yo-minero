/// Modelo para ratios y métricas financieras
/// Contiene todos los cálculos de indicadores clave

class FinancialRatios {
  // Liquidez
  final double currentRatio;      // Activo Corriente / Pasivo Corriente
  final double quickRatio;        // (Activo Corriente - Inventario) / Pasivo Corriente
  final double cashRatio;         // Efectivo / Pasivo Corriente

  // Rentabilidad
  final double grossMargin;       // (Ingresos - COGS) / Ingresos * 100
  final double operatingMargin;   // Utilidad Operativa / Ingresos * 100
  final double netMargin;         // Utilidad Neta / Ingresos * 100
  final double returnOnAssets;    // Utilidad Neta / Activos Totales * 100
  final double returnOnEquity;    // Utilidad Neta / Patrimonio * 100

  // Eficiencia
  final double inventoryTurnover;    // COGS / Inventario Promedio
  final double daysInventory;        // 365 / Rotación Inventario
  final double assetTurnover;        // Ventas / Activos Totales
  final double receivablesTurnover;  // Ventas a Crédito / CxC

  // Apalancamiento
  final double debtToEquity;      // Deuda Total / Patrimonio
  final double debtToAssets;      // Deuda Total / Activos
  final double interestCoverage;  // EBIT / Gastos por Intereses

  FinancialRatios({
    this.currentRatio = 0,
    this.quickRatio = 0,
    this.cashRatio = 0,
    this.grossMargin = 0,
    this.operatingMargin = 0,
    this.netMargin = 0,
    this.returnOnAssets = 0,
    this.returnOnEquity = 0,
    this.inventoryTurnover = 0,
    this.daysInventory = 0,
    this.assetTurnover = 0,
    this.receivablesTurnover = 0,
    this.debtToEquity = 0,
    this.debtToAssets = 0,
    this.interestCoverage = 0,
  });

  /// Evalúa el estado del Current Ratio
  RatioStatus get currentRatioStatus {
    if (currentRatio >= 2) return RatioStatus.excellent;
    if (currentRatio >= 1.5) return RatioStatus.good;
    if (currentRatio >= 1) return RatioStatus.acceptable;
    return RatioStatus.critical;
  }

  /// Evalúa el estado del margen neto
  RatioStatus get netMarginStatus {
    if (netMargin >= 20) return RatioStatus.excellent;
    if (netMargin >= 10) return RatioStatus.good;
    if (netMargin >= 5) return RatioStatus.acceptable;
    return RatioStatus.critical;
  }

  /// Evalúa el ROE
  RatioStatus get roeStatus {
    if (returnOnEquity >= 20) return RatioStatus.excellent;
    if (returnOnEquity >= 15) return RatioStatus.good;
    if (returnOnEquity >= 10) return RatioStatus.acceptable;
    return RatioStatus.critical;
  }

  /// Evalúa la deuda
  RatioStatus get debtStatus {
    if (debtToEquity <= 0.5) return RatioStatus.excellent;
    if (debtToEquity <= 1) return RatioStatus.good;
    if (debtToEquity <= 2) return RatioStatus.acceptable;
    return RatioStatus.critical;
  }

  Map<String, dynamic> toJson() {
    return {
      'current_ratio': currentRatio,
      'quick_ratio': quickRatio,
      'cash_ratio': cashRatio,
      'gross_margin': grossMargin,
      'operating_margin': operatingMargin,
      'net_margin': netMargin,
      'return_on_assets': returnOnAssets,
      'return_on_equity': returnOnEquity,
      'inventory_turnover': inventoryTurnover,
      'days_inventory': daysInventory,
      'asset_turnover': assetTurnover,
      'receivables_turnover': receivablesTurnover,
      'debt_to_equity': debtToEquity,
      'debt_to_assets': debtToAssets,
      'interest_coverage': interestCoverage,
    };
  }
}

enum RatioStatus {
  excellent,
  good,
  acceptable,
  critical,
}

extension RatioStatusExtension on RatioStatus {
  String get displayName {
    switch (this) {
      case RatioStatus.excellent:
        return 'Excelente';
      case RatioStatus.good:
        return 'Bueno';
      case RatioStatus.acceptable:
        return 'Aceptable';
      case RatioStatus.critical:
        return 'Crítico';
    }
  }
}

/// Resumen financiero para el dashboard
class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final double cashBalance;
  final int transactionCount;
  final double incomeChange;     // % cambio vs período anterior
  final double expenseChange;    // % cambio vs período anterior
  final double profitChange;     // % cambio vs período anterior
  final DateTime periodStart;
  final DateTime periodEnd;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.cashBalance,
    required this.transactionCount,
    this.incomeChange = 0,
    this.expenseChange = 0,
    this.profitChange = 0,
    required this.periodStart,
    required this.periodEnd,
  });

  factory FinancialSummary.empty() {
    final now = DateTime.now();
    return FinancialSummary(
      totalIncome: 0,
      totalExpenses: 0,
      netProfit: 0,
      profitMargin: 0,
      cashBalance: 0,
      transactionCount: 0,
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: now,
    );
  }

  /// Calcula el balance (ganancia - pérdida)
  double get balance => totalIncome - totalExpenses;

  /// Alias para compatibilidad
  double get totalExpense => totalExpenses;

  /// Indica si hay ganancia
  bool get isProfit => netProfit > 0;

  /// Porcentaje de gastos sobre ingresos
  double get expenseRatio => totalIncome > 0 ? (totalExpenses / totalIncome * 100) : 0;
}

/// Datos para gráfico de flujo de caja diario
class DailyCashFlow {
  final DateTime date;
  final double income;
  final double expense;
  final double balance;

  DailyCashFlow({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });

  double get netFlow => income - expense;
}

/// Desglose por categoría
class CategoryBreakdown {
  final String category;
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;

  CategoryBreakdown({
    required this.category,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

/// Alerta financiera
class FinancialAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final double? value;
  final double? threshold;
  final DateTime createdAt;
  final bool isRead;

  FinancialAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.value,
    this.threshold,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum AlertType {
  lowCash,           // Efectivo bajo
  overBudget,        // Presupuesto excedido
  invoiceDue,        // Factura por vencer
  invoiceOverdue,    // Factura vencida
  highExpense,       // Gasto alto inusual
  lowLiquidity,      // Liquidez baja
  profitDecline,     // Caída en ganancias
  payrollPending,    // Nómina pendiente
}

enum AlertSeverity {
  info,
  warning,
  critical,
}

/// KPIs específicos de minería
class MiningKPIs {
  final double costPerTon;           // Costo por tonelada extraída
  final double revenuePerWorker;     // Ingreso por trabajador
  final double fuelCostPerTon;       // Costo combustible por tonelada
  final double laborCostPerTon;      // Costo mano de obra por tonelada
  final double equipmentUtilization; // % utilización de equipos
  final double goldPricePerGram;     // Precio promedio oro vendido
  final double productionEfficiency; // % eficiencia de producción
  final double wasteRatio;           // % desperdicio

  MiningKPIs({
    this.costPerTon = 0,
    this.revenuePerWorker = 0,
    this.fuelCostPerTon = 0,
    this.laborCostPerTon = 0,
    this.equipmentUtilization = 0,
    this.goldPricePerGram = 0,
    this.productionEfficiency = 0,
    this.wasteRatio = 0,
  });
}
