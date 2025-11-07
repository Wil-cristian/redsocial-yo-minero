enum TransactionType {
  income,
  expense;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Ingreso';
      case TransactionType.expense:
        return 'Gasto';
    }
  }

  static TransactionType fromString(String type) {
    return type == 'income' ? TransactionType.income : TransactionType.expense;
  }

  String toJson() {
    return this == TransactionType.income ? 'income' : 'expense';
  }
}

class Transaction {
  final String id;
  final String companyId;
  final TransactionType type;
  final String category;
  final double amount;
  final String currency;
  final String description;
  final String? notes;
  final String? projectId;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.companyId,
    required this.type,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    required this.description,
    this.notes,
    this.projectId,
    required this.transactionDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      type: TransactionType.fromString(json['type'] as String),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String,
      notes: json['notes'] as String?,
      projectId: json['project_id'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'type': type.toJson(),
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'notes': notes,
      'project_id': projectId,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'company_id': companyId,
      'type': type.toJson(),
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'notes': notes,
      'project_id': projectId,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    };
  }
}
