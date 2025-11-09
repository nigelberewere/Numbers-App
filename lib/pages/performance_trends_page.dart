import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/mock_transaction_repository.dart';
import '../services/transaction_repository.dart';
import '../widgets/income_expense_line_chart.dart';
import '../widgets/monthly_comparison_bar_chart.dart';

class PerformanceTrendsPage extends StatefulWidget {
  final TransactionRepository? repository;

  const PerformanceTrendsPage({super.key, this.repository});

  @override
  State<PerformanceTrendsPage> createState() => _PerformanceTrendsPageState();
}

class _PerformanceTrendsPageState extends State<PerformanceTrendsPage> {
  late final TransactionRepository _repository;
  final NumberFormat _currency = NumberFormat.currency(symbol: '\$');
  final DateFormat _monthFormat = DateFormat.yMMM();

  bool _isLoading = true;
  String? _error;
  List<Transaction> _transactions = const [];
  PerformanceTrendsSnapshot? _snapshot;
  DateRange _selectedRange = DateRange.month;

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
        _snapshot = PerformanceTrendsSnapshot.fromTransactions(transactions);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load performance trends: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Trends'),
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
        const SizedBox(height: 16),
        _buildHighlights(snapshot),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MonthlyComparisonBarChart(
              transactions: _transactions,
              monthsToShow: 6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Income vs Expense Trend', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<DateRange>(
                          segments: const [
                            ButtonSegment(value: DateRange.week, label: Text('Week')),
                            ButtonSegment(value: DateRange.month, label: Text('Month')),
                            ButtonSegment(value: DateRange.quarter, label: Text('Quarter')),
                            ButtonSegment(value: DateRange.year, label: Text('Year')),
                          ],
                          selected: {_selectedRange},
                          onSelectionChanged: (selection) {
                            setState(() => _selectedRange = selection.first);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IncomeExpenseLineChart(
                  transactions: _transactions,
                  dateRange: _selectedRange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildMonthlyTable(snapshot),
      ],
    );
  }

  Widget _buildSummaryRow(PerformanceTrendsSnapshot snapshot) {
    final cards = [
      _TrendSummary(
        label: 'Current Month Net',
        value: _currency.format(snapshot.currentMonthNet),
        icon: Icons.stacked_line_chart,
        color: snapshot.currentMonthNet >= 0 ? Colors.green : Colors.red,
      ),
      _TrendSummary(
        label: 'MoM Change',
        value: _currency.format(snapshot.monthOverMonthChange),
        icon: Icons.swap_vert,
        color: snapshot.monthOverMonthChange >= 0 ? Colors.green : Colors.red,
      ),
      _TrendSummary(
        label: 'Best Month',
        value: snapshot.bestMonth != null
            ? '${_monthFormat.format(snapshot.bestMonth!.month)} (${_currency.format(snapshot.bestMonth!.net)})'
            : 'No data',
        icon: Icons.emoji_events,
        color: Colors.blue,
      ),
      _TrendSummary(
        label: 'Worst Month',
        value: snapshot.worstMonth != null
            ? '${_monthFormat.format(snapshot.worstMonth!.month)} (${_currency.format(snapshot.worstMonth!.net)})'
            : 'No data',
        icon: Icons.warning_amber,
        color: Colors.orange,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map((card) => SizedBox(
                width: math.min(MediaQuery.of(context).size.width - 32, 280.0),
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

  Widget _buildHighlights(PerformanceTrendsSnapshot snapshot) {
    final highlights = <String>[
      'Average monthly income ${_currency.format(snapshot.averageMonthlyIncome)}',
      'Average monthly expenses ${_currency.format(snapshot.averageMonthlyExpense)}',
      'Average monthly net ${_currency.format(snapshot.averageMonthlyNet)}',
      if (snapshot.trendDirectionLabel.isNotEmpty)
        snapshot.trendDirectionLabel,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend Highlights', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final item in highlights)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTable(PerformanceTrendsSnapshot snapshot) {
    final rows = snapshot.monthlyTrends;
    if (rows.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Monthly breakdown will appear once enough data is recorded.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 32,
                  dataRowMaxHeight: 40,
                  columns: const [
                    DataColumn(label: Text('Month')),
                    DataColumn(label: Text('Income')),
                    DataColumn(label: Text('Expenses')),
                    DataColumn(label: Text('Net')),
                  ],
                  rows: rows
                      .map((row) => DataRow(cells: [
                            DataCell(Text(_monthFormat.format(row.month))),
                            DataCell(Text(_currency.format(row.income))),
                            DataCell(Text(_currency.format(row.expenses))),
                            DataCell(Text(
                              _currency.format(row.net),
                              style: TextStyle(
                                color: row.net >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                          ]))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceTrendsSnapshot {
  final List<MonthlyTrend> monthlyTrends;
  final MonthlyTrend? bestMonth;
  final MonthlyTrend? worstMonth;
  final MonthlyTrend? currentMonth;
  final MonthlyTrend? previousMonth;
  final double monthOverMonthChange;
  final double currentMonthNet;
  final double averageMonthlyIncome;
  final double averageMonthlyExpense;
  final double averageMonthlyNet;
  final String trendDirectionLabel;

  PerformanceTrendsSnapshot({
    required this.monthlyTrends,
    required this.bestMonth,
    required this.worstMonth,
    required this.currentMonth,
    required this.previousMonth,
    required this.monthOverMonthChange,
    required this.currentMonthNet,
    required this.averageMonthlyIncome,
    required this.averageMonthlyExpense,
    required this.averageMonthlyNet,
    required this.trendDirectionLabel,
  });

  factory PerformanceTrendsSnapshot.fromTransactions(List<Transaction> transactions) {
    const monthsToShow = 6;
    final now = DateTime.now();
    final monthlyMap = <String, MonthlyTrend>{};

    for (int i = monthsToShow - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month}';
      monthlyMap[key] = MonthlyTrend(month: month, income: 0.0, expenses: 0.0);
    }

    for (final transaction in transactions) {
      final key = '${transaction.date.year}-${transaction.date.month}';
      if (monthlyMap.containsKey(key)) {
        final entry = monthlyMap[key]!;
        if (transaction.isIncome) {
          entry.income += transaction.amount;
        } else {
          entry.expenses += transaction.amount;
        }
      }
    }

    final monthlyTrends = monthlyMap.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    MonthlyTrend? bestMonth;
    MonthlyTrend? worstMonth;
    for (final trend in monthlyTrends) {
      if (bestMonth == null) {
        bestMonth = trend;
      } else if (trend.net > bestMonth.net) {
        bestMonth = trend;
      }

      if (worstMonth == null) {
        worstMonth = trend;
      } else if (trend.net < worstMonth.net) {
        worstMonth = trend;
      }
    }

    final currentMonth = monthlyTrends.isNotEmpty ? monthlyTrends.last : null;
    final previousMonth = monthlyTrends.length > 1 ? monthlyTrends[monthlyTrends.length - 2] : null;
    final monthOverMonthChange = currentMonth != null && previousMonth != null
        ? currentMonth.net - previousMonth.net
        : 0.0;

    final averageIncome = monthlyTrends.isNotEmpty
        ? monthlyTrends.fold<double>(0.0, (sum, trend) => sum + trend.income) / monthlyTrends.length
        : 0.0;
    final averageExpense = monthlyTrends.isNotEmpty
        ? monthlyTrends.fold<double>(0.0, (sum, trend) => sum + trend.expenses) / monthlyTrends.length
        : 0.0;
    final averageNet = monthlyTrends.isNotEmpty
        ? monthlyTrends.fold<double>(0.0, (sum, trend) => sum + trend.net) / monthlyTrends.length
        : 0.0;

    String trendDirectionLabel = '';
    if (currentMonth != null && previousMonth != null) {
      final percentChange = previousMonth.net == 0
          ? null
          : ((currentMonth.net - previousMonth.net) / previousMonth.net) * 100;
      final direction = currentMonth.net >= previousMonth.net ? 'improved' : 'declined';
      final changeText = percentChange == null
          ? _formatAmountChange(currentMonth.net - previousMonth.net)
          : '${percentChange.toStringAsFixed(1)}%';
      trendDirectionLabel =
          'This month has $direction by $changeText compared with last month.';
    }

    return PerformanceTrendsSnapshot(
      monthlyTrends: monthlyTrends,
      bestMonth: bestMonth,
      worstMonth: worstMonth,
      currentMonth: currentMonth,
      previousMonth: previousMonth,
      monthOverMonthChange: monthOverMonthChange,
      currentMonthNet: currentMonth?.net ?? 0.0,
      averageMonthlyIncome: averageIncome,
      averageMonthlyExpense: averageExpense,
      averageMonthlyNet: averageNet,
      trendDirectionLabel: trendDirectionLabel,
    );
  }

  static String _formatAmountChange(double value) {
    final currency = NumberFormat.currency(symbol: '');
    return currency.format(value);
  }
}

class MonthlyTrend {
  final DateTime month;
  double income;
  double expenses;

  MonthlyTrend({
    required this.month,
    required this.income,
    required this.expenses,
  });

  double get net => income - expenses;
}

class _TrendSummary {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrendSummary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
