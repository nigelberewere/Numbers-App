import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ForexScatterChart extends StatelessWidget {
  final List<ForexTrade> trades;
  final String title;

  const ForexScatterChart({
    super.key,
    required this.trades,
    this.title = 'Trading Performance',
  });

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No forex trades to display',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final profitableTrades = trades.where((t) => t.profitLoss > 0).toList();
    final losingTrades = trades.where((t) => t.profitLoss < 0).toList();

    // Calculate min/max for axes
    final allProfitLoss = trades.map((t) => t.profitLoss).toList();
    final minProfit =
        allProfitLoss.reduce((a, b) => a < b ? a : b).floorToDouble();
    final maxProfit =
        allProfitLoss.reduce((a, b) => a > b ? a : b).ceilToDouble();

    // Sort trades by date and assign x-axis values
    final sortedTrades = List<ForexTrade>.from(trades)
      ..sort((a, b) => a.entryTime.compareTo(b.entryTime));
    final minDate = sortedTrades.first.entryTime.millisecondsSinceEpoch.toDouble();
    final maxDate = sortedTrades.last.entryTime.millisecondsSinceEpoch.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    _buildLegendItem(
                      context,
                      'Profit',
                      Colors.green,
                      profitableTrades.length,
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      context,
                      'Loss',
                      Colors.red,
                      losingTrades.length,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: [
                    // Profitable trades (green)
                    ...profitableTrades.map((trade) {
                      final x = trade.entryTime.millisecondsSinceEpoch.toDouble();
                      return ScatterSpot(
                        x,
                        trade.profitLoss,
                        dotPainter: FlDotCirclePainter(
                          radius: 6,
                          color: Colors.green.withValues(alpha: 0.7),
                          strokeWidth: 2,
                          strokeColor: Colors.green,
                        ),
                      );
                    }),
                    // Losing trades (red)
                    ...losingTrades.map((trade) {
                      final x = trade.entryTime.millisecondsSinceEpoch.toDouble();
                      return ScatterSpot(
                        x,
                        trade.profitLoss,
                        dotPainter: FlDotCirclePainter(
                          radius: 6,
                          color: Colors.red.withValues(alpha: 0.7),
                          strokeWidth: 2,
                          strokeColor: Colors.red,
                        ),
                      );
                    }),
                  ],
                  minX: minDate,
                  maxX: maxDate,
                  minY: minProfit - (maxProfit - minProfit) * 0.1,
                  maxY: maxProfit + (maxProfit - minProfit) * 0.1,
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (maxProfit - minProfit) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: value == 0
                            ? colorScheme.outline
                            : colorScheme.outline.withValues(alpha: 0.2),
                        strokeWidth: value == 0 ? 2 : 1,
                        dashArray: value == 0 ? null : [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('Profit/Loss (\$)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('Trade Date'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (maxDate - minDate) / 5,
                        getTitlesWidget: (value, meta) {
                          final date =
                              DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  scatterTouchData: ScatterTouchData(
                    enabled: true,
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipItems: (ScatterSpot spot) {
                        // Find the trade for this spot
                        final trade = sortedTrades.firstWhere(
                          (t) =>
                              t.entryTime.millisecondsSinceEpoch.toDouble() ==
                                  spot.x &&
                              t.profitLoss == spot.y,
                        );

                        return ScatterTooltipItem(
                          '${trade.currencyPair}\n'
                          '${DateFormat('MMM dd, yyyy').format(trade.entryTime)}\n'
                          'P/L: \$${trade.profitLoss.toStringAsFixed(2)}\n'
                          'Pips: ${trade.pips.toStringAsFixed(1)}',
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatistics(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final totalTrades = trades.length;
    final profitableTrades = trades.where((t) => t.profitLoss > 0).length;
    final winRate = totalTrades > 0 ? (profitableTrades / totalTrades) * 100 : 0;

    final totalProfit = trades
        .where((t) => t.profitLoss > 0)
        .fold<double>(0, (sum, t) => sum + t.profitLoss);
    final totalLoss = trades
        .where((t) => t.profitLoss < 0)
        .fold<double>(0, (sum, t) => sum + t.profitLoss.abs());
    final profitFactor = totalLoss > 0 ? totalProfit / totalLoss : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Win Rate',
            '${winRate.toStringAsFixed(1)}%',
          ),
          _buildStatItem(
            context,
            'Profit Factor',
            profitFactor.toStringAsFixed(2),
          ),
          _buildStatItem(
            context,
            'Total P/L',
            '\$${(totalProfit - totalLoss).toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
