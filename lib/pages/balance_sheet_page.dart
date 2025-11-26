import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class BalanceSheetPage extends ConsumerStatefulWidget {
  final TransactionRepository? repository;

  const BalanceSheetPage({super.key, this.repository});

  @override
  ConsumerState<BalanceSheetPage> createState() => _BalanceSheetPageState();
}

class _BalanceSheetPageState extends ConsumerState<BalanceSheetPage> {
  late final TransactionRepository _repository;
  final NumberFormat _currency = NumberFormat.currency(symbol: '\$');

  bool _isLoading = true;
  String? _error;
  FinancialSummary? _summary;
  BalanceSheetSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ref.read(transactionRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactions = await _repository.getAllTransactions();
      final summary = await _repository.getFinancialSummary();
      final snapshot = BalanceSheetSnapshot.fromTransactions(
        transactions,
        summary,
      );

      if (!mounted) return;
      setState(() {
        _summary = summary;
        _snapshot = snapshot;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load balance sheet: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Sheet'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh),
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
    final summary = _summary!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTopSummary(snapshot),
        const SizedBox(height: 12),
        _buildPeriodBanner(summary),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Current Assets',
          items: snapshot.currentAssets,
          total: snapshot.totalCurrentAssets,
          accent: Colors.green,
        ),
        _buildSection(
          title: 'Non-current Assets',
          items: snapshot.nonCurrentAssets,
          total: snapshot.totalNonCurrentAssets,
          accent: Colors.green,
        ),
        _buildSection(
          title: 'Current Liabilities',
          items: snapshot.currentLiabilities,
          total: snapshot.totalCurrentLiabilities,
          accent: Colors.red,
        ),
        _buildSection(
          title: 'Long-term Liabilities',
          items: snapshot.longTermLiabilities,
          total: snapshot.totalLongTermLiabilities,
          accent: Colors.red,
        ),
        _buildSection(
          title: 'Owner Equity',
          items: snapshot.equityBreakdown,
          total: snapshot.totalEquity,
          accent: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildTopSummary(BalanceSheetSnapshot snapshot) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSummaryCard(
          'Total Assets',
          snapshot.totalAssets,
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Liabilities',
          snapshot.totalLiabilities,
          Icons.receipt_long,
          Colors.red,
        ),
        _buildSummaryCard(
          'Equity',
          snapshot.totalEquity,
          Icons.account_balance,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildPeriodBanner(FinancialSummary summary) {
    final dateFormatter = DateFormat.yMMMMd();

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reporting period',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${dateFormatter.format(summary.periodStart)} — ${dateFormatter.format(summary.periodEnd)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Net profit for period: ${_currency.format(summary.netProfit)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    final availableWidth = MediaQuery.of(context).size.width - 32;

    return SizedBox(
      width: math.min(availableWidth, 280.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                _currency.format(value),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Map<String, double> items,
    required double total,
    required Color accent,
  }) {
    if (items.isEmpty || total <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'No data available yet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final entry in items.entries)
              _buildLineItem(entry.key, entry.value, total, accent),
            const Divider(height: 24),
            _buildLineItem('Subtotal', total, total, accent, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(
    String label,
    double value,
    double total,
    Color accent, {
    bool isTotal = false,
  }) {
    final percentage = total > 0
        ? ((value / total * 100).clamp(0, 100)).toDouble()
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: accent),
          ),
          const SizedBox(width: 12),
          Text(
            _currency.format(value),
            style: isTotal
                ? Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class BalanceSheetSnapshot {
  final Map<String, double> currentAssets;
  final Map<String, double> nonCurrentAssets;
  final Map<String, double> currentLiabilities;
  final Map<String, double> longTermLiabilities;
  final Map<String, double> equityBreakdown;

  BalanceSheetSnapshot({
    required this.currentAssets,
    required this.nonCurrentAssets,
    required this.currentLiabilities,
    required this.longTermLiabilities,
    required this.equityBreakdown,
  });

  double get totalCurrentAssets => _sum(currentAssets);
  double get totalNonCurrentAssets => _sum(nonCurrentAssets);
  double get totalCurrentLiabilities => _sum(currentLiabilities);
  double get totalLongTermLiabilities => _sum(longTermLiabilities);
  double get totalAssets => totalCurrentAssets + totalNonCurrentAssets;
  double get totalLiabilities =>
      totalCurrentLiabilities + totalLongTermLiabilities;
  double get totalEquity => _sum(equityBreakdown);

  static double _sum(Map<String, double> values) =>
      values.values.fold(0, (sum, value) => sum + value);

  factory BalanceSheetSnapshot.fromTransactions(
    List<Transaction> transactions,
    FinancialSummary summary,
  ) {
    double sumCategory(TransactionCategory category, TransactionType type) {
      return transactions
          .where((t) => t.category == category && t.type == type)
          .fold<double>(0, (sum, t) => sum + t.amount);
    }

    final salesIncome = sumCategory(
      TransactionCategory.sales,
      TransactionType.income,
    );
    final harvestIncome = sumCategory(
      TransactionCategory.harvest,
      TransactionType.income,
    );
    final livestockIncome = sumCategory(
      TransactionCategory.livestock,
      TransactionType.income,
    );

    final feedExpense = sumCategory(
      TransactionCategory.feed,
      TransactionType.expense,
    );
    final fertilizerExpense = sumCategory(
      TransactionCategory.fertilizer,
      TransactionType.expense,
    );
    final seedsExpense = sumCategory(
      TransactionCategory.seeds,
      TransactionType.expense,
    );
    final laborExpense = sumCategory(
      TransactionCategory.labor,
      TransactionType.expense,
    );
    final equipmentExpense = sumCategory(
      TransactionCategory.equipment,
      TransactionType.expense,
    );
    final transportExpense = sumCategory(
      TransactionCategory.transport,
      TransactionType.expense,
    );
    final utilitiesExpense = sumCategory(
      TransactionCategory.utilities,
      TransactionType.expense,
    );

    final cashAndEquivalents = math.max(summary.balance, 0.0).toDouble();
    final receivables = salesIncome * 0.18;
    final cropInventory = harvestIncome * 0.25 + seedsExpense * 0.45;
    final prepaidInputs = (fertilizerExpense + feedExpense) * 0.18;

    final currentAssets = <String, double>{
      'Cash & equivalents': cashAndEquivalents,
      'Accounts receivable': receivables,
      'Crop inventory': cropInventory,
      'Prepaid inputs': prepaidInputs,
    }..removeWhere((key, value) => value <= 0);

    final livestockAssets = livestockIncome * 0.6 + feedExpense * 0.35;
    final equipmentAssets = equipmentExpense * 1.7;
    final landImprovements = (fertilizerExpense + seedsExpense) * 0.4;

    final nonCurrentAssets = <String, double>{
      'Livestock assets': livestockAssets,
      'Farm equipment': equipmentAssets,
      'Land improvements': landImprovements,
    }..removeWhere((key, value) => value <= 0);

    final accountsPayable =
        (feedExpense + fertilizerExpense + seedsExpense) * 0.25;
    final wagesPayable = laborExpense * 0.22;
    final accruedExpenses =
        (transportExpense * 0.3) + (utilitiesExpense * 0.45);

    final currentLiabilities = <String, double>{
      'Accounts payable': accountsPayable,
      'Wages payable': wagesPayable,
      'Accrued expenses': accruedExpenses,
    }..removeWhere((key, value) => value <= 0);

    final equipmentLoans = equipmentAssets * 0.4;
    final landLoans = landImprovements * 0.45;
    final livestockLoans = livestockAssets * 0.2;

    final longTermLiabilities = <String, double>{
      'Equipment financing': equipmentLoans,
      'Land development loan': landLoans,
      'Livestock loans': livestockLoans,
    }..removeWhere((key, value) => value <= 0);

    final totalAssets = _sum(currentAssets) + _sum(nonCurrentAssets);
    final totalLiabilities =
        _sum(currentLiabilities) + _sum(longTermLiabilities);
    final equityValue = math
        .max(totalAssets - totalLiabilities, 0.0)
        .toDouble();

    final retainedEarnings = math
        .max(math.min(summary.netProfit, equityValue), 0.0)
        .toDouble();
    final baseEquity = math.max(equityValue - retainedEarnings, 0.0).toDouble();
    final ownerCapital = baseEquity * 0.8;
    final reserves = baseEquity - ownerCapital;

    final equityBreakdown = <String, double>{
      if (ownerCapital > 0) 'Owner capital': ownerCapital,
      if (retainedEarnings > 0) 'Retained earnings': retainedEarnings,
      if (reserves > 0) 'Revaluation reserves': reserves,
    };

    return BalanceSheetSnapshot(
      currentAssets: currentAssets,
      nonCurrentAssets: nonCurrentAssets,
      currentLiabilities: currentLiabilities,
      longTermLiabilities: longTermLiabilities,
      equityBreakdown: equityBreakdown,
    );
  }
}
