import 'transaction.dart';

enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

class Budget {
  final String id;
  final String name;
  final TransactionCategory category;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get periodName {
    switch (period) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  Duration get totalDuration => endDate.difference(startDate);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'amount': amount,
      'period': period.index,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      name: map['name'],
      category: TransactionCategory.values[map['category']],
      amount: map['amount'],
      period: BudgetPeriod.values[map['period']],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] == 1,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  Budget copyWith({
    String? id,
    String? name,
    TransactionCategory? category,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Budget{id: $id, name: $name, amount: $amount, period: $periodName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Budget performance tracking
class BudgetProgress {
  final Budget budget;
  final double spent;
  final int transactionCount;

  BudgetProgress({
    required this.budget,
    required this.spent,
    required this.transactionCount,
  });

  double get remaining => budget.amount - spent;
  double get percentageUsed => budget.amount > 0 
      ? (spent / budget.amount) * 100 
      : 0;
  double get percentageRemaining => 100 - percentageUsed;
  
  bool get isOverBudget => spent > budget.amount;
  bool get isNearLimit => percentageUsed >= 80 && percentageUsed < 100;
  
  String get status {
    if (budget.isExpired) return 'Expired';
    if (isOverBudget) return 'Over Budget';
    if (isNearLimit) return 'Near Limit';
    return 'On Track';
  }

  // Average spending per day
  double get averageDailySpending {
    final daysPassed = DateTime.now().difference(budget.startDate).inDays;
    if (daysPassed <= 0) return 0;
    return spent / daysPassed;
  }

  // Projected total spending if current rate continues
  double get projectedTotalSpending {
    final totalDays = budget.totalDuration.inDays;
    if (totalDays <= 0) return spent;
    return averageDailySpending * totalDays;
  }

  // Will we exceed budget at current rate?
  bool get willExceedBudget => projectedTotalSpending > budget.amount;
}
