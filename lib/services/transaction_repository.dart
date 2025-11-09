import '../models/models.dart';

/// Abstract repository interface for Transaction data
/// Backend developer should implement this with Firebase
abstract class TransactionRepository {
  /// Get all transactions
  Future<List<Transaction>> getAllTransactions();

  /// Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get transactions by type (income/expense)
  Future<List<Transaction>> getTransactionsByType(TransactionType type);

  /// Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(TransactionCategory category);

  /// Get a single transaction by ID
  Future<Transaction?> getTransactionById(String id);

  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction);

  /// Update an existing transaction
  Future<void> updateTransaction(Transaction transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String id);

  /// Get total income
  Future<double> getTotalIncome();

  /// Get total expenses
  Future<double> getTotalExpenses();

  /// Get financial summary
  Future<FinancialSummary> getFinancialSummary();

  /// Search transactions by title or description
  Future<List<Transaction>> searchTransactions(String query);

  /// Get recent transactions (last N transactions)
  Future<List<Transaction>> getRecentTransactions({int limit = 10});
}
