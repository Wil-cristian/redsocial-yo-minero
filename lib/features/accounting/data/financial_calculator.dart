import '../models/financial_metrics.dart';

/// Servicio para cálculos financieros y ratios
class FinancialCalculator {
  
  // ==================== RATIOS DE LIQUIDEZ ====================
  
  /// Current Ratio = Activos Corrientes / Pasivos Corrientes
  /// Indica la capacidad de pagar deudas a corto plazo
  /// Ideal: > 1.5, Excelente: > 2
  static double calculateCurrentRatio({
    required double currentAssets,
    required double currentLiabilities,
  }) {
    if (currentLiabilities == 0) return 0;
    return currentAssets / currentLiabilities;
  }

  /// Quick Ratio = (Activos Corrientes - Inventario) / Pasivos Corrientes
  /// Liquidez sin depender de venta de inventario
  /// Ideal: > 1
  static double calculateQuickRatio({
    required double currentAssets,
    required double inventory,
    required double currentLiabilities,
  }) {
    if (currentLiabilities == 0) return 0;
    return (currentAssets - inventory) / currentLiabilities;
  }

  /// Cash Ratio = Efectivo / Pasivos Corrientes
  /// Capacidad de pagar con efectivo inmediato
  static double calculateCashRatio({
    required double cash,
    required double currentLiabilities,
  }) {
    if (currentLiabilities == 0) return 0;
    return cash / currentLiabilities;
  }

  // ==================== RATIOS DE RENTABILIDAD ====================
  
  /// Margen Bruto = (Ingresos - COGS) / Ingresos * 100
  /// Porcentaje de ganancia después de costos directos
  static double calculateGrossMargin({
    required double revenue,
    required double costOfGoodsSold,
  }) {
    if (revenue == 0) return 0;
    return ((revenue - costOfGoodsSold) / revenue) * 100;
  }

  /// Margen Operativo = Utilidad Operativa / Ingresos * 100
  /// Eficiencia operacional antes de intereses e impuestos
  static double calculateOperatingMargin({
    required double operatingIncome,
    required double revenue,
  }) {
    if (revenue == 0) return 0;
    return (operatingIncome / revenue) * 100;
  }

  /// Margen Neto = Utilidad Neta / Ingresos * 100
  /// Porcentaje final de ganancia
  static double calculateNetMargin({
    required double netIncome,
    required double revenue,
  }) {
    if (revenue == 0) return 0;
    return (netIncome / revenue) * 100;
  }

  /// ROA = Utilidad Neta / Activos Totales * 100
  /// Qué tan bien se usan los activos para generar ganancias
  static double calculateROA({
    required double netIncome,
    required double totalAssets,
  }) {
    if (totalAssets == 0) return 0;
    return (netIncome / totalAssets) * 100;
  }

  /// ROE = Utilidad Neta / Patrimonio * 100
  /// Retorno sobre la inversión de los accionistas
  static double calculateROE({
    required double netIncome,
    required double shareholdersEquity,
  }) {
    if (shareholdersEquity == 0) return 0;
    return (netIncome / shareholdersEquity) * 100;
  }

  /// ROI = (Ganancia - Inversión) / Inversión * 100
  /// Retorno sobre una inversión específica
  static double calculateROI({
    required double gain,
    required double investment,
  }) {
    if (investment == 0) return 0;
    return ((gain - investment) / investment) * 100;
  }

  // ==================== RATIOS DE EFICIENCIA ====================
  
  /// Rotación de Inventario = COGS / Inventario Promedio
  /// Veces que el inventario se vende y repone al año
  static double calculateInventoryTurnover({
    required double costOfGoodsSold,
    required double averageInventory,
  }) {
    if (averageInventory == 0) return 0;
    return costOfGoodsSold / averageInventory;
  }

  /// Días de Inventario = 365 / Rotación de Inventario
  /// Días promedio para vender el inventario
  static double calculateDaysInventory(double inventoryTurnover) {
    if (inventoryTurnover == 0) return 0;
    return 365 / inventoryTurnover;
  }

  /// Rotación de Activos = Ventas Netas / Activos Totales
  /// Eficiencia en usar activos para generar ventas
  static double calculateAssetTurnover({
    required double netSales,
    required double totalAssets,
  }) {
    if (totalAssets == 0) return 0;
    return netSales / totalAssets;
  }

  /// Rotación de Cuentas por Cobrar = Ventas a Crédito / CxC Promedio
  /// Veces que se cobran las cuentas al año
  static double calculateReceivablesTurnover({
    required double creditSales,
    required double averageReceivables,
  }) {
    if (averageReceivables == 0) return 0;
    return creditSales / averageReceivables;
  }

  /// Días de Cobro = 365 / Rotación de CxC
  /// Días promedio para cobrar
  static double calculateDaysSalesOutstanding(double receivablesTurnover) {
    if (receivablesTurnover == 0) return 0;
    return 365 / receivablesTurnover;
  }

  // ==================== RATIOS DE APALANCAMIENTO ====================
  
  /// Deuda a Capital = Deuda Total / Patrimonio
  /// Cuánta deuda hay por cada peso de patrimonio
  static double calculateDebtToEquity({
    required double totalDebt,
    required double shareholdersEquity,
  }) {
    if (shareholdersEquity == 0) return 0;
    return totalDebt / shareholdersEquity;
  }

  /// Deuda a Activos = Deuda Total / Activos Totales
  /// Porcentaje de activos financiados con deuda
  static double calculateDebtToAssets({
    required double totalDebt,
    required double totalAssets,
  }) {
    if (totalAssets == 0) return 0;
    return totalDebt / totalAssets;
  }

  /// Cobertura de Intereses = EBIT / Gastos por Intereses
  /// Capacidad de pagar intereses de deuda
  static double calculateInterestCoverage({
    required double ebit,
    required double interestExpense,
  }) {
    if (interestExpense == 0) return double.infinity;
    return ebit / interestExpense;
  }

  // ==================== KPIs MINEROS ====================
  
  /// Costo por Tonelada = Gastos Totales / Toneladas Extraídas
  static double calculateCostPerTon({
    required double totalExpenses,
    required double tonsExtracted,
  }) {
    if (tonsExtracted == 0) return 0;
    return totalExpenses / tonsExtracted;
  }

  /// Ingreso por Trabajador = Ingresos Totales / Número de Trabajadores
  static double calculateRevenuePerWorker({
    required double totalRevenue,
    required int workerCount,
  }) {
    if (workerCount == 0) return 0;
    return totalRevenue / workerCount;
  }

  /// Eficiencia de Producción = (Producción Real / Producción Esperada) * 100
  static double calculateProductionEfficiency({
    required double actualProduction,
    required double expectedProduction,
  }) {
    if (expectedProduction == 0) return 0;
    return (actualProduction / expectedProduction) * 100;
  }

  /// Utilización de Equipos = (Horas Operativas / Horas Disponibles) * 100
  static double calculateEquipmentUtilization({
    required double operatingHours,
    required double availableHours,
  }) {
    if (availableHours == 0) return 0;
    return (operatingHours / availableHours) * 100;
  }

  // ==================== ANÁLISIS DE TENDENCIAS ====================
  
  /// Calcula el cambio porcentual entre dos valores
  static double calculatePercentageChange({
    required double currentValue,
    required double previousValue,
  }) {
    if (previousValue == 0) {
      return currentValue > 0 ? 100 : 0;
    }
    return ((currentValue - previousValue) / previousValue.abs()) * 100;
  }

  /// Calcula promedio móvil simple
  static double calculateSMA(List<double> values, int period) {
    if (values.isEmpty || period <= 0) return 0;
    final actualPeriod = period > values.length ? values.length : period;
    final subset = values.sublist(values.length - actualPeriod);
    return subset.reduce((a, b) => a + b) / subset.length;
  }

  /// Proyección lineal simple basada en tendencia
  static double projectValue({
    required List<double> historicalValues,
    required int periodsAhead,
  }) {
    if (historicalValues.length < 2) {
      return historicalValues.isEmpty ? 0 : historicalValues.last;
    }

    // Calcular tendencia simple (promedio de cambios)
    double totalChange = 0;
    for (int i = 1; i < historicalValues.length; i++) {
      totalChange += historicalValues[i] - historicalValues[i - 1];
    }
    final avgChange = totalChange / (historicalValues.length - 1);

    return historicalValues.last + (avgChange * periodsAhead);
  }

  // ==================== CÁLCULO DE RATIOS COMPLETOS ====================
  
  /// Genera un objeto FinancialRatios completo
  static FinancialRatios calculateAllRatios({
    required double currentAssets,
    required double currentLiabilities,
    required double inventory,
    required double cash,
    required double revenue,
    required double costOfGoodsSold,
    required double operatingIncome,
    required double netIncome,
    required double totalAssets,
    required double shareholdersEquity,
    required double totalDebt,
    required double interestExpense,
    double? creditSales,
    double? averageReceivables,
  }) {
    final inventoryTurnover = calculateInventoryTurnover(
      costOfGoodsSold: costOfGoodsSold,
      averageInventory: inventory,
    );

    return FinancialRatios(
      // Liquidez
      currentRatio: calculateCurrentRatio(
        currentAssets: currentAssets,
        currentLiabilities: currentLiabilities,
      ),
      quickRatio: calculateQuickRatio(
        currentAssets: currentAssets,
        inventory: inventory,
        currentLiabilities: currentLiabilities,
      ),
      cashRatio: calculateCashRatio(
        cash: cash,
        currentLiabilities: currentLiabilities,
      ),
      
      // Rentabilidad
      grossMargin: calculateGrossMargin(
        revenue: revenue,
        costOfGoodsSold: costOfGoodsSold,
      ),
      operatingMargin: calculateOperatingMargin(
        operatingIncome: operatingIncome,
        revenue: revenue,
      ),
      netMargin: calculateNetMargin(
        netIncome: netIncome,
        revenue: revenue,
      ),
      returnOnAssets: calculateROA(
        netIncome: netIncome,
        totalAssets: totalAssets,
      ),
      returnOnEquity: calculateROE(
        netIncome: netIncome,
        shareholdersEquity: shareholdersEquity,
      ),
      
      // Eficiencia
      inventoryTurnover: inventoryTurnover,
      daysInventory: calculateDaysInventory(inventoryTurnover),
      assetTurnover: calculateAssetTurnover(
        netSales: revenue,
        totalAssets: totalAssets,
      ),
      receivablesTurnover: creditSales != null && averageReceivables != null
          ? calculateReceivablesTurnover(
              creditSales: creditSales,
              averageReceivables: averageReceivables,
            )
          : 0,
      
      // Apalancamiento
      debtToEquity: calculateDebtToEquity(
        totalDebt: totalDebt,
        shareholdersEquity: shareholdersEquity,
      ),
      debtToAssets: calculateDebtToAssets(
        totalDebt: totalDebt,
        totalAssets: totalAssets,
      ),
      interestCoverage: calculateInterestCoverage(
        ebit: operatingIncome,
        interestExpense: interestExpense,
      ),
    );
  }

  // ==================== UTILIDADES DE FORMATO ====================
  
  /// Formatea un número como moneda
  static String formatCurrency(double value, {String symbol = '\$'}) {
    final absValue = value.abs();
    String formatted;
    
    if (absValue >= 1000000) {
      formatted = '${(absValue / 1000000).toStringAsFixed(2)}M';
    } else if (absValue >= 1000) {
      formatted = '${(absValue / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = absValue.toStringAsFixed(2);
    }
    
    return value < 0 ? '-$symbol$formatted' : '$symbol$formatted';
  }

  /// Formatea un porcentaje
  static String formatPercentage(double value, {int decimals = 1}) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(decimals)}%';
  }

  /// Formatea un ratio
  static String formatRatio(double value, {int decimals = 2}) {
    return '${value.toStringAsFixed(decimals)}x';
  }
}
