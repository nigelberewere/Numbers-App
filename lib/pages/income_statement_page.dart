import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/mock_transaction_repository.dart';
import '../services/transaction_repository.dart';

class IncomeStatementPage extends StatefulWidget {
  final TransactionRepository? repository;

  const IncomeStatementPage({super.key, this.repository});

  @override
  State<IncomeStatementPage> createState() => _IncomeStatementPageState();
}

class _IncomeStatementPageState extends State<IncomeStatementPage> {
  late final TransactionRepository _repository;
  final NumberFormat _currency = NumberFormat.currency(symbol: '\$');
  final NumberFormat _compactCurrency = NumberFormat.compactCurrency(symbol: '\$');

  bool _isLoading = true;
  String? _error;
  IncomeStatementSnapshot? _snapshot;

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
        _snapshot = IncomeStatementSnapshot.fromTransactions(transactions);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load income statement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Statement'),
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
        _buildBreakdownCard(
          title: 'Revenue Breakdown',
          data: snapshot.revenueByCategory,
          accent: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildBreakdownCard(
          title: 'Expense Breakdown',
          data: snapshot.expenseByCategory,
          accent: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildKeyMetrics(snapshot),
        const SizedBox(height: 16),
        _buildTopTransactions('Top Income Transactions', snapshot.topIncomeTransactions, Colors.green),
        const SizedBox(height: 16),
        _buildTopTransactions('Top Expense Transactions', snapshot.topExpenseTransactions, Colors.red),
      ],
    );
  }

  Widget _buildSummaryRow(IncomeStatementSnapshot snapshot) {
    final cards = [
      _SummaryInfo(
        label: 'Total Revenue',
        value: _currency.format(snapshot.totalRevenue),
        color: Colors.green,
        icon: Icons.trending_up,
      ),
      _SummaryInfo(
        label: 'Total Expenses',
        value: _currency.format(snapshot.totalExpenses),
        color: Colors.red,
        icon: Icons.trending_down,
      ),
      _SummaryInfo(
        label: 'Net Profit',
        value: _currency.format(snapshot.netProfit),
        color: snapshot.netProfit >= 0 ? Colors.green : Colors.red,
        icon: Icons.attach_money,
      ),
      _SummaryInfo(
        label: 'Profit Margin',
        value: _formatPercent(snapshot.profitMargin),
        color: Colors.blue,
        icon: Icons.pie_chart_outline,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map((info) => SizedBox(
                width: math.min(MediaQuery.of(context).size.width - 32, 260.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(info.icon, color: info.color, size: 28),
                        const SizedBox(height: 12),
                        Text(info.value,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: info.color, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(info.label),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPeriodBanner(IncomeStatementSnapshot snapshot) {
    final formatter = DateFormat.yMMMMd();

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reporting Period', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '${formatter.format(snapshot.periodStart!)} — ${formatter.format(snapshot.periodEnd!)}',
            ),
            const SizedBox(height: 12),
            Text('Transactions analysed: ${snapshot.transactionCount}',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required Map<String, double> data,
    required Color accent,
  }) {
    final total = data.values.fold<double>(0.0, (sum, value) => sum + value);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('No data available yet')
            else
              ...entries.map((entry) {
                final share = total > 0 ? entry.value / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      Text(_formatPercent(share)),
                      const SizedBox(width: 12),
                      Text(_currency.format(entry.value),
                          style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(IncomeStatementSnapshot snapshot) {
    final metrics = [
      _MetricRow('Average revenue per transaction', _currency.format(snapshot.averageRevenuePerTransaction)),
      _MetricRow('Average expense per transaction', _currency.format(snapshot.averageExpensePerTransaction)),
      _MetricRow('Expense ratio', _formatPercent(snapshot.expenseRatio)),
      _MetricRow('Revenue growth vs prior month', _formatPercent(snapshot.revenueGrowthMoM)),
      _MetricRow('Expense growth vs prior month', _formatPercent(snapshot.expenseGrowthMoM)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Metrics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...metrics.map((metric) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(metric.label)),
                      Text(metric.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTransactions(String title, List<Transaction> transactions, Color accent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Text('No transactions available yet')
            else
              ...transactions.map((transaction) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: accent.withAlpha((0.15 * 255).round()),
                    child: Icon(Icons.receipt_long, color: accent),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(transaction.categoryName),
                  trailing: Text(
                    _compactCurrency.format(transaction.amount),
                    style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatPercent(double value) {
    final percent = (value * 100);
    if (percent.isNaN || percent.isInfinite) {
      return '0%';
    }
    return '${percent.toStringAsFixed(1)}%';
  }
}

class IncomeStatementSnapshot {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final double expenseRatio;
  final double averageRevenuePerTransaction;
  final double averageExpensePerTransaction;
  final double revenueGrowthMoM;
  final double expenseGrowthMoM;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expenseByCategory;
  final List<Transaction> topIncomeTransactions;
  final List<Transaction> topExpenseTransactions;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int transactionCount;

  IncomeStatementSnapshot({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.expenseRatio,
    required this.averageRevenuePerTransaction,
    required this.averageExpensePerTransaction,
    required this.revenueGrowthMoM,
    required this.expenseGrowthMoM,
    required this.revenueByCategory,
    required this.expenseByCategory,
    required this.topIncomeTransactions,
    required this.topExpenseTransactions,
    required this.periodStart,
    required this.periodEnd,
    required this.transactionCount,
  });

  factory IncomeStatementSnapshot.fromTransactions(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return IncomeStatementSnapshot(
        totalRevenue: 0.0,
        totalExpenses: 0.0,
        netProfit: 0.0,
        profitMargin: 0.0,
        expenseRatio: 0.0,
        averageRevenuePerTransaction: 0.0,
        averageExpensePerTransaction: 0.0,
        revenueGrowthMoM: 0.0,
        expenseGrowthMoM: 0.0,
        revenueByCategory: const {},
        expenseByCategory: const {},
        topIncomeTransactions: const [],
        topExpenseTransactions: const [],
        periodStart: null,
        periodEnd: null,
        transactionCount: 0,
      );
    }

    final incomes = transactions.where((t) => t.isIncome).toList();
    final expenses = transactions.where((t) => t.isExpense).toList();

    final totalRevenue = incomes.fold<double>(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);
    final netProfit = totalRevenue - totalExpenses;
    final profitMargin = totalRevenue > 0 ? netProfit / totalRevenue : 0.0;
    final expenseRatio = totalRevenue > 0 ? totalExpenses / totalRevenue : 0.0;

    final averageRevenue = incomes.isNotEmpty ? totalRevenue / incomes.length : 0.0;
    final averageExpense = expenses.isNotEmpty ? totalExpenses / expenses.length : 0.0;

    final revenueByCategory = _groupByCategory(incomes);
    final expenseByCategory = _groupByCategory(expenses);

    final topIncome = List<Transaction>.from(incomes)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final topExpense = List<Transaction>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final periodStart = transactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final periodEnd = transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);

    final revenueGrowthMoM = _monthOverMonthGrowth(transactions, TransactionType.income);
    final expenseGrowthMoM = _monthOverMonthGrowth(transactions, TransactionType.expense);

    return IncomeStatementSnapshot(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      profitMargin: profitMargin,
      expenseRatio: expenseRatio,
      averageRevenuePerTransaction: averageRevenue,
      averageExpensePerTransaction: averageExpense,
      revenueGrowthMoM: revenueGrowthMoM,
      expenseGrowthMoM: expenseGrowthMoM,
      revenueByCategory: revenueByCategory,
      expenseByCategory: expenseByCategory,
      topIncomeTransactions: topIncome.take(5).toList(),
      topExpenseTransactions: topExpense.take(5).toList(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      transactionCount: transactions.length,
    );
  }

  static Map<String, double> _groupByCategory(List<Transaction> transactions) {
    final map = <String, double>{};
    for (final transaction in transactions) {
      map[transaction.categoryName] =
          (map[transaction.categoryName] ?? 0) + transaction.amount;
    }
    return map;
  }

  static double _monthOverMonthGrowth(List<Transaction> transactions, TransactionType type) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    double sumForMonth(DateTime month) {
      return transactions
          .where((t) => t.type == type && t.date.year == month.year && t.date.month == month.month)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    }

    final current = sumForMonth(currentMonth);
    final previous = sumForMonth(previousMonth);

    if (previous == 0) {
      return current == 0 ? 0.0 : 1.0;
    }

    return (current - previous) / previous;
  }
}

class _SummaryInfo {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryInfo({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class _MetricRow {
  final String label;
  final String value;

  const _MetricRow(this.label, this.value);
}
