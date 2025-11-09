import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/mock_transaction_repository.dart';
import '../services/transaction_repository.dart';

class CashFlowPage extends StatefulWidget {
  final TransactionRepository? repository;

  const CashFlowPage({super.key, this.repository});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage> {
  late final TransactionRepository _repository;
  final NumberFormat _currency = NumberFormat.currency(symbol: '\$');

  bool _isLoading = true;
  String? _error;
  FinancialSummary? _summary;
  CashFlowSnapshot? _snapshot;

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
      final summary = await _repository.getFinancialSummary();
      final snapshot = CashFlowSnapshot.fromTransactions(transactions, summary);

      if (!mounted) return;
      setState(() {
        _summary = summary;
        _snapshot = snapshot;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load cash flow: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow Statement'),
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
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
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
        _buildSummaryRow(snapshot),
        const SizedBox(height: 12),
        _buildPeriodBanner(summary, snapshot),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Operating Activities',
          items: snapshot.operatingBreakdown,
          netValue: snapshot.operatingNet,
        ),
        _buildSection(
          title: 'Investing Activities',
          items: snapshot.investingBreakdown,
          netValue: snapshot.investingNet,
        ),
        _buildSection(
          title: 'Financing Activities',
          items: snapshot.financingBreakdown,
          netValue: snapshot.financingNet,
        ),
        _buildTrendCard(snapshot.trends),
      ],
    );
  }

  Widget _buildSummaryRow(CashFlowSnapshot snapshot) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSummaryCard('Operating', snapshot.operatingNet),
        _buildSummaryCard('Investing', snapshot.investingNet),
        _buildSummaryCard('Financing', snapshot.financingNet),
        _buildSummaryCard('Net Change', snapshot.netChange),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double value) {
    final width = math.min(MediaQuery.of(context).size.width - 32, 260.0);
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                _currency.format(value),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: _valueColor(value)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodBanner(FinancialSummary summary, CashFlowSnapshot snapshot) {
    final dateFormatter = DateFormat.yMMMMd();
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reporting period', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '${dateFormatter.format(summary.periodStart)} — ${dateFormatter.format(summary.periodEnd)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Opening cash: ${_currency.format(snapshot.openingCash)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Closing cash: ${_currency.format(snapshot.closingCash)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Net change in cash: ${_currency.format(snapshot.netChange)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: _valueColor(snapshot.netChange)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Map<String, double> items,
    required double netValue,
  }) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('No activity recorded yet'),
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
              _buildLineItem(entry.key, entry.value, isNet: false),
            const Divider(height: 24),
            _buildLineItem('Net cash from $title'.toLowerCase(), netValue, isNet: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(String label, double value, {required bool isNet}) {
    final displayLabel = label.isEmpty
        ? label
        : label[0].toUpperCase() + label.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayLabel,
              style: isNet
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            _currency.format(value),
            style: TextStyle(
              color: _valueColor(value),
              fontWeight: isNet ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(List<CashFlowTrendPoint> trends) {
    if (trends.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Monthly cash trends will appear once transactions are recorded.'),
        ),
      );
    }

    final maxAbs = trends.fold<double>(0, (current, point) => math.max(current, point.netTotal.abs()));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly net cash trend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final point in trends)
              _buildTrendRow(point, maxAbs == 0 ? 1 : maxAbs),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendRow(CashFlowTrendPoint point, double maxAbs) {
    final dateLabel = DateFormat.yMMM().format(point.month);
  final normalized = (point.netTotal.abs() / maxAbs).clamp(0, 1).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(dateLabel)),
              Text(
                _currency.format(point.netTotal),
                style: TextStyle(
                  color: _valueColor(point.netTotal),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_valueColor(point.netTotal)),
            ),
          ),
        ],
      ),
    );
  }

  Color _valueColor(double value) {
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.grey;
  }
}

class CashFlowSnapshot {
  final Map<String, double> operatingBreakdown;
  final Map<String, double> investingBreakdown;
  final Map<String, double> financingBreakdown;
  final List<CashFlowTrendPoint> trends;
  final double operatingNet;
  final double investingNet;
  final double financingNet;
  final double netChange;
  final double openingCash;
  final double closingCash;

  const CashFlowSnapshot({
    required this.operatingBreakdown,
    required this.investingBreakdown,
    required this.financingBreakdown,
    required this.trends,
    required this.operatingNet,
    required this.investingNet,
    required this.financingNet,
    required this.netChange,
    required this.openingCash,
    required this.closingCash,
  });

  factory CashFlowSnapshot.fromTransactions(
    List<Transaction> transactions,
    FinancialSummary summary,
  ) {
    double sumFor(Set<TransactionCategory> categories, TransactionType type) {
      return transactions
          .where((t) => categories.contains(t.category) && t.type == type)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    }

    // Heuristic grouping tailored to the mock dataset. Adjust when the backend lands.
    final operatingIncome = sumFor(
      {
        TransactionCategory.sales,
        TransactionCategory.harvest,
        TransactionCategory.livestock,
        TransactionCategory.trading,
      },
      TransactionType.income,
    );

    final inputExpenses = sumFor(
      {
        TransactionCategory.feed,
        TransactionCategory.fertilizer,
        TransactionCategory.seeds,
      },
      TransactionType.expense,
    );

    final laborExpenses = sumFor(
      {TransactionCategory.labor},
      TransactionType.expense,
    );

    final overheadExpenses = sumFor(
      {
        TransactionCategory.transport,
        TransactionCategory.utilities,
        TransactionCategory.other,
      },
      TransactionType.expense,
    );

    final operatingOutflows = inputExpenses + laborExpenses + overheadExpenses;

    final operatingBreakdown = <String, double>{
      if (operatingIncome > 0) 'Cash received from customers': operatingIncome,
      if (inputExpenses > 0) 'Cash paid for farm inputs': -inputExpenses,
      if (laborExpenses > 0) 'Cash paid to workers': -laborExpenses,
      if (overheadExpenses > 0) 'Cash paid for overheads': -overheadExpenses,
    };

    final equipmentInvestments = sumFor(
      {TransactionCategory.equipment},
      TransactionType.expense,
    );

    final landImprovements = (sumFor({TransactionCategory.seeds}, TransactionType.expense) * 0.15) +
        (sumFor({TransactionCategory.fertilizer}, TransactionType.expense) * 0.2);

    final investingBreakdown = <String, double>{
      if (equipmentInvestments > 0) 'Farm equipment purchases': -equipmentInvestments,
      if (landImprovements > 0) 'Land development spends': -landImprovements,
    };

    final financingInflows = sumFor(
      {TransactionCategory.other},
      TransactionType.income,
    );

    final financingOutflows = sumFor(
      {TransactionCategory.other},
      TransactionType.expense,
    );

    final financingBreakdown = <String, double>{
      if (financingInflows > 0) 'Capital contributions': financingInflows,
      if (financingOutflows > 0) 'Loan repayments and draws': -financingOutflows,
    };

    final operatingNet = operatingIncome - operatingOutflows;
  final investingNet = investingBreakdown.values.fold<double>(0.0, (sum, value) => sum + value);

    final financingNet = financingInflows - financingOutflows;
    final netChange = operatingNet + investingNet + financingNet;

    final closingCash = math.max(summary.balance, 0.0).toDouble();
    final openingCash = math.max(closingCash - netChange, 0.0);

    final monthTotals = <DateTime, double>{};
    for (final transaction in transactions) {
      final key = DateTime(transaction.date.year, transaction.date.month);
      final sign = transaction.type == TransactionType.income ? 1 : -1;
  monthTotals[key] = monthTotals.putIfAbsent(key, () => 0.0) + (transaction.amount * sign);
    }

    final trends = monthTotals.entries
        .map((entry) => CashFlowTrendPoint(month: entry.key, netTotal: entry.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return CashFlowSnapshot(
      operatingBreakdown: operatingBreakdown,
      investingBreakdown: investingBreakdown,
      financingBreakdown: financingBreakdown,
      trends: trends,
      operatingNet: operatingNet,
      investingNet: investingNet,
      financingNet: financingNet,
      netChange: netChange,
      openingCash: openingCash,
      closingCash: closingCash,
    );
  }
}

class CashFlowTrendPoint {
  final DateTime month;
  final double netTotal;

  const CashFlowTrendPoint({required this.month, required this.netTotal});
}
