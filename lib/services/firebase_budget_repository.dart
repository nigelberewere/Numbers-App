import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/models.dart';
import 'budget_repository.dart';

class FirebaseBudgetRepository implements BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseBudgetRepository({required this.userId});

  // Collection References
  CollectionReference get _budgetsCollection =>
      _firestore.collection('users').doc(userId).collection('budgets');

  CollectionReference get _transactionsCollection =>
      _firestore.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<Budget>> getAllBudgets() async {
    final snapshot =
        await _budgetsCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    final snapshot = await _budgetsCollection
        .where('isActive', isEqualTo: 1)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Budget>> getBudgetsByCategory(
      TransactionCategory category) async {
    final snapshot = await _budgetsCollection
        .where('category', isEqualTo: category.index)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Budget>> getBudgetsByPeriod(BudgetPeriod period) async {
    final snapshot = await _budgetsCollection
        .where('period', isEqualTo: period.index)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final doc = await _budgetsCollection.doc(id).get();
    if (!doc.exists) return null;
    return Budget.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addBudget(Budget budget) async {
    await _budgetsCollection.doc(budget.id).set(budget.toMap());
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _budgetsCollection.doc(budget.id).update(
          budget.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _budgetsCollection.doc(id).delete();
  }

  // --- Budget Progress ---

  Future<double> _calculateSpent(
      TransactionCategory category, DateTime start, DateTime end) async {
    final snapshot = await _transactionsCollection
        .where('category', isEqualTo: category.index)
        .where('type', isEqualTo: TransactionType.expense.index)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .get();

    final transactions = snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return transactions.fold<double>(0.0, (prev, t) => prev + t.amount);
  }

  Future<int> _countTransactions(
      TransactionCategory category, DateTime start, DateTime end) async {
    final snapshot = await _transactionsCollection
        .where('category', isEqualTo: category.index)
        .where('type', isEqualTo: TransactionType.expense.index)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<BudgetProgress> getBudgetProgress(String budgetId) async {
    final budget = await getBudgetById(budgetId);
    if (budget == null) {
      throw Exception('Budget not found');
    }

    final spent =
        await _calculateSpent(budget.category, budget.startDate, budget.endDate);
    final count = await _countTransactions(
        budget.category, budget.startDate, budget.endDate);

    return BudgetProgress(
      budget: budget,
      spent: spent,
      transactionCount: count,
    );
  }

  @override
  Future<List<BudgetProgress>> getAllBudgetProgress() async {
    final budgets = await getActiveBudgets();
    final List<BudgetProgress> progressList = [];

    for (var budget in budgets) {
      final spent = await _calculateSpent(
          budget.category, budget.startDate, budget.endDate);
      final count = await _countTransactions(
          budget.category, budget.startDate, budget.endDate);
      progressList.add(BudgetProgress(
        budget: budget,
        spent: spent,
        transactionCount: count,
      ));
    }

    return progressList;
  }

  @override
  Future<List<BudgetProgress>> getBudgetsNearLimit() async {
    final allProgress = await getAllBudgetProgress();
    return allProgress.where((p) => p.isNearLimit).toList();
  }

  @override
  Future<List<BudgetProgress>> getOverBudgets() async {
    final allProgress = await getAllBudgetProgress();
    return allProgress.where((p) => p.isOverBudget).toList();
  }

  @override
  Future<bool> isOverBudget(TransactionCategory category) async {
    // Find active budgets for this category
    final budgets = await getBudgetsByCategory(category);
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    if (activeBudgets.isEmpty) return false;

    for (var budget in activeBudgets) {
      final spent = await _calculateSpent(
          budget.category, budget.startDate, budget.endDate);
      if (spent > budget.amount) return true;
    }

    return false;
  }

  @override
  Future<double> getRemainingBudget(TransactionCategory category) async {
    final budgets = await getBudgetsByCategory(category);
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    if (activeBudgets.isEmpty) return 0;

    double totalRemaining = 0;
    for (var budget in activeBudgets) {
      final spent = await _calculateSpent(
          budget.category, budget.startDate, budget.endDate);
      final remaining = budget.amount - spent;
      if (remaining > 0) totalRemaining += remaining;
    }

    return totalRemaining;
  }
}
