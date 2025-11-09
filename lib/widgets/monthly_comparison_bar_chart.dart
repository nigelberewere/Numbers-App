import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class MonthlyComparisonBarChart extends StatelessWidget {
  final List<Transaction> transactions;
  final int monthsToShow;

  const MonthlyComparisonBarChart({
    super.key,
    required this.transactions,
    this.monthsToShow = 6,
  });

  @override
  Widget build(BuildContext context) {
    final data = _prepareMonthlyData();

    if (data.isEmpty) {
      return const Center(
        child: Text('No transaction data available'),
      );
    }

    return Column(
      children: [
        const Text(
          'Monthly Income vs Expenses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(data),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome = rodIndex == 0;
                      return BarTooltipItem(
                        '${isIncome ? 'Income' : 'Expenses'}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '\$${rod.toY.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _bottomTitles,
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: _leftTitles,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: _buildBarGroups(data),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  List<MonthlyData> _prepareMonthlyData() {
    final now = DateTime.now();
    final monthlyData = <String, MonthlyData>{};

    // Initialize last N months
    for (int i = monthsToShow - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month}';
      monthlyData[key] = MonthlyData(
        month: month,
        income: 0,
        expenses: 0,
      );
    }

    // Aggregate transactions by month
    for (var transaction in transactions) {
      final key = '${transaction.date.year}-${transaction.date.month}';
      if (monthlyData.containsKey(key)) {
        if (transaction.type == TransactionType.income) {
          monthlyData[key]!.income += transaction.amount;
        } else {
          monthlyData[key]!.expenses += transaction.amount;
        }
      }
    }

    // Sort by month
    final sortedData = monthlyData.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return sortedData;
  }

  List<BarChartGroupData> _buildBarGroups(List<MonthlyData> data) {
    return List.generate(data.length, (index) {
      final monthData = data[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthData.income,
            color: Colors.green,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          BarChartRodData(
            toY: monthData.expenses,
            color: Colors.red,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY(List<MonthlyData> data) {
    double max = 0;
    for (var monthData in data) {
      if (monthData.income > max) max = monthData.income;
      if (monthData.expenses > max) max = monthData.expenses;
    }
    return max * 1.2; // Add 20% padding
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final data = _prepareMonthlyData();
    if (value.toInt() >= data.length) {
      return const SizedBox.shrink();
    }

    final month = data[value.toInt()].month;
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        monthNames[month.month],
        style: style,
      ),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    if (value == 0) {
      return const SizedBox.shrink();
    }

    return Text(
      '\$${(value / 1000).toStringAsFixed(0)}k',
      style: style,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Income', Colors.green),
        const SizedBox(width: 24),
        _buildLegendItem('Expenses', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class MonthlyData {
  final DateTime month;
  double income;
  double expenses;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expenses,
  });

  double get profit => income - expenses;
}
