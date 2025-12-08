// Modelo para Cuentas por Cobrar y Pagar
import 'package:flutter/material.dart';

enum AccountType {
  receivable, // Por cobrar
  payable,    // Por pagar
}

enum AccountStatus {
  pending,    // Pendiente
  partial,    // Pago parcial
  paid,       // Pagado
  overdue,    // Vencido
  cancelled,  // Cancelado
}

class AccountPayableReceivable {
  final String id;
  final String odooMineId;
  final AccountType type;
  final String contactName;
  final String? contactPhone;
  final String? contactEmail;
  final String description;
  final double totalAmount;
  final double paidAmount;
  final DateTime issueDate;
  final DateTime dueDate;
  final AccountStatus status;
  final String? invoiceNumber;
  final String? notes;
  final List<PaymentRecord> payments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AccountPayableReceivable({
    required this.id,
    required this.odooMineId,
    required this.type,
    required this.contactName,
    this.contactPhone,
    this.contactEmail,
    required this.description,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.issueDate,
    required this.dueDate,
    this.status = AccountStatus.pending,
    this.invoiceNumber,
    this.notes,
    this.payments = const [],
    required this.createdAt,
    this.updatedAt,
  });

  double get remainingAmount => totalAmount - paidAmount;
  
  double get paidPercentage => totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;
  
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != AccountStatus.paid;
  
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  
  int get daysOverdue => isOverdue ? DateTime.now().difference(dueDate).inDays : 0;

  String get statusText {
    switch (status) {
      case AccountStatus.pending:
        return 'Pendiente';
      case AccountStatus.partial:
        return 'Pago Parcial';
      case AccountStatus.paid:
        return 'Pagado';
      case AccountStatus.overdue:
        return 'Vencido';
      case AccountStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color get statusColor {
    switch (status) {
      case AccountStatus.pending:
        return Colors.orange;
      case AccountStatus.partial:
        return Colors.blue;
      case AccountStatus.paid:
        return Colors.green;
      case AccountStatus.overdue:
        return Colors.red;
      case AccountStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case AccountStatus.pending:
        return Icons.schedule;
      case AccountStatus.partial:
        return Icons.pie_chart;
      case AccountStatus.paid:
        return Icons.check_circle;
      case AccountStatus.overdue:
        return Icons.warning;
      case AccountStatus.cancelled:
        return Icons.cancel;
    }
  }

  factory AccountPayableReceivable.fromJson(Map<String, dynamic> json) {
    return AccountPayableReceivable(
      id: json['id'] ?? '',
      odooMineId: json['odoo_mine_id'] ?? '',
      type: json['type'] == 'receivable' ? AccountType.receivable : AccountType.payable,
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      description: json['description'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      issueDate: DateTime.parse(json['issue_date'] ?? DateTime.now().toIso8601String()),
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: _parseStatus(json['status']),
      invoiceNumber: json['invoice_number'],
      notes: json['notes'],
      payments: (json['payments'] as List<dynamic>?)
          ?.map((p) => PaymentRecord.fromJson(p))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'odoo_mine_id': odooMineId,
      'type': type == AccountType.receivable ? 'receivable' : 'payable',
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'description': description,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status.name,
      'invoice_number': invoiceNumber,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static AccountStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return AccountStatus.pending;
      case 'partial':
        return AccountStatus.partial;
      case 'paid':
        return AccountStatus.paid;
      case 'overdue':
        return AccountStatus.overdue;
      case 'cancelled':
        return AccountStatus.cancelled;
      default:
        return AccountStatus.pending;
    }
  }

  AccountPayableReceivable copyWith({
    String? id,
    String? odooMineId,
    AccountType? type,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? description,
    double? totalAmount,
    double? paidAmount,
    DateTime? issueDate,
    DateTime? dueDate,
    AccountStatus? status,
    String? invoiceNumber,
    String? notes,
    List<PaymentRecord>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountPayableReceivable(
      id: id ?? this.id,
      odooMineId: odooMineId ?? this.odooMineId,
      type: type ?? this.type,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentRecord {
  final String id;
  final String accountId;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? reference;
  final String? notes;
  final DateTime createdAt;

  PaymentRecord({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.reference,
    this.notes,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? '',
      accountId: json['account_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] ?? DateTime.now().toIso8601String()),
      paymentMethod: json['payment_method'],
      reference: json['reference'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'reference': reference,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Resumen de cuentas
class AccountsSummary {
  final double totalReceivable;
  final double totalPayable;
  final double overdueReceivable;
  final double overduePayable;
  final int countReceivable;
  final int countPayable;
  final int countOverdue;

  AccountsSummary({
    required this.totalReceivable,
    required this.totalPayable,
    required this.overdueReceivable,
    required this.overduePayable,
    required this.countReceivable,
    required this.countPayable,
    required this.countOverdue,
  });

  double get netPosition => totalReceivable - totalPayable;
  
  double get totalOverdue => overdueReceivable + overduePayable;
}
