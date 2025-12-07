import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/financial_entry.dart';
import '../models/financial_metrics.dart';

/// Repositorio para operaciones de contabilidad en Supabase
class AccountingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== FINANCIAL ENTRIES ====================
  
  /// Obtiene todas las entradas financieras de una empresa
  Future<List<FinancialEntry>> getEntries(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    EntryType? type,
    String? category,
    int? limit,
  }) async {
    try {
      var query = _supabase
          .from('financial_entries')
          .select()
          .eq('company_id', companyId);

      if (startDate != null) {
        query = query.gte('entry_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('entry_date', endDate.toIso8601String().split('T')[0]);
      }
      if (type != null) {
        query = query.eq('type', type.name);
      }
      if (category != null) {
        query = query.eq('category', category);
      }

      var finalQuery = query.order('entry_date', ascending: false);
      
      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      return (response as List)
          .map((json) => FinancialEntry.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting financial entries: $e');
      return [];
    }
  }

  /// Crea una nueva entrada financiera
  Future<FinancialEntry?> createEntry(FinancialEntry entry) async {
    try {
      final response = await _supabase
          .from('financial_entries')
          .insert(entry.toInsert())
          .select()
          .single();

      return FinancialEntry.fromJson(response);
    } catch (e) {
      debugPrint('Error creating financial entry: $e');
      return null;
    }
  }

  /// Actualiza una entrada financiera
  Future<FinancialEntry?> updateEntry(String id, FinancialEntry entry) async {
    try {
      final response = await _supabase
          .from('financial_entries')
          .update(entry.toInsert())
          .eq('id', id)
          .select()
          .single();

      return FinancialEntry.fromJson(response);
    } catch (e) {
      debugPrint('Error updating financial entry: $e');
      return null;
    }
  }

  /// Elimina una entrada financiera
  Future<bool> deleteEntry(String id) async {
    try {
      await _supabase
          .from('financial_entries')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting financial entry: $e');
      return false;
    }
  }

  // ==================== SUMMARIES & ANALYTICS ====================
  
  /// Obtiene resumen financiero de un período
  Future<FinancialSummary> getSummary(
    String companyId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final entries = await getEntries(
        companyId,
        startDate: startDate,
        endDate: endDate,
      );

      double totalIncome = 0;
      double totalExpenses = 0;

      for (var entry in entries) {
        if (entry.type == EntryType.income) {
          totalIncome += entry.amount;
        } else if (entry.type == EntryType.expense) {
          totalExpenses += entry.amount;
        }
      }

      final netProfit = totalIncome - totalExpenses;
      final profitMargin = totalIncome > 0 ? (netProfit / totalIncome * 100).toDouble() : 0.0;

      // Calcular cambios vs período anterior
      final periodDuration = endDate.difference(startDate);
      final prevStartDate = startDate.subtract(periodDuration);
      final prevEndDate = startDate.subtract(const Duration(days: 1));

      final prevEntries = await getEntries(
        companyId,
        startDate: prevStartDate,
        endDate: prevEndDate,
      );

      double prevIncome = 0;
      double prevExpenses = 0;

      for (var entry in prevEntries) {
        if (entry.type == EntryType.income) {
          prevIncome += entry.amount;
        } else if (entry.type == EntryType.expense) {
          prevExpenses += entry.amount;
        }
      }

      final prevProfit = prevIncome - prevExpenses;

      return FinancialSummary(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netProfit: netProfit,
        profitMargin: profitMargin,
        cashBalance: netProfit, // Simplificado, en producción sería acumulado
        transactionCount: entries.length,
        incomeChange: prevIncome > 0 
            ? ((totalIncome - prevIncome) / prevIncome * 100) 
            : 0,
        expenseChange: prevExpenses > 0 
            ? ((totalExpenses - prevExpenses) / prevExpenses * 100) 
            : 0,
        profitChange: prevProfit != 0 
            ? ((netProfit - prevProfit) / prevProfit.abs() * 100) 
            : 0,
        periodStart: startDate,
        periodEnd: endDate,
      );
    } catch (e) {
      debugPrint('Error getting financial summary: $e');
      return FinancialSummary.empty();
    }
  }

  /// Obtiene flujo de caja diario para gráficos
  Future<List<DailyCashFlow>> getDailyCashFlow(
    String companyId, {
    required int days,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final entries = await getEntries(
        companyId,
        startDate: startDate,
        endDate: endDate,
      );

      // Agrupar por día
      final Map<String, DailyCashFlow> dailyData = {};
      
      // Inicializar todos los días con ceros
      for (int i = 0; i <= days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = date.toIso8601String().split('T')[0];
        dailyData[dateKey] = DailyCashFlow(
          date: date,
          income: 0,
          expense: 0,
          balance: 0,
        );
      }

      // Llenar con datos reales
      for (var entry in entries) {
        final dateKey = entry.entryDate.toIso8601String().split('T')[0];
        if (dailyData.containsKey(dateKey)) {
          final current = dailyData[dateKey]!;
          if (entry.type == EntryType.income) {
            dailyData[dateKey] = DailyCashFlow(
              date: current.date,
              income: current.income + entry.amount,
              expense: current.expense,
              balance: current.balance + entry.amount,
            );
          } else if (entry.type == EntryType.expense) {
            dailyData[dateKey] = DailyCashFlow(
              date: current.date,
              income: current.income,
              expense: current.expense + entry.amount,
              balance: current.balance - entry.amount,
            );
          }
        }
      }

      // Calcular balance acumulado
      double runningBalance = 0;
      final sortedKeys = dailyData.keys.toList()..sort();
      for (var key in sortedKeys) {
        final data = dailyData[key]!;
        runningBalance += data.income - data.expense;
        dailyData[key] = DailyCashFlow(
          date: data.date,
          income: data.income,
          expense: data.expense,
          balance: runningBalance,
        );
      }

      return sortedKeys.map((key) => dailyData[key]!).toList();
    } catch (e) {
      debugPrint('Error getting daily cash flow: $e');
      return [];
    }
  }

  /// Obtiene desglose por categoría
  Future<List<CategoryBreakdown>> getCategoryBreakdown(
    String companyId, {
    required DateTime startDate,
    required DateTime endDate,
    required EntryType type,
  }) async {
    try {
      final entries = await getEntries(
        companyId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );

      // Agrupar por categoría
      final Map<String, List<FinancialEntry>> grouped = {};
      double total = 0;

      for (var entry in entries) {
        grouped.putIfAbsent(entry.category, () => []).add(entry);
        total += entry.amount;
      }

      // Crear breakdown
      final List<CategoryBreakdown> breakdown = [];
      for (var category in grouped.keys) {
        final categoryEntries = grouped[category]!;
        final amount = categoryEntries.fold<double>(
          0, 
          (sum, e) => sum + e.amount,
        );
        
        String categoryName;
        if (type == EntryType.income) {
          categoryName = MiningIncomeCategory.fromCode(category).displayName;
        } else {
          categoryName = MiningExpenseCategory.fromCode(category).displayName;
        }

        breakdown.add(CategoryBreakdown(
          category: category,
          categoryName: categoryName,
          amount: amount,
          percentage: total > 0 ? (amount / total * 100) : 0,
          transactionCount: categoryEntries.length,
        ));
      }

      // Ordenar por monto descendente
      breakdown.sort((a, b) => b.amount.compareTo(a.amount));

      return breakdown;
    } catch (e) {
      debugPrint('Error getting category breakdown: $e');
      return [];
    }
  }

  /// Genera alertas financieras
  Future<List<FinancialAlert>> generateAlerts(String companyId) async {
    final alerts = <FinancialAlert>[];
    
    try {
      // Obtener datos del mes actual
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final summary = await getSummary(
        companyId,
        startDate: startOfMonth,
        endDate: now,
      );

      // Alerta: Gastos mayores a ingresos
      if (summary.totalExpenses > summary.totalIncome && summary.totalIncome > 0) {
        alerts.add(FinancialAlert(
          id: 'alert_expense_over_income',
          type: AlertType.highExpense,
          severity: AlertSeverity.critical,
          title: 'Gastos superan ingresos',
          message: 'Los gastos (\$${summary.totalExpenses.toStringAsFixed(2)}) superan los ingresos (\$${summary.totalIncome.toStringAsFixed(2)}) este mes.',
          value: summary.totalExpenses,
          threshold: summary.totalIncome,
        ));
      }

      // Alerta: Margen de ganancia muy bajo
      if (summary.profitMargin < 10 && summary.totalIncome > 0) {
        alerts.add(FinancialAlert(
          id: 'alert_low_margin',
          type: AlertType.profitDecline,
          severity: AlertSeverity.warning,
          title: 'Margen de ganancia bajo',
          message: 'El margen de ganancia es solo ${summary.profitMargin.toStringAsFixed(1)}%. Se recomienda revisar costos.',
          value: summary.profitMargin,
          threshold: 10,
        ));
      }

      // Alerta: Caída en ingresos
      if (summary.incomeChange < -20) {
        alerts.add(FinancialAlert(
          id: 'alert_income_decline',
          type: AlertType.profitDecline,
          severity: AlertSeverity.warning,
          title: 'Caída en ingresos',
          message: 'Los ingresos han disminuido ${summary.incomeChange.abs().toStringAsFixed(1)}% respecto al período anterior.',
          value: summary.incomeChange,
          threshold: -20,
        ));
      }

      // Alerta: Aumento en gastos
      if (summary.expenseChange > 30) {
        alerts.add(FinancialAlert(
          id: 'alert_expense_increase',
          type: AlertType.highExpense,
          severity: AlertSeverity.warning,
          title: 'Aumento en gastos',
          message: 'Los gastos han aumentado ${summary.expenseChange.toStringAsFixed(1)}% respecto al período anterior.',
          value: summary.expenseChange,
          threshold: 30,
        ));
      }

    } catch (e) {
      debugPrint('Error generating alerts: $e');
    }

    return alerts;
  }

  /// Obtiene las últimas transacciones
  Future<List<FinancialEntry>> getRecentTransactions(
    String companyId, {
    int limit = 10,
  }) async {
    return getEntries(companyId, limit: limit);
  }

  /// Busca transacciones por texto
  Future<List<FinancialEntry>> searchTransactions(
    String companyId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('financial_entries')
          .select()
          .eq('company_id', companyId)
          .or('description.ilike.%$query%,reference.ilike.%$query%,notes.ilike.%$query%')
          .order('entry_date', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => FinancialEntry.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error searching transactions: $e');
      return [];
    }
  }
}
