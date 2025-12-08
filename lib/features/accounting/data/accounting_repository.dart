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

  // ==================== PROYECTOS Y DESEMPEÑO ====================

  /// Obtiene el desempeño de proyectos mineros
  Future<List<ProjectPerformance>> getProjectsPerformance(String companyId) async {
    try {
      // Intentar obtener de la tabla financial_budgets como proyectos
      final response = await _supabase
          .from('financial_budgets')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false)
          .limit(10);

      if ((response as List).isEmpty) {
        // Datos de demostración si no hay proyectos
        return _getDemoProjectsPerformance();
      }

      return response.map((json) {
        final budgetAmount = (json['budget_amount'] ?? 0).toDouble();
        final actualAmount = (json['actual_amount'] ?? 0).toDouble();
        final progress = budgetAmount > 0 ? (actualAmount / budgetAmount * 100).clamp(0.0, 100.0) : 0.0;
        
        return ProjectPerformance(
          id: json['id']?.toString() ?? '',
          name: json['category_name'] ?? json['category'] ?? 'Proyecto',
          progress: progress.toDouble(),
          budgetUsed: actualAmount,
          budgetTotal: budgetAmount,
          roi: ((budgetAmount - actualAmount) / budgetAmount * 100),
          daysRemaining: _calculateDaysRemaining(json['end_date']),
          status: _parseProjectStatus(json['status']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting projects performance: $e');
      return _getDemoProjectsPerformance();
    }
  }

  List<ProjectPerformance> _getDemoProjectsPerformance() {
    return [
      ProjectPerformance(
        id: 'proj_1',
        name: 'Extracción Veta Norte',
        progress: 78,
        budgetUsed: 245000,
        budgetTotal: 300000,
        roi: 18.3,
        daysRemaining: 45,
        status: ProjectStatus.active,
      ),
      ProjectPerformance(
        id: 'proj_2',
        name: 'Exploración Sector B',
        progress: 45,
        budgetUsed: 89000,
        budgetTotal: 200000,
        roi: 0,
        daysRemaining: 90,
        status: ProjectStatus.active,
      ),
      ProjectPerformance(
        id: 'proj_3',
        name: 'Procesamiento Mineral',
        progress: 92,
        budgetUsed: 175000,
        budgetTotal: 180000,
        roi: 24.5,
        daysRemaining: 15,
        status: ProjectStatus.active,
      ),
      ProjectPerformance(
        id: 'proj_4',
        name: 'Mantenimiento Equipos',
        progress: 60,
        budgetUsed: 42000,
        budgetTotal: 75000,
        roi: 0,
        daysRemaining: 30,
        status: ProjectStatus.active,
      ),
      ProjectPerformance(
        id: 'proj_5',
        name: 'Ampliación Planta',
        progress: 25,
        budgetUsed: 125000,
        budgetTotal: 500000,
        roi: 0,
        daysRemaining: 180,
        status: ProjectStatus.active,
      ),
    ];
  }

  int _calculateDaysRemaining(dynamic endDate) {
    if (endDate == null) return 0;
    try {
      final end = DateTime.parse(endDate.toString());
      final days = end.difference(DateTime.now()).inDays;
      return days < 0 ? 0 : (days > 999 ? 999 : days);
    } catch (_) {
      return 0;
    }
  }

  ProjectStatus _parseProjectStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return ProjectStatus.completed;
      case 'paused':
        return ProjectStatus.paused;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.active;
    }
  }

  // ==================== EMPLEADOS Y PRODUCTIVIDAD ====================

  /// Obtiene los empleados con mejor productividad
  Future<List<EmployeeProductivity>> getTopEmployees(String companyId, {int limit = 5}) async {
    try {
      // Intentar obtener de nómina
      final response = await _supabase
          .from('payroll_entries')
          .select()
          .eq('company_id', companyId)
          .order('gross_salary', ascending: false)
          .limit(limit);

      if ((response as List).isEmpty) {
        return _getDemoEmployees();
      }

      return response.map((json) {
        final name = json['employee_name'] ?? 'Empleado';
        return EmployeeProductivity(
          id: json['id']?.toString() ?? '',
          name: name,
          position: json['position'] ?? 'Operador',
          avatarInitials: _getInitials(name),
          productivity: (json['productivity'] ?? 85 + (json['gross_salary'] ?? 0) % 15).toDouble().clamp(0.0, 100.0),
          hoursWorked: (json['hours_worked'] ?? 160).toDouble(),
          tasksCompleted: (json['tasks_completed'] ?? 45).toDouble(),
          efficiency: (json['efficiency'] ?? 0.85).toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting top employees: $e');
      return _getDemoEmployees();
    }
  }

  List<EmployeeProductivity> _getDemoEmployees() {
    return [
      EmployeeProductivity(
        id: 'emp_1',
        name: 'Carlos Mendez',
        position: 'Jefe de Operaciones',
        avatarInitials: 'CM',
        productivity: 95,
        hoursWorked: 176,
        tasksCompleted: 52,
        efficiency: 0.95,
      ),
      EmployeeProductivity(
        id: 'emp_2',
        name: 'María Rodriguez',
        position: 'Supervisora de Planta',
        avatarInitials: 'MR',
        productivity: 88,
        hoursWorked: 168,
        tasksCompleted: 48,
        efficiency: 0.88,
      ),
      EmployeeProductivity(
        id: 'emp_3',
        name: 'Ana García',
        position: 'Ingeniera de Procesos',
        avatarInitials: 'AG',
        productivity: 82,
        hoursWorked: 160,
        tasksCompleted: 42,
        efficiency: 0.82,
      ),
      EmployeeProductivity(
        id: 'emp_4',
        name: 'Roberto Salazar',
        position: 'Operador de Equipos',
        avatarInitials: 'RS',
        productivity: 79,
        hoursWorked: 164,
        tasksCompleted: 38,
        efficiency: 0.79,
      ),
      EmployeeProductivity(
        id: 'emp_5',
        name: 'Laura Jiménez',
        position: 'Contadora',
        avatarInitials: 'LJ',
        productivity: 76,
        hoursWorked: 160,
        tasksCompleted: 35,
        efficiency: 0.76,
      ),
    ];
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  // ==================== USO DE RECURSOS ====================

  /// Obtiene el uso de recursos
  Future<List<ResourceUsage>> getResourceUsage(String companyId) async {
    try {
      // Calcular uso de recursos basado en categorías de gastos
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1); // Inicio del mes
      
      final summary = await getSummary(
        companyId,
        startDate: startDate,
        endDate: now,
      );
      final categoryBreakdown = await getCategoryBreakdown(
        companyId,
        type: EntryType.expense,
        startDate: startDate,
        endDate: now,
      );

      if (categoryBreakdown.isEmpty) {
        return _getDemoResourceUsage();
      }

      // Mapear categorías a recursos
      final Map<String, double> resourceTotals = {};
      final totalExpense = summary.totalExpense ?? 1;

      for (final cat in categoryBreakdown) {
        final resource = _mapCategoryToResource(cat.category);
        resourceTotals[resource] = (resourceTotals[resource] ?? 0) + cat.amount;
      }

      final resources = <ResourceUsage>[];
      final resourceNames = {
        'equipos': 'Equipos',
        'mano_obra': 'Mano de Obra',
        'materiales': 'Materiales',
        'servicios': 'Servicios',
        'otros': 'Otros',
      };

      resourceNames.forEach((key, displayName) {
        final used = resourceTotals[key] ?? 0;
        final allocated = totalExpense * _getResourceAllocation(key);
        resources.add(ResourceUsage(
          category: key,
          displayName: displayName,
          usagePercentage: allocated > 0 ? (used / allocated).clamp(0.0, 1.5) : 0.0,
          allocated: allocated,
          used: used,
          available: (allocated - used) < 0 ? 0.0 : (allocated - used),
        ));
      });

      return resources;
    } catch (e) {
      debugPrint('Error getting resource usage: $e');
      return _getDemoResourceUsage();
    }
  }

  String _mapCategoryToResource(String category) {
    switch (category.toLowerCase()) {
      case 'equipment':
      case 'machinery':
      case 'fuel':
        return 'equipos';
      case 'labor':
      case 'salaries':
      case 'payroll':
        return 'mano_obra';
      case 'materials':
      case 'supplies':
      case 'raw_materials':
        return 'materiales';
      case 'services':
      case 'utilities':
      case 'transport':
        return 'servicios';
      default:
        return 'otros';
    }
  }

  double _getResourceAllocation(String resource) {
    switch (resource) {
      case 'equipos':
        return 0.30;
      case 'mano_obra':
        return 0.35;
      case 'materiales':
        return 0.20;
      case 'servicios':
        return 0.10;
      default:
        return 0.05;
    }
  }

  List<ResourceUsage> _getDemoResourceUsage() {
    return [
      ResourceUsage(
        category: 'equipos',
        displayName: 'Equipos',
        usagePercentage: 0.75,
        allocated: 150000,
        used: 112500,
        available: 37500,
      ),
      ResourceUsage(
        category: 'mano_obra',
        displayName: 'Mano de Obra',
        usagePercentage: 0.62,
        allocated: 175000,
        used: 108500,
        available: 66500,
      ),
      ResourceUsage(
        category: 'materiales',
        displayName: 'Materiales',
        usagePercentage: 0.58,
        allocated: 100000,
        used: 58000,
        available: 42000,
      ),
      ResourceUsage(
        category: 'servicios',
        displayName: 'Servicios',
        usagePercentage: 0.40,
        allocated: 50000,
        used: 20000,
        available: 30000,
      ),
    ];
  }

  // ==================== MÉTRICAS DE PUBLICACIONES ====================

  /// Obtiene el resumen de publicaciones del usuario/empresa
  Future<PublicationsSummary> getPublicationsSummary(String userId) async {
    try {
      // Obtener posts del usuario
      final response = await _supabase
          .from('posts')
          .select()
          .eq('author_id', userId);

      final posts = response as List;
      if (posts.isEmpty) {
        return PublicationsSummary();
      }

      // Convertir a PublicationPerformance
      final publications = posts.map((post) => _postToPerformance(post)).toList();

      // Calcular totales
      int totalViews = 0, totalLikes = 0, totalComments = 0, 
          totalChats = 0, totalSales = 0;
      double totalRevenue = 0, engagementSum = 0;
      int activeCount = 0;

      for (var pub in publications) {
        totalViews += pub.views;
        totalLikes += pub.likes;
        totalComments += pub.comments;
        totalChats += pub.chats;
        totalSales += pub.sales;
        totalRevenue += pub.revenue;
        engagementSum += pub.engagementRate;
        if (pub.performanceScore > 0) activeCount++;
      }

      // Ordenar para encontrar tops
      final byViews = List<PublicationPerformance>.from(publications)
        ..sort((a, b) => b.views.compareTo(a.views));
      final byLikes = List<PublicationPerformance>.from(publications)
        ..sort((a, b) => b.likes.compareTo(a.likes));
      final byComments = List<PublicationPerformance>.from(publications)
        ..sort((a, b) => b.comments.compareTo(a.comments));
      final byChats = List<PublicationPerformance>.from(publications)
        ..sort((a, b) => b.chats.compareTo(a.chats));
      final bySales = List<PublicationPerformance>.from(publications)
        ..sort((a, b) => b.sales.compareTo(a.sales));

      return PublicationsSummary(
        totalPublications: publications.length,
        activePublications: activeCount,
        totalViews: totalViews,
        totalLikes: totalLikes,
        totalComments: totalComments,
        totalChats: totalChats,
        totalSales: totalSales,
        totalRevenue: totalRevenue,
        avgEngagement: publications.isNotEmpty 
            ? engagementSum / publications.length 
            : 0,
        mostViewed: byViews.isNotEmpty ? byViews.first : null,
        mostLiked: byLikes.isNotEmpty ? byLikes.first : null,
        mostCommented: byComments.isNotEmpty ? byComments.first : null,
        mostChatted: byChats.isNotEmpty ? byChats.first : null,
        bestSeller: bySales.isNotEmpty && bySales.first.sales > 0 
            ? bySales.first 
            : null,
      );
    } catch (e) {
      debugPrint('Error obteniendo métricas de publicaciones: $e');
      return PublicationsSummary();
    }
  }

  /// Obtiene las top publicaciones por métrica específica
  Future<List<PublicationPerformance>> getTopPublications(
    String userId, {
    String sortBy = 'likes',
    int limit = 5,
  }) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('author_id', userId)
          .order(sortBy, ascending: false)
          .limit(limit);

      return (response as List)
          .map((post) => _postToPerformance(post))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo top publicaciones: $e');
      return [];
    }
  }

  /// Convierte un post a PublicationPerformance
  PublicationPerformance _postToPerformance(Map<String, dynamic> post) {
    final type = _parsePublicationType(post['type']);
    final views = post['views'] ?? 0;
    final likes = post['likes'] ?? 0;
    final comments = post['comments'] ?? 0;
    
    // Calcular engagement
    final engagementRate = views > 0 
        ? ((likes + comments) / views * 100).clamp(0.0, 100.0) 
        : 0.0;
    
    // Calcular score
    int score = 0;
    score += (engagementRate * 0.3).round() as int;
    score += ((likes / 10).round() as int).clamp(0, 30);
    score += ((comments / 5).round() as int).clamp(0, 20);
    score += ((views / 100).round() as int).clamp(0, 20);

    // Obtener imagen
    String? imageUrl;
    if (post['images'] != null && (post['images'] as List).isNotEmpty) {
      imageUrl = post['images'][0];
    } else if (post['image_url'] != null) {
      imageUrl = post['image_url'];
    } else if (post['news_cover_image'] != null) {
      imageUrl = post['news_cover_image'];
    }

    return PublicationPerformance(
      id: post['id'],
      title: post['title'] ?? 'Sin título',
      type: type,
      imageUrl: imageUrl,
      views: views,
      likes: likes,
      comments: comments,
      shares: post['shares'] ?? 0,
      chats: 0, // TODO: Obtener de conversaciones
      saves: 0, // TODO: Obtener de saved_posts
      sales: post['sales_count'] ?? 0,
      revenue: (post['revenue'] ?? 0).toDouble(),
      createdAt: DateTime.parse(post['created_at']),
      engagementRate: engagementRate,
      performanceScore: score.clamp(0, 100),
    );
  }

  PublicationType _parsePublicationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'product': return PublicationType.product;
      case 'service': return PublicationType.service;
      case 'offer': return PublicationType.offer;
      case 'request': return PublicationType.request;
      case 'news': return PublicationType.news;
      case 'poll': return PublicationType.poll;
      default: return PublicationType.community;
    }
  }
}
