enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  // Income categories
  sales,
  trading,
  harvest,
  livestock,
  
  // Expense categories
  feed,
  fertilizer,
  seeds,
  labor,
  equipment,
  transport,
  utilities,
  other,
}

enum PaymentMethod {
  cash,
  bank,
  mobileMoney,
  card,
  check,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? description;
  final String? reference;
  final PaymentMethod? paymentMethod;
  final String? attachmentPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRecurring;
  final String? recurringFrequency; // daily, weekly, monthly, yearly

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    this.reference,
    this.paymentMethod,
    this.attachmentPath,
    DateTime? createdAt,
    this.updatedAt,
    this.isRecurring = false,
    this.recurringFrequency,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper getters
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  
  String get categoryName {
    switch (category) {
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.trading:
        return 'Trading';
      case TransactionCategory.harvest:
        return 'Harvest';
      case TransactionCategory.livestock:
        return 'Livestock';
      case TransactionCategory.feed:
        return 'Feed';
      case TransactionCategory.fertilizer:
        return 'Fertilizer';
      case TransactionCategory.seeds:
        return 'Seeds';
      case TransactionCategory.labor:
        return 'Labor';
      case TransactionCategory.equipment:
        return 'Equipment';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  String get paymentMethodName {
    if (paymentMethod == null) return 'Not specified';
    switch (paymentMethod!) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bank:
        return 'Bank Transfer';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.check:
        return 'Check';
    }
  }

  // Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'category': category.index,
      'date': date.toIso8601String(),
      'description': description,
      'reference': reference,
      'paymentMethod': paymentMethod?.index,
      'attachmentPath': attachmentPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'recurringFrequency': recurringFrequency,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      category: TransactionCategory.values[map['category']],
      date: DateTime.parse(map['date']),
      description: map['description'],
      reference: map['reference'],
      paymentMethod: map['paymentMethod'] != null 
          ? PaymentMethod.values[map['paymentMethod']] 
          : null,
      attachmentPath: map['attachmentPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
      isRecurring: map['isRecurring'] == 1,
      recurringFrequency: map['recurringFrequency'],
    );
  }

  // Copy with method for updates
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? description,
    String? reference,
    PaymentMethod? paymentMethod,
    String? attachmentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, title: $title, amount: $amount, type: $type, date: $date}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
