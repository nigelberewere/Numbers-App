import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_action_card.dart';
import '../models/notification_item.dart';
import '../services/notifications_service.dart';
import 'notifications_page.dart';
import 'add_transaction_page.dart';
import 'agriculture_page.dart';
import 'forex_page.dart';
import 'transactions_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Theme toggle button (easy access from dashboard)
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            tooltip: themeMode == ThemeMode.dark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
          ),
          // Notifications bell with unread badge
          ValueListenableBuilder<List<NotificationItem>>(
            valueListenable: NotificationsService.instance.notifications,
            builder: (context, list, _) {
              final unread = list.where((n) => !n.read).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(currentUserProvider);
                        if (user?.photoUrl == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(user!.photoUrl!),
                          ),
                        );
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here\'s your financial overview',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Summary Cards
            Consumer(
              builder: (context, ref, child) {
                final summaryAsync = ref.watch(financialSummaryProvider);
                return summaryAsync.when(
                  data: (summary) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Income',
                              amount:
                                  '\$${summary.totalIncome.toStringAsFixed(2)}',
                              icon: Icons.trending_up,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              title: 'Expenses',
                              amount:
                                  '\$${summary.totalExpenses.toStringAsFixed(2)}',
                              icon: Icons.trending_down,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Net Profit',
                              amount:
                                  '\$${summary.netProfit.toStringAsFixed(2)}',
                              icon: Icons.account_balance_wallet,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              title: 'Balance',
                              amount: '\$${summary.balance.toStringAsFixed(2)}',
                              icon: Icons.savings,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                QuickActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Add Income',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddTransactionPage(isIncome: true),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.remove_circle_outline,
                  title: 'Add Expense',
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddTransactionPage(isIncome: false),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.agriculture,
                  title: 'Agriculture',
                  color: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgriculturePage(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.show_chart,
                  title: 'Forex Trading',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForexPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsPage(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final transactionsAsync = ref.watch(transactionListProvider);
                return transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    // Show only top 5 recent transactions
                    final recent = transactions.take(5).toList();
                    return Column(
                      children: recent
                          .map(
                            (t) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      t.type == TransactionType.income
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  child: Icon(
                                    t.type == TransactionType.income
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: t.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(t.title),
                                subtitle: Text(t.date.toString().split(' ')[0]),
                                trailing: Text(
                                  '\$${t.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: t.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionPage(isIncome: true),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Record'),
      ),
    );
  }
}
