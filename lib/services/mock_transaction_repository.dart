import '../models/models.dart';
import 'transaction_repository.dart';

/// Mock implementation of TransactionRepository for testing
/// Replace this with FirebaseTransactionRepository when backend is ready
class MockTransactionRepository implements TransactionRepository {
  final List<Transaction> _transactions = [];

  MockTransactionRepository() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    
    // Generate 6 months of sample data
    for (int month = 5; month >= 0; month--) {
      _transactions.addAll([
        // Income transactions
        Transaction(
          id: 'tx_income_${month}_1',
          title: 'Maize Sale',
          amount: 5000 + (month * 500),
          type: TransactionType.income,
          category: TransactionCategory.sales,
          date: DateTime(now.year, now.month - month, 5),
          paymentMethod: PaymentMethod.bank,
        ),
        Transaction(
          id: 'tx_income_${month}_2',
          title: 'Livestock Sale',
          amount: 3000 + (month * 300),
          type: TransactionType.income,
          category: TransactionCategory.livestock,
          date: DateTime(now.year, now.month - month, 15),
          paymentMethod: PaymentMethod.cash,
        ),
        Transaction(
          id: 'tx_income_${month}_3',
          title: 'Harvest Sale',
          amount: 4000 + (month * 400),
          type: TransactionType.income,
          category: TransactionCategory.harvest,
          date: DateTime(now.year, now.month - month, 25),
          paymentMethod: PaymentMethod.mobileMoney,
        ),
        // Expense transactions
        Transaction(
          id: 'tx_expense_${month}_1',
          title: 'Animal Feed',
          amount: 1500 + (month * 100),
          type: TransactionType.expense,
          category: TransactionCategory.feed,
          date: DateTime(now.year, now.month - month, 3),
          paymentMethod: PaymentMethod.cash,
        ),
        Transaction(
          id: 'tx_expense_${month}_2',
          title: 'Fertilizer Purchase',
          amount: 2000 + (month * 150),
          type: TransactionType.expense,
          category: TransactionCategory.fertilizer,
          date: DateTime(now.year, now.month - month, 10),
          paymentMethod: PaymentMethod.bank,
        ),
        Transaction(
          id: 'tx_expense_${month}_3',
          title: 'Farm Labor',
          amount: 1000 + (month * 80),
          type: TransactionType.expense,
          category: TransactionCategory.labor,
          date: DateTime(now.year, now.month - month, 20),
          paymentMethod: PaymentMethod.cash,
        ),
        Transaction(
          id: 'tx_expense_${month}_4',
          title: 'Transport Costs',
          amount: 500 + (month * 50),
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          date: DateTime(now.year, now.month - month, 25),
          paymentMethod: PaymentMethod.cash,
        ),
        Transaction(
          id: 'tx_expense_${month}_5',
          title: 'Seeds Purchase',
          amount: 800 + (month * 60),
          type: TransactionType.expense,
          category: TransactionCategory.seeds,
          date: DateTime(now.year, now.month - month, 12),
          paymentMethod: PaymentMethod.bank,
        ),
      ]);
    }
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return List.from(_transactions);
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transactions
        .where((t) =>
            t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transactions.where((t) => t.type == type).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(
      TransactionCategory category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transactions.where((t) => t.category == category).toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<double> getTotalIncome() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpenses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    final income = await getTotalIncome();
    final expenses = await getTotalExpenses();
    
    final dates = _transactions.map((t) => t.date).toList()..sort();
    final periodStart = dates.isNotEmpty ? dates.first : DateTime.now();
    final periodEnd = dates.isNotEmpty ? dates.last : DateTime.now();
    
    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      netProfit: income - expenses,
      balance: income - expenses,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _transactions
        .where((t) =>
            t.title.toLowerCase().contains(lowercaseQuery) ||
            (t.description?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
}
