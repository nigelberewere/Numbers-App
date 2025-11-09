import '../models/models.dart';

/// Abstract repository interface for Budget data
/// Backend developer should implement this with Firebase
abstract class BudgetRepository {
  /// Get all budgets
  Future<List<Budget>> getAllBudgets();

  /// Get active budgets
  Future<List<Budget>> getActiveBudgets();

  /// Get budgets by category
  Future<List<Budget>> getBudgetsByCategory(TransactionCategory category);

  /// Get budgets by period
  Future<List<Budget>> getBudgetsByPeriod(BudgetPeriod period);

  /// Get a single budget by ID
  Future<Budget?> getBudgetById(String id);

  /// Add a new budget
  Future<void> addBudget(Budget budget);

  /// Update an existing budget
  Future<void> updateBudget(Budget budget);

  /// Delete a budget
  Future<void> deleteBudget(String id);

  /// Get budget progress with spending data
  Future<BudgetProgress> getBudgetProgress(String budgetId);

  /// Get all budget progress reports
  Future<List<BudgetProgress>> getAllBudgetProgress();

  /// Get budgets that are near limit (80%+ spent)
  Future<List<BudgetProgress>> getBudgetsNearLimit();

  /// Get over-budget budgets
  Future<List<BudgetProgress>> getOverBudgets();

  /// Check if spending exceeds budget for a category
  Future<bool> isOverBudget(TransactionCategory category);

  /// Get remaining budget for a category
  Future<double> getRemainingBudget(TransactionCategory category);
}
