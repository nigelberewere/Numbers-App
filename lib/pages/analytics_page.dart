import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/transaction_repository.dart';
import '../services/mock_transaction_repository.dart';
import '../services/export_service.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/income_expense_line_chart.dart';
import '../widgets/monthly_comparison_bar_chart.dart';
import '../widgets/transaction_filter_dialog.dart';

class AnalyticsPage extends StatefulWidget {
  final TransactionRepository? repository;

  const AnalyticsPage({super.key, this.repository});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late final TransactionRepository _repository;
  DateRange _selectedDateRange = DateRange.month;
  TransactionFilters _filters = TransactionFilters();
  
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockTransactionRepository();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var transactions = await _repository.getAllTransactions();
      transactions = _applyFilters(transactions);
      
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var filtered = transactions;

    if (_filters.startDate != null && _filters.endDate != null) {
      filtered = filtered.where((t) =>
          t.date.isAfter(_filters.startDate!.subtract(const Duration(days: 1))) &&
          t.date.isBefore(_filters.endDate!.add(const Duration(days: 1)))).toList();
    }

    if (_filters.transactionType != null) {
      filtered = filtered.where((t) => t.type == _filters.transactionType).toList();
    }

    if (_filters.categories.isNotEmpty) {
      filtered = filtered.where((t) => _filters.categories.contains(t.category)).toList();
    }

    if (_filters.minAmount != null) {
      filtered = filtered.where((t) => t.amount >= _filters.minAmount!).toList();
    }

    if (_filters.maxAmount != null) {
      filtered = filtered.where((t) => t.amount <= _filters.maxAmount!).toList();
    }

    return filtered;
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<TransactionFilters>(
      context: context,
      builder: (context) => TransactionFilterDialog(initialFilters: _filters),
    );

    if (result != null) {
      setState(() => _filters = result);
      _loadTransactions();
    }
  }

  Future<void> _exportData() async {
    await ExportService.showExportDialog(context, _transactions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: _filters.hasActiveFilters
                ? const Badge(label: Text('!'), child: Icon(Icons.filter_list))
                : const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _transactions.isNotEmpty ? _exportData : null,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTransactions),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _transactions.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadTransactions, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No transactions found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_filters.hasActiveFilters
              ? 'Try adjusting your filters'
              : 'Add transactions to see analytics'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final income = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_filters.hasActiveFilters) _buildFilterBanner(),
        _buildSummaryRow(income, expenses),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: MonthlyComparisonBarChart(transactions: _transactions))),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<DateRange>(
                  segments: const [
                    ButtonSegment(value: DateRange.week, label: Text('Week')),
                    ButtonSegment(value: DateRange.month, label: Text('Month')),
                    ButtonSegment(value: DateRange.quarter, label: Text('Quarter')),
                    ButtonSegment(value: DateRange.year, label: Text('Year')),
                  ],
                  selected: {_selectedDateRange},
                  onSelectionChanged: (s) => setState(() => _selectedDateRange = s.first),
                ),
                const SizedBox(height: 16),
                IncomeExpenseLineChart(transactions: _transactions, dateRange: _selectedDateRange),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: ExpensePieChart(transactions: _transactions))),
      ],
    );
  }

  Widget _buildFilterBanner() {
    return Column(
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.filter_alt),
                const SizedBox(width: 8),
                Expanded(child: Text('Filters active - ${_transactions.length} transactions')),
                TextButton(
                  onPressed: () {
                    setState(() => _filters = TransactionFilters());
                    _loadTransactions();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryRow(double income, double expenses) {
    final profit = income - expenses;
    final savings = income > 0 ? (profit / income * 100) : 0;

    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Income', '\$${income.toStringAsFixed(0)}', Icons.trending_up, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Expenses', '\$${expenses.toStringAsFixed(0)}', Icons.trending_down, Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Profit', '\$${profit.toStringAsFixed(0)}', Icons.account_balance_wallet, profit >= 0 ? Colors.green : Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Savings', '${savings.toStringAsFixed(1)}%', Icons.savings, Colors.blue)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
