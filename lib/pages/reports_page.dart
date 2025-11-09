import 'package:flutter/material.dart';
import 'balance_sheet_page.dart';
import 'cash_flow_page.dart';
import 'expense_analysis_page.dart';
import 'income_statement_page.dart';
import 'performance_trends_page.dart';
import '../widgets/report_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReportCard(
            icon: Icons.description,
            title: 'Income Statement',
            subtitle: 'View profit and loss',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IncomeStatementPage(),
                ),
              );
            },
          ),
          ReportCard(
            icon: Icons.account_balance,
            title: 'Balance Sheet',
            subtitle: 'Assets, liabilities, equity',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BalanceSheetPage(),
                ),
              );
            },
          ),
          ReportCard(
            icon: Icons.water_drop,
            title: 'Cash Flow Statement',
            subtitle: 'Track cash movements',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CashFlowPage(),
                ),
              );
            },
          ),
          ReportCard(
            icon: Icons.pie_chart,
            title: 'Expense Analysis',
            subtitle: 'Breakdown by category',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpenseAnalysisPage(),
                ),
              );
            },
          ),
          ReportCard(
            icon: Icons.trending_up,
            title: 'Performance Trends',
            subtitle: 'Monthly and yearly trends',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerformanceTrendsPage(),
                ),
              );
            },
          ),
          ReportCard(
            icon: Icons.lightbulb_outline,
            title: 'Smart Recommendations',
            subtitle: 'AI-powered insights',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportDetailPage(
                    title: 'Smart Recommendations',
                    description:
                        'Personalized guidance powered by AI will appear here once the intelligence engine is ready.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  final String title;
  final String description;

  const ReportDetailPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 72,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                '$title Coming Soon',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
