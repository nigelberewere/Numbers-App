import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/models.dart';
import 'transaction_repository.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseTransactionRepository({required this.userId});

  CollectionReference get _collection =>
      _firestore.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final snapshot = await _collection.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _collection.doc(transaction.id).set(transaction.toMap());
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _collection
        .doc(transaction.id)
        .update(transaction.copyWith(updatedAt: DateTime.now()).toMap());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Transaction.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    final snapshot = await _collection
        .where('type', isEqualTo: type.index)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<double> getTotalIncome() async {
    final transactions = await getTransactionsByType(TransactionType.income);
    return transactions.fold<double>(0.0, (prev, t) => prev + t.amount);
  }

  @override
  Future<double> getTotalExpenses() async {
    final transactions = await getTransactionsByType(TransactionType.expense);
    return transactions.fold<double>(0.0, (prev, t) => prev + t.amount);
  }

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    final income = await getTotalIncome();
    final expenses = await getTotalExpenses();

    // For period start/end, we'd ideally query the first and last transaction
    // But for now, let's just use current time as placeholder or fetch all
    // Fetching all just for dates is expensive, so let's skip precise dates for summary for now
    // or implement a separate metadata document that tracks min/max dates.

    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      netProfit: income - expenses,
      balance: income - expenses,
      periodStart: DateTime.now(), // Placeholder
      periodEnd: DateTime.now(), // Placeholder
    );
  }

  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    // Note: Firestore doesn't support full-text search natively
    // We'll fetch all and filter client-side for now (not scalable for huge datasets but fine for MVP)
    final all = await getAllTransactions();
    final lowercaseQuery = query.toLowerCase();
    return all
        .where(
          (t) =>
              t.title.toLowerCase().contains(lowercaseQuery) ||
              (t.description?.toLowerCase().contains(lowercaseQuery) ?? false),
        )
        .toList();
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    final snapshot = await _collection
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(
    TransactionCategory category,
  ) async {
    final snapshot = await _collection
        .where('category', isEqualTo: category.index)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Stream for real-time updates
  Stream<List<Transaction>> transactionsStream() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Transaction.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }
}
