import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Transaction> transactions;

  const ExpensePieChart({super.key, required this.transactions});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = _calculateExpensesByCategory();

    if (expensesByCategory.isEmpty) {
      return const Center(child: Text('No expense data available'));
    }

    return Column(
      children: [
        const Text(
          'Expenses by Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildPieChartSections(expensesByCategory),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(expensesByCategory),
      ],
    );
  }

  Map<TransactionCategory, double> _calculateExpensesByCategory() {
    final expenses = widget.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final categoryTotals = <TransactionCategory, double>{};

    for (var transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<TransactionCategory, double> data,
  ) {
    final total = data.values.fold<double>(0, (sum, amount) => sum + amount);
    final colors = _getCategoryColors();

    int index = 0;
    return data.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 110.0 : 100.0;
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      final section = PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

      index++;
      return section;
    }).toList();
  }

  Widget _buildLegend(Map<TransactionCategory, double> data) {
    final colors = _getCategoryColors();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[entry.key],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${_getCategoryName(entry.key)}: \$${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Map<TransactionCategory, Color> _getCategoryColors() {
    return {
      TransactionCategory.feed: Colors.orange,
      TransactionCategory.fertilizer: Colors.green,
      TransactionCategory.seeds: Colors.lightGreen,
      TransactionCategory.labor: Colors.purple,
      TransactionCategory.equipment: Colors.blue,
      TransactionCategory.transport: Colors.cyan,
      TransactionCategory.utilities: Colors.amber,
      TransactionCategory.other: Colors.grey,
      TransactionCategory.sales: Colors.teal,
      TransactionCategory.trading: Colors.indigo,
      TransactionCategory.harvest: Colors.lime,
      TransactionCategory.livestock: Colors.brown,
      TransactionCategory.rent: Colors.indigoAccent,
      TransactionCategory.food: Colors.redAccent,
      TransactionCategory.books: Colors.teal,
      TransactionCategory.entertainment: Colors.purpleAccent,
      TransactionCategory.tuition: Colors.deepOrange,
    };
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.feed:
        return 'Feed';
      case TransactionCategory.fertilizer:
        return 'Fertilizer';
      case TransactionCategory.seeds:
        return 'Seeds';
      case TransactionCategory.labor:
        return 'Labor';
      case TransactionCategory.equipment:
        return 'Equipment';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.other:
        return 'Other';
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.trading:
        return 'Trading';
      case TransactionCategory.harvest:
        return 'Harvest';
      case TransactionCategory.livestock:
        return 'Livestock';
      case TransactionCategory.rent:
        return 'Rent';
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.books:
        return 'Books';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.tuition:
        return 'Tuition';
    }
  }
}
