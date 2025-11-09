import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

/// Form for adding multiple transactions at once
class BulkTransactionForm extends StatefulWidget {
  final bool isIncome;

  const BulkTransactionForm({
    super.key,
    required this.isIncome,
  });

  @override
  State<BulkTransactionForm> createState() => _BulkTransactionFormState();
}

class _BulkTransactionFormState extends State<BulkTransactionForm> {
  final List<_TransactionItem> _transactions = [];
  
  @override
  void initState() {
    super.initState();
    _addNewTransaction();
  }

  void _addNewTransaction() {
    setState(() {
      _transactions.add(_TransactionItem());
    });
  }

  void _removeTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
  }

  void _saveAllTransactions() {
    final validTransactions = <Transaction>[];
    
    for (var item in _transactions) {
      if (item.isValid()) {
        final transaction = Transaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}_${validTransactions.length}',
          title: item.titleController.text.trim(),
          amount: double.parse(item.amountController.text),
          type: widget.isIncome ? TransactionType.income : TransactionType.expense,
          category: item.category!,
          date: item.date,
          paymentMethod: item.paymentMethod,
        );
        validTransactions.add(transaction);
      }
    }

    if (validTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one valid transaction'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, validTransactions);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${validTransactions.length} transactions added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    for (var item in _transactions) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulk ${widget.isIncome ? "Income" : "Expense"} Entry'),
        actions: [
          TextButton.icon(
            onPressed: _saveAllTransactions,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.isIncome 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Transactions',
                  _transactions.length.toString(),
                  Icons.receipt,
                ),
                _buildSummaryItem(
                  'Valid',
                  _transactions.where((t) => t.isValid()).length.toString(),
                  Icons.check_circle,
                ),
                _buildSummaryItem(
                  'Total',
                  '\$${_calculateTotal().toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return _TransactionItemCard(
                  item: _transactions[index],
                  index: index,
                  isIncome: widget.isIncome,
                  onRemove: () => _removeTransaction(index),
                  onChanged: () => setState(() {}),
                );
              },
            ),
          ),

          // Add Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNewTransaction,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Transaction'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    return _transactions
        .where((t) => t.isValid())
        .fold(0.0, (sum, item) {
          return sum + (double.tryParse(item.amountController.text) ?? 0);
        });
  }
}

class _TransactionItem {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  TransactionCategory? category;
  DateTime date = DateTime.now();
  PaymentMethod paymentMethod = PaymentMethod.cash;

  bool isValid() {
    return titleController.text.trim().isNotEmpty &&
           amountController.text.isNotEmpty &&
           double.tryParse(amountController.text) != null &&
           double.parse(amountController.text) > 0 &&
           category != null;
  }

  void dispose() {
    titleController.dispose();
    amountController.dispose();
  }
}

class _TransactionItemCard extends StatefulWidget {
  final _TransactionItem item;
  final int index;
  final bool isIncome;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _TransactionItemCard({
    required this.item,
    required this.index,
    required this.isIncome,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_TransactionItemCard> createState() => _TransactionItemCardState();
}

class _TransactionItemCardState extends State<_TransactionItemCard> {
  bool _isExpanded = true;

  List<TransactionCategory> get _categories {
    if (widget.isIncome) {
      return [
        TransactionCategory.sales,
        TransactionCategory.trading,
        TransactionCategory.harvest,
        TransactionCategory.livestock,
      ];
    } else {
      return [
        TransactionCategory.feed,
        TransactionCategory.fertilizer,
        TransactionCategory.seeds,
        TransactionCategory.labor,
        TransactionCategory.equipment,
        TransactionCategory.transport,
        TransactionCategory.utilities,
        TransactionCategory.other,
      ];
    }
  }

  String _getCategoryName(TransactionCategory category) {
    return category.toString().split('.').last.toUpperCase()[0] +
           category.toString().split('.').last.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = widget.item.isValid();

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isValid ? Colors.green : Colors.grey,
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              widget.item.titleController.text.isEmpty
                  ? 'Transaction ${widget.index + 1}'
                  : widget.item.titleController.text,
            ),
            subtitle: isValid
                ? Text('\$${widget.item.amountController.text}')
                : const Text('Incomplete', style: TextStyle(color: Colors.orange)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: widget.item.titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => widget.onChanged(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: widget.item.amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          onChanged: (_) => widget.onChanged(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TransactionCategory>(
                    initialValue: widget.item.category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_getCategoryName(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.item.category = value;
                      });
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<PaymentMethod>(
                          initialValue: widget.item.paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: PaymentMethod.values.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              widget.item.paymentMethod = value ?? PaymentMethod.cash;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: widget.item.date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                widget.item.date = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: Text(
                              '${widget.item.date.day}/${widget.item.date.month}/${widget.item.date.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
