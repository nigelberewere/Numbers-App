import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class IncomeExpenseLineChart extends StatelessWidget {
  final List<Transaction> transactions;
  final DateRange dateRange;

  const IncomeExpenseLineChart({
    super.key,
    required this.transactions,
    this.dateRange = DateRange.month,
  });

  @override
  Widget build(BuildContext context) {
    final data = _prepareChartData();

    if (data['income']!.isEmpty && data['expense']!.isEmpty) {
      return const Center(
        child: Text('No transaction data available'),
      );
    }

    return Column(
      children: [
        const Text(
          'Income vs Expenses',
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: _bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: null,
                      getTitlesWidget: _leftTitleWidgets,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                minX: 0,
                maxX: (data['income']!.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxY(data),
                lineBarsData: [
                  // Income line
                  LineChartBarData(
                    spots: data['income']!,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                  ),
                  // Expense line
                  LineChartBarData(
                    spots: data['expense']!,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isIncome = spot.barIndex == 0;
                        return LineTooltipItem(
                          '\$${spot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            backgroundColor: isIncome ? Colors.green : Colors.red,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Map<String, List<FlSpot>> _prepareChartData() {
    final now = DateTime.now();
    final days = _getDaysInRange();
    
    final incomeByDay = <int, double>{};
    final expenseByDay = <int, double>{};

    // Initialize all days to 0
    for (int i = 0; i < days; i++) {
      incomeByDay[i] = 0;
      expenseByDay[i] = 0;
    }

    // Group transactions by day
    for (var transaction in transactions) {
      final daysDiff = now.difference(transaction.date).inDays;
      if (daysDiff >= 0 && daysDiff < days) {
        final index = days - 1 - daysDiff;
        if (transaction.type == TransactionType.income) {
          incomeByDay[index] = (incomeByDay[index] ?? 0) + transaction.amount;
        } else {
          expenseByDay[index] = (expenseByDay[index] ?? 0) + transaction.amount;
        }
      }
    }

    return {
      'income': incomeByDay.entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      'expense': expenseByDay.entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
    };
  }

  int _getDaysInRange() {
    switch (dateRange) {
      case DateRange.week:
        return 7;
      case DateRange.month:
        return 30;
      case DateRange.quarter:
        return 90;
      case DateRange.year:
        return 365;
    }
  }

  double _getMaxY(Map<String, List<FlSpot>> data) {
    double maxIncome = 0;
    double maxExpense = 0;

    if (data['income']!.isNotEmpty) {
      maxIncome = data['income']!.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    }
    if (data['expense']!.isNotEmpty) {
      maxExpense = data['expense']!.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    }

    final max = maxIncome > maxExpense ? maxIncome : maxExpense;
    return max * 1.2; // Add 20% padding
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    
    final days = _getDaysInRange();
    final showEvery = days > 30 ? 30 : (days > 7 ? 7 : 1);
    
    if (value.toInt() % showEvery != 0) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final date = now.subtract(Duration(days: days - 1 - value.toInt()));
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${date.month}/${date.day}', style: style),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    
    if (value == 0) {
      return const SizedBox.shrink();
    }

    return Text('\$${value.toInt()}', style: style, textAlign: TextAlign.left);
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
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

enum DateRange {
  week,
  month,
  quarter,
  year,
}
