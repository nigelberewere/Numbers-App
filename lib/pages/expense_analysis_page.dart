import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/mock_transaction_repository.dart';
import '../services/transaction_repository.dart';
import '../widgets/expense_pie_chart.dart';

class ExpenseAnalysisPage extends StatefulWidget {
  final TransactionRepository? repository;

  const ExpenseAnalysisPage({super.key, this.repository});

  @override
  State<ExpenseAnalysisPage> createState() => _ExpenseAnalysisPageState();
}

class _ExpenseAnalysisPageState extends State<ExpenseAnalysisPage> {
  late final TransactionRepository _repository;
  final NumberFormat _currency = NumberFormat.currency(symbol: '\$');
  final DateFormat _dateFormat = DateFormat.yMMMd();

  bool _isLoading = true;
  String? _error;
  ExpenseAnalysisSnapshot? _snapshot;
  List<Transaction> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockTransactionRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactions = await _repository.getAllTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _snapshot = ExpenseAnalysisSnapshot.fromTransactions(transactions);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load expense analysis: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final snapshot = _snapshot!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryRow(snapshot),
        if (snapshot.periodStart != null && snapshot.periodEnd != null)
          ...[
            const SizedBox(height: 12),
            _buildPeriodBanner(snapshot),
          ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ExpensePieChart(transactions: _transactions),
          ),
        ),
        const SizedBox(height: 16),
        _buildTopCategories(snapshot),
        const SizedBox(height: 16),
        _buildRecentExpenses(snapshot.recentExpenses),
        const SizedBox(height: 16),
        _buildRecurringExpenses(snapshot.recurringExpenses),
      ],
    );
  }

  Widget _buildSummaryRow(ExpenseAnalysisSnapshot snapshot) {
    final cards = [
      _ExpenseSummary(
        label: 'Total Expenses',
        value: _currency.format(snapshot.totalExpenses),
        icon: Icons.money_off,
        color: Colors.red,
      ),
      _ExpenseSummary(
        label: 'Average Daily Spend',
        value: _currency.format(snapshot.averageDailySpend),
        icon: Icons.calendar_view_week,
        color: Colors.orange,
      ),
      _ExpenseSummary(
        label: 'Top Category',
        value: snapshot.topCategory != null
            ? '${snapshot.topCategory} (${_formatPercent(snapshot.topCategoryShare)})'
            : 'Not enough data',
        icon: Icons.category,
        color: Colors.blue,
      ),
      _ExpenseSummary(
        label: 'Recurring Expenses',
        value: snapshot.recurringExpenses.length.toString(),
        icon: Icons.autorenew,
        color: Colors.purple,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map((card) => SizedBox(
                width: math.min(MediaQuery.of(context).size.width - 32, 260.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(card.icon, color: card.color, size: 28),
                        const SizedBox(height: 12),
                        Text(
                          card.value,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: card.color, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(card.label),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPeriodBanner(ExpenseAnalysisSnapshot snapshot) {
    final formatter = DateFormat.yMMMMd();

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Observation Window', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('${formatter.format(snapshot.periodStart!)} — ${formatter.format(snapshot.periodEnd!)}'),
            const SizedBox(height: 12),
            Text('Expense entries: ${snapshot.expenseCount}',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(ExpenseAnalysisSnapshot snapshot) {
    final entries = snapshot.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = snapshot.totalExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Categories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('No expenses recorded yet')
            else
              ...entries.map((entry) {
                double share = 0.0;
                if (total > 0) {
                  final ratio = entry.value / total;
                  share = ratio.clamp(0.0, 1.0);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text(_currency.format(entry.value),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: share,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 4),
                      Text(_formatPercent(share)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(List<Transaction> expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Expenses', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (expenses.isEmpty)
              const Text('There are no recent expenses to show yet')
            else
              ...expenses.map((expense) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withAlpha((0.12 * 255).round()),
                      child: const Icon(Icons.payments, color: Colors.red),
                    ),
                    title: Text(expense.title),
                    subtitle: Text('${expense.categoryName} • ${_dateFormat.format(expense.date)}'),
                    trailing: Text(
                      _currency.format(expense.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringExpenses(List<Transaction> expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recurring Commitments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (expenses.isEmpty)
              const Text('No recurring expenses found')
            else
              ...expenses.map((expense) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withAlpha((0.12 * 255).round()),
                      child: const Icon(Icons.refresh, color: Colors.purple),
                    ),
                    title: Text(expense.title),
                    subtitle: Text(
                        '${expense.recurringFrequency ?? 'Recurring'} • ${_dateFormat.format(expense.date)}'),
                    trailing: Text(
                      _currency.format(expense.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _formatPercent(double value) {
    final percent = value * 100;
    if (percent.isNaN || percent.isInfinite) {
      return '0%';
    }
    return '${percent.toStringAsFixed(1)}%';
  }
}

class ExpenseAnalysisSnapshot {
  final double totalExpenses;
  final double averageDailySpend;
  final Map<String, double> expensesByCategory;
  final List<Transaction> recentExpenses;
  final List<Transaction> recurringExpenses;
  final String? topCategory;
  final double topCategoryShare;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int expenseCount;

  ExpenseAnalysisSnapshot({
    required this.totalExpenses,
    required this.averageDailySpend,
    required this.expensesByCategory,
    required this.recentExpenses,
    required this.recurringExpenses,
    required this.topCategory,
    required this.topCategoryShare,
    required this.periodStart,
    required this.periodEnd,
    required this.expenseCount,
  });

  factory ExpenseAnalysisSnapshot.fromTransactions(List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    if (expenses.isEmpty) {
      return ExpenseAnalysisSnapshot(
        totalExpenses: 0.0,
        averageDailySpend: 0.0,
        expensesByCategory: const {},
        recentExpenses: const [],
        recurringExpenses: const [],
        topCategory: null,
        topCategoryShare: 0.0,
        periodStart: null,
        periodEnd: null,
        expenseCount: 0,
      );
    }

    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);
    final byCategory = <String, double>{};
    for (final transaction in expenses) {
      byCategory[transaction.categoryName] =
          (byCategory[transaction.categoryName] ?? 0) + transaction.amount;
    }

  final distinctDays = expenses
    .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
    .toSet()
    .length;
  final averageDailySpend = distinctDays > 0 ? totalExpenses / distinctDays : 0.0;

    final recentExpenses = List<Transaction>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recurringExpenses = expenses
        .where((t) => t.isRecurring)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sortedCategories.isEmpty ? null : sortedCategories.first.key;
    final topShare = sortedCategories.isEmpty || totalExpenses == 0
        ? 0.0
        : sortedCategories.first.value / totalExpenses;

    final periodStart = expenses.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final periodEnd = expenses.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);

    return ExpenseAnalysisSnapshot(
      totalExpenses: totalExpenses,
      averageDailySpend: averageDailySpend,
      expensesByCategory: byCategory,
      recentExpenses: recentExpenses.take(5).toList(),
      recurringExpenses: recurringExpenses.take(5).toList(),
      topCategory: topCategory,
      topCategoryShare: topShare,
      periodStart: periodStart,
      periodEnd: periodEnd,
      expenseCount: expenses.length,
    );
  }
}

class _ExpenseSummary {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ExpenseSummary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
