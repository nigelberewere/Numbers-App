import 'package:flutter/material.dart';

class ForexPage extends StatefulWidget {
  const ForexPage({super.key});

  @override
  State<ForexPage> createState() => _ForexPageState();
}

class Trade {
  final String id;
  final String pair;
  final double amount;
  final double profitLoss;
  final DateTime date;

  Trade({
    required this.id,
    required this.pair,
    required this.amount,
    required this.profitLoss,
    required this.date,
  });
}

class _ForexPageState extends State<ForexPage> {
  double _initialCapital = 0.0;
  double _balance = 0.0;
  final List<Trade> _trades = [];

  void _recordTrade() async {
    final result = await showDialog<Trade>(
      context: context,
      builder: (context) {
        final pairCtrl = TextEditingController();
        final amountCtrl = TextEditingController();
        final plCtrl = TextEditingController();
        DateTime tradeDate = DateTime.now();

        return AlertDialog(
          title: const Text('Record Trade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pairCtrl,
                  decoration: const InputDecoration(labelText: 'Pair (e.g. EUR/USD)'),
                ),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount (base currency)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: plCtrl,
                  decoration: const InputDecoration(labelText: 'Profit / Loss (e.g. -15.50)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Date:'),
                    const SizedBox(width: 8),
                    TextButton(
                      child: Text('${tradeDate.toLocal()}'.split(' ')[0]),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tradeDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          tradeDate = picked;
                          // Force rebuild of the dialog by calling setState on the dialog's state
                          (context as Element).markNeedsBuild();
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final pair = pairCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0.0;
                final pl = double.tryParse(plCtrl.text.replaceAll(',', '')) ?? 0.0;
                if (pair.isEmpty) return;
                final trade = Trade(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  pair: pair,
                  amount: amount,
                  profitLoss: pl,
                  date: tradeDate,
                );
                Navigator.of(context).pop(trade);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _trades.insert(0, result);
        _balance += result.profitLoss;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trade recorded')));
    }
  }

  void _addCapital() async {
    final amount = await _showAmountDialog(title: 'Add Capital');
    if (!mounted) return;

    if (amount != null && amount > 0) {
      setState(() {
        _initialCapital += amount;
        _balance += amount;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capital added')));
    }
  }

  void _recordWithdrawal() async {
    final amount = await _showAmountDialog(title: 'Record Withdrawal');
    if (!mounted) return;

    if (amount != null && amount > 0) {
      setState(() {
        _balance -= amount;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal recorded')));
    }
  }

  Future<double?> _showAmountDialog({required String title}) {
    final ctrl = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '\$', hintText: '0.00'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0.0;
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _applyTradingFees() async {
    final pctCtrl = TextEditingController(text: '0.5');
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trading Fees'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Apply a trading fees percentage to the current balance'),
              const SizedBox(height: 12),
              TextField(
                controller: pctCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Fee %'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (apply == true) {
      final pct = double.tryParse(pctCtrl.text) ?? 0.0;
      final fee = _balance * (pct / 100.0);
      setState(() {
        _balance -= fee;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied fees: \$${fee.toStringAsFixed(2)}')));
    }
  }

  void _viewAllTrades() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TradesListPage(trades: _trades, onDelete: (id) {
          setState(() {
            _trades.removeWhere((t) => t.id == id);
          });
        })));
  }

  @override
  Widget build(BuildContext context) {
    final totalPL = _trades.fold<double>(0.0, (p, e) => p + e.profitLoss);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forex Trading'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trading Summary Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trading Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Initial Capital',
                    value: '\$${_initialCapital.toStringAsFixed(2)}',
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Current Balance',
                    value: '\$${_balance.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Total Profit/Loss',
                    value: '\$${totalPL.toStringAsFixed(2)}',
                    color: Colors.orange,
                  ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Number of Trades',
                    value: '${_trades.length}',
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ForexActionCard(
            icon: Icons.add_circle,
            title: 'Record Trade',
            color: Colors.blue,
            onTap: _recordTrade,
          ),
          _ForexActionCard(
            icon: Icons.account_balance_wallet,
            title: 'Add Capital',
            color: Colors.green,
            onTap: _addCapital,
          ),
          _ForexActionCard(
            icon: Icons.remove_circle,
            title: 'Record Withdrawal',
            color: Colors.red,
            onTap: _recordWithdrawal,
          ),
          _ForexActionCard(
            icon: Icons.calculate,
            title: 'Trading Fees',
            color: Colors.orange,
            onTap: _applyTradingFees,
          ),
          const SizedBox(height: 16),

          // Recent Trades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Trades',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: _trades.isNotEmpty ? _viewAllTrades : null,
                child: const Text('View All'),
              ),
            ],
          ),
          if (_trades.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.show_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No trades recorded yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._trades.take(3).map((t) => Card(
                  child: ListTile(
                    title: Text(t.pair),
                    subtitle: Text('${t.date.toLocal()}'.split(' ')[0]),
                    trailing: Text(
                      '\$${t.profitLoss.toStringAsFixed(2)}',
                      style: TextStyle(color: t.profitLoss >= 0 ? Colors.green : Colors.red),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class TradesListPage extends StatelessWidget {
  final List<Trade> trades;
  final void Function(String id) onDelete;

  const TradesListPage({super.key, required this.trades, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Trades')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trades.length,
        itemBuilder: (context, i) {
          final t = trades[i];
          return Card(
            child: ListTile(
              title: Text(t.pair),
              subtitle: Text('${t.date.toLocal()}'.split(' ')[0]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\$${t.profitLoss.toStringAsFixed(2)}', style: TextStyle(color: t.profitLoss >= 0 ? Colors.green : Colors.red)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final scaffold = ScaffoldMessenger.of(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Trade'),
                          content: const Text('Remove this trade from records?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        onDelete(t.id);
                        scaffold.showSnackBar(const SnackBar(content: Text('Trade deleted')));
                      }
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ForexActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ForexActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
