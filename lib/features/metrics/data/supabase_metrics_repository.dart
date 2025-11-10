import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/transaction.dart';

class MetricsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== PROJECTS ====================
  
  Future<List<Project>> getCompanyProjects(String companyId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Project.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting company projects: $e');
      return [];
    }
  }

  Future<Project> createProject(Project project) async {
    try {
      final response = await _supabase
          .from('projects')
          .insert(project.toInsert())
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      debugPrint('Error creating project: $e');
      rethrow;
    }
  }

  Future<Project> updateProject(String id, Project project) async {
    try {
      final response = await _supabase
          .from('projects')
          .update(project.toInsert())
          .eq('id', id)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _supabase
          .from('projects')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  // ==================== TRANSACTIONS ====================
  
  Future<List<Transaction>> getCompanyTransactions(String companyId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _supabase
          .from('transactions')
          .select()
          .eq('company_id', companyId);

      if (startDate != null) {
        query = query.gte('transaction_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('transaction_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('transaction_date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting company transactions: $e');
      return [];
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await _supabase
          .from('transactions')
          .insert(transaction.toInsert())
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // ==================== ANALYTICS ====================
  
  Future<Map<String, dynamic>> getCompanyMetrics(String companyId, {String period = 'month'}) async {
    try {
      // Calcular rango de fechas según el período
      final now = DateTime.now();
      DateTime startDate;
      
      switch (period) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'quarter':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default: // month
          startDate = DateTime(now.year, now.month - 1, now.day);
      }

      final transactions = await getCompanyTransactions(
        companyId,
        startDate: startDate,
        endDate: now,
      );

      final projects = await getCompanyProjects(companyId);

      // Calcular métricas
      double totalIncome = 0;
      double totalExpense = 0;
      
      for (var transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      final profit = totalIncome - totalExpense;
      final activeProjects = projects.where((p) => p.status == ProjectStatus.inProgress).length;

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'profit': profit,
        'projects_count': activeProjects,
        'total_projects': projects.length,
        'transactions_count': transactions.length,
      };
    } catch (e) {
      debugPrint('Error getting company metrics: $e');
      return {
        'income': 0.0,
        'expense': 0.0,
        'profit': 0.0,
        'projects_count': 0,
        'total_projects': 0,
        'transactions_count': 0,
      };
    }
  }
}
